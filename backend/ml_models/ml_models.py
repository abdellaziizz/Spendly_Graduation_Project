"""
ML Models for Spendly predictions and insights.
- Category Classifier: RandomForest for transaction categorization
- Overrun Predictor: GradientBoosting for budget prediction
- Spending Forecaster: GradientBoosting for monthly forecast
"""

from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier, GradientBoostingRegressor
from sklearn.preprocessing import LabelEncoder, StandardScaler
import numpy as np
import pickle
import os
from typing import Tuple, List, Dict, Any
from datetime import datetime, timedelta
from backend.models import RiskLevel


class SpendlyCategoryClassifier:
    """ML-based transaction category classifier using RandomForest."""
    
    def __init__(self):
        self.model = RandomForestClassifier(n_estimators=100, random_state=42, max_depth=10)
        self.label_encoder = LabelEncoder()
        self.scaler = StandardScaler()
        self.feature_names = [
            'description_length', 'has_food_keyword', 'has_entertainment_keyword',
            'has_transport_keyword', 'has_shopping_keyword', 'has_health_keyword',
            'has_utilities_keyword', 'has_education_keyword', 'day_of_week',
            'amount_log', 'description_hash_mod'
        ]
        self.is_trained = False
    
    def extract_features(self, description: str, amount: float, date: datetime) -> np.ndarray:
        """Extract numerical features from transaction data."""
        features = []
        
        # Text features
        desc_lower = description.lower()
        features.append(len(description))  # description_length
        
        # Keyword matching
        food_keywords = ['food', 'restaurant', 'coffee', 'pizza', 'burger', 'cafe', 'lunch', 'dinner', 'breakfast']
        entertainment_keywords = ['netflix', 'spotify', 'movie', 'gaming', 'game', 'youtube', 'steam', 'cinema']
        transport_keywords = ['uber', 'taxi', 'gas', 'parking', 'flight', 'train', 'bus', 'metro', 'fuel']
        shopping_keywords = ['amazon', 'mall', 'electronics', 'clothes', 'shop', 'store', 'buy', 'shopping']
        health_keywords = ['pharmacy', 'doctor', 'gym', 'hospital', 'medicine', 'health', 'clinic']
        utilities_keywords = ['electric', 'water', 'internet', 'rent', 'phone', 'utility', 'bill']
        education_keywords = ['school', 'course', 'tuition', 'education', 'class', 'university', 'college']
        
        features.append(int(any(kw in desc_lower for kw in food_keywords)))
        features.append(int(any(kw in desc_lower for kw in entertainment_keywords)))
        features.append(int(any(kw in desc_lower for kw in transport_keywords)))
        features.append(int(any(kw in desc_lower for kw in shopping_keywords)))
        features.append(int(any(kw in desc_lower for kw in health_keywords)))
        features.append(int(any(kw in desc_lower for kw in utilities_keywords)))
        features.append(int(any(kw in desc_lower for kw in education_keywords)))
        
        # Temporal features
        features.append(date.weekday())  # day_of_week (0-6)
        
        # Amount features
        features.append(np.log1p(amount))  # amount_log (log scale)
        
        # Hash-based feature
        features.append(hash(description) % 100)  # description_hash_mod
        
        return np.array(features, dtype=float).reshape(1, -1)
    
    def predict(self, description: str, amount: float, date: datetime) -> Tuple[str, float, List[Dict]]:
        """Predict category for a transaction."""
        if not self.is_trained:
            # Fallback to rule-based
            return self._rule_based_predict(description)
        
        features = self.extract_features(description, amount, date)
        features_scaled = self.scaler.transform(features)
        
        # Get prediction
        predicted_label = self.model.predict(features_scaled)[0]
        confidence = float(np.max(self.model.predict_proba(features_scaled)))
        
        # Get probabilities for all classes
        probabilities = self.model.predict_proba(features_scaled)[0]
        classes = self.label_encoder.classes_
        
        # Get top alternatives
        alternatives = []
        for idx in np.argsort(probabilities)[::-1][1:4]:  # Top 3 alternatives
            score = float(probabilities[idx])
            if score > 0.1:  # Only if > 10%
                alternatives.append({
                    'category': str(classes[idx]),
                    'score': score,
                    'icon': self._get_icon(classes[idx])
                })
        
        return str(predicted_label), confidence, alternatives
    
    def _rule_based_predict(self, description: str) -> Tuple[str, float, List[Dict]]:
        """Fallback rule-based prediction."""
        desc_lower = description.lower()
        categories = {
            'food': ['food', 'restaurant', 'coffee', 'pizza', 'burger'],
            'entertainment': ['netflix', 'spotify', 'movie', 'gaming'],
            'transport': ['uber', 'taxi', 'gas', 'parking', 'flight'],
            'shopping': ['amazon', 'mall', 'electronics', 'clothes'],
            'health': ['pharmacy', 'doctor', 'gym', 'hospital'],
            'utilities': ['electric', 'water', 'internet', 'rent'],
            'education': ['school', 'course', 'tuition'],
        }
        
        for cat, keywords in categories.items():
            if any(kw in desc_lower for kw in keywords):
                return cat, 0.8, []
        
        return 'other', 0.5, []
    
    @staticmethod
    def _get_icon(category: str) -> str:
        icons = {
            'food': 'restaurant', 'entertainment': 'movie',
            'transport': 'directions_car', 'shopping': 'shopping_cart',
            'health': 'health_and_safety', 'utilities': 'home',
            'education': 'school', 'other': 'help'
        }
        return icons.get(category, 'help')
    
    def train(self, X: np.ndarray, y: np.ndarray):
        """Train the classifier."""
        self.label_encoder.fit(y)
        y_encoded = self.label_encoder.transform(y)
        
        X_scaled = self.scaler.fit_transform(X)
        self.model.fit(X_scaled, y_encoded)
        self.is_trained = True


