"""
Monthly Forecast Engine
Uses ML-based GradientBoosting regression with linear regression fallback
"""
from typing import List, NamedTuple
from datetime import datetime
from backend.models import MonthlyForecast
import logging

logger = logging.getLogger(__name__)

try:
    from backend.ml_models import get_model_manager
    ML_AVAILABLE = True
except ImportError:
    ML_AVAILABLE = False
    logger.warning("ML models not available, using rule-based forecast")


class _RegressionResult(NamedTuple):
    """Result of linear regression"""
    slope: float
    intercept: float
    r_squared: float


class MonthlyForecastEngine:
    """Predicts next month's total expenses using linear regression"""
    
    @staticmethod
    def predict_next_month(monthly_expenses: List[float]) -> MonthlyForecast:
        """
        Predicts next month's total expenses using ML model or linear regression.
        
        Args:
            monthly_expenses: List of total expenses for past months
                            (Index 0 = oldest month, Last index = current/most recent month)
                            
        Returns:
            MonthlyForecast object with prediction details
        """
        
        if not monthly_expenses:
            return MonthlyForecast(
                predicted_amount=0.0,
                confidence=0.0,
                historical_data=[],
                trend=0.0,
                trend_description='No data available'
            )
        
        if len(monthly_expenses) == 1:
            return MonthlyForecast(
                predicted_amount=monthly_expenses[0],
                confidence=0.5,
                historical_data=monthly_expenses,
                trend=0.0,
                trend_description='Insufficient data for trend analysis'
            )
        
        # Try ML prediction first
        if ML_AVAILABLE:
            try:
                return MonthlyForecastEngine._predict_with_ml(monthly_expenses)
            except Exception as e:
                logger.warning(f"ML forecast failed: {e}, falling back to rule-based")
        
        # Fall back to rule-based prediction
        return MonthlyForecastEngine._predict_rule_based(monthly_expenses)
    
    @staticmethod
    def _predict_with_ml(monthly_expenses: List[float]) -> MonthlyForecast:
        """Use ML model for prediction."""
        try:
            model_manager = get_model_manager()
            ml_predictor = model_manager.get_forecast_predictor()
            
            # Get ML prediction
            predicted_amount, confidence, trend_description = ml_predictor.predict(
                monthly_expenses, datetime.now().month
            )
            
            # Calculate trend for display
            if len(monthly_expenses) >= 2:
                trend = (monthly_expenses[-1] - monthly_expenses[-2]) / max(monthly_expenses[-2], 1)
            else:
                trend = 0.0
            
            return MonthlyForecast(
                predicted_amount=predicted_amount,
                confidence=confidence,
                historical_data=monthly_expenses,
                trend=trend,
                trend_description=f'✨ ML Forecast: {trend_description}'
            )
        except Exception as e:
            logger.error(f"ML forecast error: {e}")
            raise
    
    @staticmethod
    def _predict_rule_based(monthly_expenses: List[float]) -> MonthlyForecast:
        """Rule-based prediction (original algorithm)."""
        # Perform simple linear regression
        regression = MonthlyForecastEngine._linear_regression(monthly_expenses)
        
        # Predict next month (one step ahead)
        next_month_index = len(monthly_expenses)
        prediction = regression.slope * next_month_index + regression.intercept
        
        # Ensure prediction is non-negative
        predicted_amount = max(0.0, prediction)
        
        # Calculate confidence based on R-squared
        confidence = max(0.5, min(0.95, regression.r_squared))
        
        # Determine trend
        trend = regression.slope
        trend_description = MonthlyForecastEngine._describe_trend(trend, monthly_expenses)
        
        return MonthlyForecast(
            predicted_amount=predicted_amount,
            confidence=confidence,
            historical_data=monthly_expenses,
            trend=trend,
            trend_description=trend_description
        )
    
    @staticmethod
    def _linear_regression(values: List[float]) -> _RegressionResult:
        """
        Perform linear regression on time series data.
        X values are time indices: 0, 1, 2, ...
        """
        
        n = len(values)
        
        # Calculate sums needed for regression
        sum_x = 0.0
        sum_y = 0.0
        sum_xy = 0.0
        sum_x2 = 0.0
        sum_y2 = 0.0
        
        for i in range(n):
            x = float(i)
            y = values[i]
            
            sum_x += x
            sum_y += y
            sum_xy += x * y
            sum_x2 += x * x
            sum_y2 += y * y
        
        # Calculate slope (m) and intercept (b)
        # Formula: m = (n*Σxy - Σx*Σy) / (n*Σx² - (Σx)²)
        numerator = (n * sum_xy) - (sum_x * sum_y)
        denominator = (n * sum_x2) - (sum_x * sum_x)
        
        slope = numerator / denominator if denominator != 0 else 0.0
        intercept = (sum_y - (slope * sum_x)) / n
        
        # Calculate R-squared (coefficient of determination)
        mean_y = sum_y / n
        ss_total = 0.0
        ss_residual = 0.0
        
        for i in range(n):
            x = float(i)
            y = values[i]
            predicted = slope * x + intercept
            
            ss_total += (y - mean_y) ** 2
            ss_residual += (y - predicted) ** 2
        
        r_squared = 1 - (ss_residual / ss_total) if ss_total != 0 else 0.0
        r_squared = max(0.0, min(1.0, r_squared))
        
        return _RegressionResult(
            slope=slope,
            intercept=intercept,
            r_squared=r_squared
        )
    
    @staticmethod
    def _describe_trend(slope: float, data: List[float]) -> str:
        """Describe the spending trend in user-friendly language"""
        
        if len(data) < 2:
            return 'Insufficient data'
        
        avg_expense = sum(data) / len(data)
        percentage_change = (slope / avg_expense) * 100 if avg_expense > 0 else 0
        
        if abs(percentage_change) < 5:
            return 'Your spending is stable'
        elif percentage_change > 15:
            return 'Your spending is increasing significantly'
        elif percentage_change > 5:
            return 'Your spending is gradually increasing'
        elif percentage_change < -15:
            return 'Your spending is decreasing significantly'
        else:
            return 'Your spending is gradually decreasing'
    
    @staticmethod
    def exponential_smoothing(data: List[float], alpha: float = 0.3) -> float:
        """
        Exponential Smoothing (Alternative method for comparison)
        Alpha controls smoothing: 0 < alpha < 1
        Higher alpha = more weight on recent data
        """
        
        if not data:
            return 0.0
        if len(data) == 1:
            return data[0]
        
        smoothed = data[0]
        
        for i in range(1, len(data)):
            smoothed = alpha * data[i] + (1 - alpha) * smoothed
        
        return smoothed
