"""
Budget Overrun Prediction Service
Uses ML-based GradientBoosting model with fallback to time-series forecasting
"""
from typing import List, Dict, Any
from datetime import datetime
from backend.models import OverrunPrediction, ExpenseData, RiskLevel
import statistics
import logging

logger = logging.getLogger(__name__)

try:
    from backend.ml_models import get_model_manager
    ML_AVAILABLE = True
except ImportError:
    ML_AVAILABLE = False
    logger.warning("ML models not available, using rule-based predictions")


class OverrunPredictor:
    """Predicts if budget will be exceeded before month end"""
    
    @staticmethod
    def predict_overrun(
        current_spending: float,
        budget_limit: float,
        daily_expenses: List[ExpenseData],
        days_in_month: int,
        current_day: int
    ) -> OverrunPrediction:
        """
        Predicts if budget will be exceeded before month end.
        Uses ML model if available, falls back to rule-based approach.
        
        Args:
            current_spending: Total spent so far this month
            budget_limit: Monthly budget limit
            daily_expenses: List of daily expenses for current month
            days_in_month: Total days in current month
            current_day: Current day of month
            
        Returns:
            OverrunPrediction object with prediction details
        """
        
        if current_day >= days_in_month:
            return OverrunPrediction(
                will_overrun=current_spending > budget_limit,
                confidence=1.0,
                projected_spending=current_spending,
                budget_limit=budget_limit,
                days_remaining=0,
                risk_level=RiskLevel.HIGH if current_spending > budget_limit else RiskLevel.LOW,
                message='Month has ended'
            )
        
        days_remaining = days_in_month - current_day
        
        # Try to use ML model first
        if ML_AVAILABLE:
            try:
                return OverrunPredictor._predict_with_ml(
                    current_spending, budget_limit, daily_expenses,
                    days_in_month, current_day, days_remaining
                )
            except Exception as e:
                logger.warning(f"ML prediction failed: {e}, falling back to rule-based")
        
        # Fall back to rule-based prediction
        return OverrunPredictor._predict_rule_based(
            current_spending, budget_limit, daily_expenses,
            days_in_month, current_day, days_remaining
        )
    
    @staticmethod
    def _predict_with_ml(
        current_spending: float,
        budget_limit: float,
        daily_expenses: List[ExpenseData],
        days_in_month: int,
        current_day: int,
        days_remaining: int
    ) -> OverrunPrediction:
        """Use ML model for prediction."""
        try:
            model_manager = get_model_manager()
            ml_predictor = model_manager.get_overrun_predictor()
            
            # Convert expenses to format expected by ML model
            expenses_dict = [
                {
                    'amount': exp.amount,
                    'category': exp.category,
                    'date': exp.date
                }
                for exp in daily_expenses
            ]
            
            # Get ML prediction
            will_overrun, confidence, risk_level = ml_predictor.predict(
                current_spending, budget_limit, expenses_dict, current_day, days_in_month
            )
            
            # Project spending using ML confidence
            daily_rate = OverrunPredictor._calculate_weighted_daily_rate(daily_expenses, current_day)
            projected_spending = current_spending + (daily_rate * days_remaining)
            
            # Generate message based on ML prediction
            if will_overrun:
                message = f'⚠️ ML Alert: High risk! You\'re projected to exceed budget'
            else:
                message = '✅ ML Prediction: You\'re on track to stay within budget'
            
            return OverrunPrediction(
                will_overrun=will_overrun,
                confidence=confidence,
                projected_spending=projected_spending,
                budget_limit=budget_limit,
                days_remaining=days_remaining,
                risk_level=risk_level,
                message=message
            )
        except Exception as e:
            logger.error(f"ML prediction error: {e}")
            raise
    
    @staticmethod
    def _predict_rule_based(
        current_spending: float,
        budget_limit: float,
        daily_expenses: List[ExpenseData],
        days_in_month: int,
        current_day: int,
        days_remaining: int
    ) -> OverrunPrediction:
        """Rule-based prediction (original algorithm)."""
        # Calculate daily spending rate with weighted average
        daily_rate = OverrunPredictor._calculate_weighted_daily_rate(daily_expenses, current_day)
        
        # Project spending to end of month
        projected_spending = current_spending + (daily_rate * days_remaining)
        
        # Calculate confidence based on data consistency
        confidence = OverrunPredictor._calculate_confidence(daily_expenses, daily_rate)
        
        # Determine if will overrun
        will_overrun = projected_spending > budget_limit
        
        # Calculate risk level
        overrun_percentage = (projected_spending / budget_limit) * 100 if budget_limit > 0 else 0
        
        if overrun_percentage >= 100:
            risk_level = RiskLevel.HIGH
            message = f'High risk! You\'re projected to exceed budget by ${(projected_spending - budget_limit):.2f}'
        elif overrun_percentage >= 85:
            risk_level = RiskLevel.MEDIUM
            message = f'Medium risk. You\'re on track to use {overrun_percentage:.1f}% of your budget'
        else:
            risk_level = RiskLevel.LOW
            message = 'Looking good! You\'re on track to stay within budget'
        
        return OverrunPrediction(
            will_overrun=will_overrun,
            confidence=confidence,
            projected_spending=projected_spending,
            budget_limit=budget_limit,
            days_remaining=days_remaining,
            risk_level=risk_level,
            message=message
        )
    
    @staticmethod
    def _calculate_weighted_daily_rate(
        expenses: List[ExpenseData],
        current_day: int
    ) -> float:
        """
        Calculate weighted daily spending rate.
        Recent days have higher weight.
        """
        
        if not expenses:
            return 0.0
        
        # Group expenses by day
        daily_totals = {}
        for expense in expenses:
            day = expense.date.day
            daily_totals[day] = daily_totals.get(day, 0.0) + expense.amount
        
        # Calculate weighted average (recent days have more weight)
        weighted_sum = 0.0
        total_weight = 0.0
        
        for day, amount in daily_totals.items():
            # Weight increases linearly: more recent = higher weight
            weight = day / current_day
            weighted_sum += amount * weight
            total_weight += weight
        
        return weighted_sum / total_weight if total_weight > 0 else 0.0
    
    @staticmethod
    def _calculate_confidence(
        expenses: List[ExpenseData],
        avg_rate: float
    ) -> float:
        """
        Calculate confidence score based on data consistency.
        Lower variance = higher confidence.
        """
        
        if not expenses or avg_rate == 0:
            return 0.5
        
        # Group by day and calculate variance
        daily_totals = {}
        for expense in expenses:
            day = expense.date.day
            daily_totals[day] = daily_totals.get(day, 0.0) + expense.amount
        
        if len(daily_totals) < 3:
            return 0.6  # Low confidence with limited data
        
        # Calculate standard deviation
        values = list(daily_totals.values())
        
        try:
            mean = sum(values) / len(values)
            variance = sum((v - mean) ** 2 for v in values) / len(values)
            std_dev = variance ** 0.5 if variance > 0 else 0.0
        except:
            return 0.6
        
        # Lower variance = higher confidence
        # Normalize confidence between 0.5 and 0.95
        coefficient_of_variation = std_dev / mean if mean > 0 else 1.0
        confidence = 0.95 - (coefficient_of_variation * 0.45)
        
        return max(0.5, min(0.95, confidence))