class SpendlyOverrunPredictor:
    """ML-based budget overrun predictor using GradientBoosting."""
    
    def __init__(self):
        self.model = GradientBoostingClassifier(n_estimators=100, random_state=42, max_depth=5)
        self.scaler = StandardScaler()
        self.is_trained = False
        self.feature_names = [
            'current_spending_ratio', 'days_passed_ratio', 'daily_avg_spend',
            'weekly_variance', 'category_spread', 'recent_trend', 'max_transaction'
        ]
    
    def extract_features(self, current_spending: float, budget_limit: float, 
                        expenses: List[Dict], current_day: int, days_in_month: int) -> np.ndarray:
        """Extract features for overrun prediction."""
        features = []
        
        # Spending ratio
        features.append(current_spending / budget_limit if budget_limit > 0 else 0)
        
        # Days passed ratio
        features.append(current_day / days_in_month if days_in_month > 0 else 0)
        
        # Daily average spend
        daily_avg = current_spending / current_day if current_day > 0 else 0
        features.append(daily_avg)
        
        # Weekly variance
        if len(expenses) > 0:
            amounts = [e.get('amount', 0) for e in expenses]
            weekly_var = np.std(amounts) if len(amounts) > 1 else 0
            features.append(weekly_var)
            
            # Category spread
            categories = set(e.get('category', 'other') for e in expenses)
            features.append(len(categories) / 8)  # 8 categories max
            
            # Recent trend (last 3 days vs previous 3 days)
            recent_avg = np.mean(amounts[-3:]) if len(amounts) >= 3 else amounts[-1] if amounts else 0
            previous_avg = np.mean(amounts[-6:-3]) if len(amounts) >= 6 else 0
            trend = (recent_avg - previous_avg) / max(previous_avg, 1)
            features.append(trend)
            
            # Max transaction
            features.append(max(amounts) / budget_limit if budget_limit > 0 else 0)
        else:
            features.extend([0] * 4)
        
        return np.array(features, dtype=float).reshape(1, -1)
    
    def predict(self, current_spending: float, budget_limit: float, 
               expenses: List[Dict], current_day: int, days_in_month: int) -> Tuple[bool, float, RiskLevel]:
        """Predict if budget will be overrun."""
        if not self.is_trained:
            return self._rule_based_predict(current_spending, budget_limit, current_day, days_in_month)
        
        features = self.extract_features(current_spending, budget_limit, expenses, current_day, days_in_month)
        features_scaled = self.scaler.transform(features)
        
        overrun_prob = float(self.model.predict_proba(features_scaled)[0][1])
        will_overrun = overrun_prob > 0.5
        
        # Determine risk level and return as RiskLevel enum
        if overrun_prob > 0.7:
            risk_level = RiskLevel.HIGH
        elif overrun_prob > 0.4:
            risk_level = RiskLevel.MEDIUM
        else:
            risk_level = RiskLevel.LOW

        return will_overrun, overrun_prob, risk_level
    
    def _rule_based_predict(self, current_spending: float, budget_limit: float, 
                           current_day: int, days_in_month: int) -> Tuple[bool, float, RiskLevel]:
        """Fallback rule-based prediction."""
        spending_ratio = current_spending / budget_limit if budget_limit > 0 else 0
        days_ratio = current_day / days_in_month if days_in_month > 0 else 0
        
        if days_ratio > 0:
            projected = current_spending / days_ratio
            overrun = projected >= budget_limit
            confidence = min(spending_ratio, 0.95)
        else:
            overrun = False
            confidence = 0.5
        
        if spending_ratio >= 0.9:
            risk = RiskLevel.HIGH
        elif spending_ratio >= 0.7:
            risk = RiskLevel.MEDIUM
        else:
            risk = RiskLevel.LOW
        
        return overrun, confidence, risk
    
    def train(self, X: np.ndarray, y: np.ndarray):
        """Train the classifier."""
        X_scaled = self.scaler.fit_transform(X)
        self.model.fit(X_scaled, y)
        self.is_trained = True


