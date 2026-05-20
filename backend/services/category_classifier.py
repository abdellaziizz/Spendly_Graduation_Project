"""
Smart Category Classifier
Uses ML-based RandomForest classification with fuzzy matching fallback
"""
from typing import List, Dict, NamedTuple
from datetime import datetime
from backend.models import CategoryPrediction, CategoryMatch
import logging

logger = logging.getLogger(__name__)

try:
    from backend.ml_models import get_model_manager
    ML_AVAILABLE = True
except ImportError:
    ML_AVAILABLE = False
    logger.warning("ML models not available, using rule-based classification")


class _CategoryData(NamedTuple):
    """Category metadata"""
    keywords: List[str]
    description: str


class CategoryClassifier:
    """
    Smart category classifier for transactions.
    Uses fuzzy string matching and keyword analysis.
    """
    
    # Category keywords database
    _CATEGORY_DATABASE: Dict[str, _CategoryData] = {
        'food': _CategoryData(
            keywords=['restaurant', 'food', 'lunch', 'dinner', 'breakfast', 'cafe',
                     'coffee', 'pizza', 'burger', 'meal', 'eat', 'dining', 'snack',
                     'mcdonald', 'kfc', 'subway', 'starbucks', 'dominos', 'taco'],
            description='Food and Dining'
        ),
        'entertainment': _CategoryData(
            keywords=['netflix', 'spotify', 'movie', 'cinema', 'game', 'gaming',
                     'concert', 'theater', 'hulu', 'disney', 'youtube', 'prime',
                     'music', 'stream', 'subscription', 'entertainment', 'show'],
            description='Entertainment'
        ),
        'transport': _CategoryData(
            keywords=['uber', 'lyft', 'taxi', 'bus', 'train', 'metro', 'gas',
                     'fuel', 'parking', 'car', 'transport', 'travel', 'flight',
                     'airline', 'ticket', 'toll', 'transit', 'ride'],
            description='Transport and Travel'
        ),
        'shopping': _CategoryData(
            keywords=['amazon', 'ebay', 'shop', 'store', 'mall', 'clothing',
                     'clothes', 'fashion', 'electronics', 'walmart', 'target',
                     'purchase', 'buy', 'online', 'retail', 'cart'],
            description='Shopping'
        ),
        'health': _CategoryData(
            keywords=['pharmacy', 'medicine', 'doctor', 'hospital', 'clinic',
                     'health', 'medical', 'dentist', 'prescription', 'insurance',
                     'gym', 'fitness', 'wellness', 'spa', 'yoga'],
            description='Health and Wellness'
        ),
        'utilities': _CategoryData(
            keywords=['electric', 'electricity', 'water', 'gas', 'internet',
                     'phone', 'mobile', 'utility', 'bill', 'rent', 'mortgage',
                     'service', 'isp'],
            description='Utilities and Bills'
        ),
        'education': _CategoryData(
            keywords=['school', 'university', 'college', 'course', 'book',
                     'tuition', 'education', 'learn', 'study', 'class', 'udemy',
                     'coursera', 'training', 'lesson'],
            description='Education'
        ),
        'other': _CategoryData(
            keywords=['other', 'misc', 'miscellaneous', 'general'],
            description='Other'
        ),
    }
    
    @staticmethod
    def predict_category(description: str, amount: float = 0.0) -> CategoryPrediction:
        """
        Predict category from transaction description.
        Uses ML model if available, falls back to fuzzy matching.
        
        Args:
            description: Transaction description or merchant name
            amount: Transaction amount (optional, used by ML model)
            
        Returns:
            CategoryPrediction with category, confidence, and alternatives
        """
        
        if not description or not description.strip():
            return CategoryPrediction(
                category='other',
                confidence=0.5,
                alternative_matches=[]
            )
        
        # Try ML prediction first
        if ML_AVAILABLE:
            try:
                return CategoryClassifier._predict_with_ml(description, amount)
            except Exception as e:
                logger.warning(f"ML classification failed: {e}, falling back to rule-based")
        
        # Fall back to rule-based prediction
        return CategoryClassifier._predict_rule_based(description)
    
    @staticmethod
    def _predict_with_ml(description: str, amount: float) -> CategoryPrediction:
        """Use ML model for prediction."""
        try:
            model_manager = get_model_manager()
            ml_classifier = model_manager.get_category_classifier()
            
            # Get ML prediction
            predicted_category, confidence, alternatives = ml_classifier.predict(
                description, amount, datetime.now()
            )
            
            # Convert alternatives to CategoryMatch objects
            alt_matches = [
                CategoryMatch(category=alt['category'], score=alt['score'])
                for alt in alternatives
            ]
            
            return CategoryPrediction(
                category=predicted_category,
                confidence=confidence,
                alternative_matches=alt_matches
            )
        except Exception as e:
            logger.error(f"ML classification error: {e}")
            raise
    
    @staticmethod
    def _predict_rule_based(description: str) -> CategoryPrediction:
        """Rule-based prediction (original algorithm)."""
        if not description or not description.strip():
            return CategoryPrediction(
                category='other',
                confidence=0.5,
                alternative_matches=[]
            )
        
        normalized_desc = description.lower().strip()
        
        # Calculate scores for each category
        category_scores = {}
        
        for category, data in CategoryClassifier._CATEGORY_DATABASE.items():
            score = CategoryClassifier._calculate_category_score(normalized_desc, data.keywords)
            category_scores[category] = score
        
        # Sort categories by score
        sorted_categories = sorted(category_scores.items(), key=lambda x: x[1], reverse=True)
        
        # Get best match
        best_category = sorted_categories[0][0]
        confidence = sorted_categories[0][1]
        
        # Get alternative matches (top 3, excluding best)
        alternatives = []
        for i in range(1, min(len(sorted_categories), 4)):
            if sorted_categories[i][1] > 0.2:
                alternatives.append(CategoryMatch(
                    category=sorted_categories[i][0],
                    score=sorted_categories[i][1]
                ))
        
        return CategoryPrediction(
            category=best_category,
            confidence=confidence,
            alternative_matches=alternatives
        )
    
    @staticmethod
    def _calculate_category_score(description: str, keywords: List[str]) -> float:
        """
        Calculate category match score for a description.
        Exact matches get higher scores than fuzzy matches.
        """
        
        max_score = 0.0
        
        for keyword in keywords:
            # Exact match gets highest score
            if keyword in description:
                max_score = 1.0
                break
            
            # Fuzzy match using Levenshtein distance
            words = description.split()
            for word in words:
                similarity = CategoryClassifier._levenshtein_similarity(word, keyword)
                if similarity > max_score:
                    max_score = similarity
        
        return max_score
    
    @staticmethod
    def _levenshtein_similarity(s1: str, s2: str) -> float:
        """
        Calculate similarity using Levenshtein distance.
        Returns value between 0 (no match) and 1 (perfect match).
        Only returns significant similarities (threshold 0.7).
        """
        
        if s1 == s2:
            return 1.0
        if not s1 or not s2:
            return 0.0
        
        distance = CategoryClassifier._levenshtein_distance(s1, s2)
        max_length = max(len(s1), len(s2))
        
        # Convert distance to similarity (0-1 scale)
        similarity = 1.0 - (distance / max_length)
        
        # Only return significant similarities (threshold 0.7)
        return similarity if similarity >= 0.7 else 0.0
    
    @staticmethod
    def _levenshtein_distance(s1: str, s2: str) -> int:
        """
        Calculate Levenshtein distance between two strings.
        """
        
        if len(s1) < len(s2):
            return CategoryClassifier._levenshtein_distance(s2, s1)
        
        if len(s2) == 0:
            return len(s1)
        
        previous_row = range(len(s2) + 1)
        
        for i, c1 in enumerate(s1):
            current_row = [i + 1]
            
            for j, c2 in enumerate(s2):
                insertions = previous_row[j + 1] + 1
                deletions = current_row[j] + 1
                substitutions = previous_row[j] + (c1 != c2)
                current_row.append(min(insertions, deletions, substitutions))
            
            previous_row = current_row
        
        return previous_row[-1]
