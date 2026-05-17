"""
Training data generator for ML models.
Generates realistic synthetic spending data for model training.
"""

import numpy as np
from datetime import datetime, timedelta
from typing import Tuple, List, Dict
import random


class TrainingDataGenerator:
    """Generate realistic synthetic spending data for training ML models."""
    
    CATEGORIES = ['food', 'entertainment', 'transport', 'shopping', 'health', 'utilities', 'education', 'other']
    
    CATEGORY_KEYWORDS = {
        'food': ['Restaurant', 'Coffee Shop', 'Pizza', 'Burger', 'Café', 'Lunch', 'Dinner', 'Breakfast', 'Grocery'],
        'entertainment': ['Netflix', 'Spotify', 'Movie', 'Gaming', 'YouTube Premium', 'Steam', 'Cinema', 'Concert'],
        'transport': ['Uber', 'Taxi', 'Gas', 'Parking', 'Flight', 'Train', 'Bus', 'Metro', 'Fuel'],
        'shopping': ['Amazon', 'Mall', 'Electronics', 'Clothes', 'Shoes', 'Shopping Centre', 'Store'],
        'health': ['Pharmacy', 'Doctor', 'Gym', 'Hospital', 'Medicine', 'Health Club', 'Clinic', 'Yoga'],
        'utilities': ['Electric Bill', 'Water Bill', 'Internet', 'Rent', 'Phone Bill', 'Gas Bill', 'Insurance'],
        'education': ['School', 'Course', 'Tuition', 'University', 'Class', 'College', 'Online Course'],
    }
    
    CATEGORY_AMOUNTS = {
        'food': (5, 50),
        'entertainment': (10, 20),
        'transport': (5, 100),
        'shopping': (20, 200),
        'health': (20, 100),
        'utilities': (50, 200),
        'education': (50, 500),
        'other': (10, 100),
    }
    
    @staticmethod
    def generate_transactions(num_transactions: int = 500) -> Tuple[List[Dict], np.ndarray]:
        """Generate synthetic transactions for training."""
        transactions = []
        categories = []
        
        for _ in range(num_transactions):
            # Random category
            category = random.choice(TrainingDataGenerator.CATEGORIES)
            categories.append(category)
            
            # Random description
            keywords = TrainingDataGenerator.CATEGORY_KEYWORDS.get(category, ['Transaction'])
            description = random.choice(keywords) + f" #{random.randint(1, 100)}"
            
            # Random amount
            min_amt, max_amt = TrainingDataGenerator.CATEGORY_AMOUNTS[category]
            amount = random.uniform(min_amt, max_amt)
            
            # Random date
            days_ago = random.randint(0, 90)
            date = datetime.now() - timedelta(days=days_ago)
            
            transactions.append({
                'description': description,
                'amount': amount,
                'date': date,
                'category': category
            })
        
        return transactions, np.array(categories)
    
    @staticmethod
    def generate_overrun_data(num_samples: int = 200) -> Tuple[np.ndarray, np.ndarray]:
        """Generate training data for overrun prediction."""
        X_list = []
        y_list = []
        
        for _ in range(num_samples):
            budget_limit = random.uniform(2000, 5000)
            current_day = random.randint(1, 30)
            days_in_month = 30
            
            # Generate realistic expenses
            daily_spend = random.uniform(50, 300)
            num_expenses = random.randint(5, 20)
            expenses = []
            current_spending = 0
            
            for i in range(num_expenses):
                amount = random.uniform(10, 200)
                current_spending += amount
                expenses.append({
                    'amount': amount,
                    'category': random.choice(TrainingDataGenerator.CATEGORIES)
                })
            
            # Determine if overrun
            if current_day > 0:
                projected = current_spending / current_day * days_in_month
                will_overrun = projected >= budget_limit
            else:
                will_overrun = False
            
            # Extract features (same as in ml_models.py SpendlyOverrunPredictor)
            features = []
            features.append(current_spending / budget_limit if budget_limit > 0 else 0)
            features.append(current_day / days_in_month)
            features.append(current_spending / current_day if current_day > 0 else 0)
            
            amounts = [e['amount'] for e in expenses]
            features.append(np.std(amounts) if len(amounts) > 1 else 0)
            features.append(len(set(e['category'] for e in expenses)) / 8)
            
            recent_avg = np.mean(amounts[-3:]) if len(amounts) >= 3 else (amounts[-1] if amounts else 0)
            previous_avg = np.mean(amounts[-6:-3]) if len(amounts) >= 6 else 0
            trend = (recent_avg - previous_avg) / max(previous_avg, 1)
            features.append(trend)
            
            features.append(max(amounts) / budget_limit if budget_limit > 0 and amounts else 0)
            
            X_list.append(features)
            y_list.append(1 if will_overrun else 0)
        
        return np.array(X_list), np.array(y_list)
    
    @staticmethod
    def generate_forecast_data(num_samples: int = 100) -> Tuple[np.ndarray, np.ndarray]:
        """Generate training data for spending forecast."""
        X_list = []
        y_list = []
        
        for _ in range(num_samples):
            # Generate 6 months of data
            monthly_data = []
            for month in range(6):
                base = random.uniform(2000, 4000)
                noise = random.gauss(0, 200)
                trend = month * random.uniform(-50, 50)
                amount = base + noise + trend
                monthly_data.append(max(amount, 100))
            
            # Use first 5 months to predict 6th
            historical = monthly_data[:5]
            actual_next = monthly_data[5]
            
            # Extract features
            features = []
            features.append(np.mean(historical[-3:]) if len(historical) >= 3 else historical[-1])
            features.append(max(historical[-3:]) if len(historical) >= 3 else historical[-1])
            features.append(np.std(historical[-3:]) if len(historical) >= 3 else 0)
            
            trend = (historical[-1] - historical[-3]) / max(historical[-3], 1) if len(historical) >= 3 else 0
            features.append(trend)
            
            current_month = 5
            seasonality_factors = {
                0: 1.0, 1: 1.0, 2: 1.05, 3: 1.1, 4: 1.05, 5: 1.0,
                6: 0.95, 7: 0.9, 8: 0.95, 9: 1.0, 10: 1.05, 11: 1.15
            }
            features.append(seasonality_factors.get(current_month % 12, 1.0))
            features.append(len(historical) / 100)
            
            X_list.append(features)
            y_list.append(actual_next)
        
        return np.array(X_list), np.array(y_list)
    
    @staticmethod
    def generate_category_features(transactions: List[Dict]) -> Tuple[np.ndarray, np.ndarray]:
        """Convert transactions to feature vectors for category classification."""
        X_list = []
        
        for trans in transactions:
            description = trans['description']
            amount = trans['amount']
            date = trans['date']
            
            # Extract features (same as in ml_models.py)
            features = []
            
            desc_lower = description.lower()
            features.append(len(description))
            
            keywords_dict = TrainingDataGenerator.CATEGORY_KEYWORDS
            features.append(int(any(kw.lower() in desc_lower for kw in keywords_dict.get('food', []))))
            features.append(int(any(kw.lower() in desc_lower for kw in keywords_dict.get('entertainment', []))))
            features.append(int(any(kw.lower() in desc_lower for kw in keywords_dict.get('transport', []))))
            features.append(int(any(kw.lower() in desc_lower for kw in keywords_dict.get('shopping', []))))
            features.append(int(any(kw.lower() in desc_lower for kw in keywords_dict.get('health', []))))
            features.append(int(any(kw.lower() in desc_lower for kw in keywords_dict.get('utilities', []))))
            features.append(int(any(kw.lower() in desc_lower for kw in keywords_dict.get('education', []))))
            
            features.append(date.weekday())
            features.append(np.log1p(amount))
            features.append(hash(description) % 100)
            
            X_list.append(features)
        
        categories = np.array([t['category'] for t in transactions])
        return np.array(X_list), categories