class SpendlyForecastPredictor:
    """ML-based spending forecast using GradientBoosting regression."""
    
    def __init__(self):
        self.model = GradientBoostingRegressor(n_estimators=100, random_state=42, max_depth=5)
        self.scaler = StandardScaler()
        self.is_trained = False
        self.feature_names = [
            'prev_month_avg', 'prev_month_max', 'prev_month_variance',
            'trend_3mo', 'seasonality_factor', 'num_transactions'
        ]
    
    def extract_features(self, monthly_data: List[float], current_month: int) -> np.ndarray:
        """Extract features for spending forecast."""
        features = []
        
        if len(monthly_data) < 2:
            return np.array([0] * len(self.feature_names), dtype=float).reshape(1, -1)
        
        # Previous month metrics
        prev_month = monthly_data[-1]
        features.append(np.mean(monthly_data[-3:]) if len(monthly_data) >= 3 else prev_month)  # prev_month_avg
        features.append(max(monthly_data[-3:]) if len(monthly_data) >= 3 else prev_month)  # prev_month_max
        features.append(np.std(monthly_data[-3:]) if len(monthly_data) >= 3 else 0)  # prev_month_variance
        
        # 3-month trend
        if len(monthly_data) >= 3:
            trend = (monthly_data[-1] - monthly_data[-3]) / max(monthly_data[-3], 1)
        else:
            trend = 0
        features.append(trend)  # trend_3mo
        
        # Seasonality (simple: month of year factor)
        seasonality_factors = {
            0: 1.0, 1: 1.0, 2: 1.05, 3: 1.1, 4: 1.05, 5: 1.0,
            6: 0.95, 7: 0.9, 8: 0.95, 9: 1.0, 10: 1.05, 11: 1.15
        }
        features.append(seasonality_factors.get(current_month % 12, 1.0))  # seasonality_factor
        
        # Number of transactions
        features.append(min(len(monthly_data), 100) / 100)  # num_transactions (normalized)
        
        return np.array(features, dtype=float).reshape(1, -1)
    
    def predict(self, monthly_data: List[float], current_month: int) -> Tuple[float, float, str]:
        """Predict next month's spending."""
        if not self.is_trained or len(monthly_data) < 2:
            return self._rule_based_predict(monthly_data)
        
        features = self.extract_features(monthly_data, current_month)
        features_scaled = self.scaler.transform(features)
        
        predicted_amount = float(self.model.predict(features_scaled)[0])
        confidence = 0.85  # ML confidence
        
        # Determine trend
        if len(monthly_data) >= 2:
            recent_avg = np.mean(monthly_data[-2:])
            older_avg = np.mean(monthly_data[:-2]) if len(monthly_data) > 2 else monthly_data[0]
            change_pct = (predicted_amount - recent_avg) / max(recent_avg, 1)
            
            if change_pct > 0.1:
                trend = 'increasing'
            elif change_pct < -0.1:
                trend = 'decreasing'
            else:
                trend = 'stable'
        else:
            trend = 'stable'
        
        return max(predicted_amount, 0), confidence, trend
    
    def _rule_based_predict(self, monthly_data: List[float]) -> Tuple[float, float, str]:
        """Fallback rule-based prediction."""
        if not monthly_data:
            return 0, 0.5, 'stable'
        
        avg = np.mean(monthly_data)
        confidence = 0.7
        
        if len(monthly_data) >= 2:
            trend_val = (monthly_data[-1] - monthly_data[-2]) / max(monthly_data[-2], 1)
            if trend_val > 0.05:
                trend = 'increasing'
            elif trend_val < -0.05:
                trend = 'decreasing'
            else:
                trend = 'stable'
        else:
            trend = 'stable'
        
        return avg, confidence, trend
    
    def train(self, X: np.ndarray, y: np.ndarray):
        """Train the regressor."""
        X_scaled = self.scaler.fit_transform(X)
        self.model.fit(X_scaled, y)
        self.is_trained = True
