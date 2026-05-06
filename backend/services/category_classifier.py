"""Category Classifier Service."""
from typing import Dict, List, Tuple, Optional
import logging
import re

logger = logging.getLogger(__name__)


class CategoryClassifier:
    """Classifies transactions into categories."""
    
    # Keywords for each category
    CATEGORY_KEYWORDS = {
        'food': [
            'restaurant', 'cafe', 'coffee', 'pizza', 'burger', 'grocery', 'supermarket',
            'food', 'lunch', 'dinner', 'breakfast', 'starbucks', 'mcdonald', 'subway',
            'trader joe', 'whole foods', 'safeway', 'kroger', 'walmart'
        ],
        'entertainment': [
            'cinema', 'movie', 'theater', 'netflix', 'spotify', 'hulu', 'disney',
            'game', 'gaming', 'entertainment', 'concert', 'ticket', 'hbo', 'twitch',
            'playstation', 'xbox', 'steam'
        ],
        'transport': [
            'uber', 'lyft', 'taxi', 'gas', 'fuel', 'transit', 'bus', 'train',
            'transportation', 'parking', 'metro', 'airline', 'flight', 'car rental',
            'shell', 'chevron', 'exxon'
        ],
        'shopping': [
            'amazon', 'mall', 'store', 'shop', 'retail', 'target', 'costco',
            'forever 21', 'h&m', 'zara', 'gap', 'shopping', 'mall', 'boutique',
            'ebay', 'etsy'
        ],
        'health': [
            'pharmacy', 'doctor', 'hospital', 'clinic', 'health', 'dental',
            'gym', 'fitness', 'yoga', 'medical', 'cvs', 'walgreens', 'mental health',
            'therapist', 'dermatology', 'surgery'
        ],
        'utilities': [
            'electricity', 'water', 'gas', 'internet', 'phone', 'utility',
            'verizon', 'at&t', 'comcast', 'power', 'utility bill'
        ],
        'education': [
            'school', 'university', 'college', 'tuition', 'course', 'education',
            'udemy', 'skillshare', 'university', 'book', 'textbook'
        ]
    }
    
    def __init__(self):
        """Initialize the classifier."""
        # Custom keywords learned from user feedback
        self.learned_keywords = {
            'food': [],
            'entertainment': [],
            'transport': [],
            'shopping': [],
            'health': [],
            'utilities': [],
            'education': [],
            'other': []
        }
        # Track learned examples for reinforcement
        self.learned_examples = []

    def train_from_feedback(self, description: str, correct_category: str) -> Dict:
        """
        Train the classifier from user corrections/feedback.

        Args:
            description: Transaction description
            correct_category: The correct category provided by user

        Returns:
            Training result with status
        """
        try:
            description_lower = description.lower()

            # Extract meaningful words from description (longer than 3 chars)
            words = [
                word for word in description_lower.split()
                if len(word) > 3 and not word.isdigit()
            ]

            # Add primary word as learned keyword
            if words:
                primary_word = max(words, key=len)
                if correct_category in self.learned_keywords:
                    if primary_word not in self.learned_keywords[correct_category]:
                        self.learned_keywords[correct_category].append(primary_word)
                        logger.info(
                            "Learned keyword '%s' for category '%s'",
                            primary_word,
                            correct_category,
                        )

            # Store example for analysis
            self.learned_examples.append({
                'description': description,
                'category': correct_category
            })

            # Keep only recent examples (last 100)
            if len(self.learned_examples) > 100:
                self.learned_examples = self.learned_examples[-100:]

            return {
                'trained': True,
                'message': f"Learned from user: '{description}' is '{correct_category}'",
                'keywords_added': len(words)
            }

        except Exception as e:
            logger.error(f"Error training classifier: {e}")
            return {
                'trained': False,
                'error': str(e)
            }
    
    def classify(self, description: str) -> Dict:
        """
        Classify transaction description into category.
        
        Args:
            description: Transaction description
        
        Returns:
            Dictionary with category and confidence
        """
        try:
            description_lower = description.lower()

            # Find matching categories
            matches = {}
            for category, keywords in self.CATEGORY_KEYWORDS.items():
                # Check both predefined and learned keywords
                all_keywords = keywords + self.learned_keywords.get(category, [])
                confidence = self._calculate_confidence(description_lower, all_keywords)
                if confidence > 0:
                    matches[category] = confidence

            # Determine best match
            if matches:
                best_category = max(matches, key=matches.get)
                best_confidence = matches[best_category]

                # Alternative matches (top 3)
                alternatives = sorted(
                    [
                        {"category": cat, "confidence": conf}
                        for cat, conf in matches.items()
                        if cat != best_category
                    ],
                    key=lambda x: x["confidence"],
                    reverse=True
                )[:2]
                
                return {
                    "category": best_category,
                    "confidence": round(best_confidence, 2),
                    "alternatives": alternatives
                }
            else:
                return {
                    "category": "other",
                    "confidence": 0.0,
                    "alternatives": []
                }

        except Exception as e:
            logger.error(f"Error classifying: {e}")
            return {
                "category": "other",
                "confidence": 0.0,
                "error": str(e)
            }
    
    def _calculate_confidence(self, description: str, keywords: List[str]) -> float:
        """
        Calculate confidence score for category.
        """
        matches = 0
        for keyword in keywords:
            if keyword.lower() in description:
                matches += 1
        
        if matches == 0:
            return 0.0

        # Confidence increases with number of matches
        confidence = min(matches * 0.3, 1.0)
        return confidence
    
    def classify_batch(self, descriptions: List[str]) -> List[Dict]:
        """
        Classify multiple descriptions.
        
        Args:
            descriptions: List of transaction descriptions
        
        Returns:
            List of classification results
        """
        return [self.classify(desc) for desc in descriptions]

    def get_learned_data(self) -> Dict:
        """
        Get statistics about learned patterns.
        
        Returns:
            Dictionary with learned keywords and examples count
        """
        learned_count = sum(len(keywords) for keywords in self.learned_keywords.values())
        return {
            'total_learned_keywords': learned_count,
            'learned_keywords': self.learned_keywords,
            'total_examples_trained': len(self.learned_examples),
            'categories_with_learned_keywords': [
                cat for cat, kw in self.learned_keywords.items() if kw
            ]
        }
