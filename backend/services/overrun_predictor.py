"""Budget Overrun Predictor Service."""
from datetime import datetime
from typing import Dict, List, Optional
import logging

logger = logging.getLogger(__name__)


class OverrunPredictor:
    """Predicts if user will exceed budget before month ends."""
    
    def __init__(self):
        """Initialize the overrun predictor."""
        self.categories_with_budget = {}
    
    def predict_overrun(
        self,
        current_spending: float,
        budget_limit: float,
        expenses: List[Dict],
        days_in_month: int = 30,
        current_day: int = 1
    ) -> Dict:
        """
        Predict if user will overrun budget.
        
        Args:
            current_spending: Total spent so far
            budget_limit: Budget limit
            expenses: List of expense records
            days_in_month: Total days in month
            current_day: Current day of month
        
        Returns:
            Dictionary with prediction results
        """
        try:
            # Calculate weighted daily rate (recent days weighted higher)
            daily_rate = self._calculate_weighted_daily_rate(expenses, days_in_month, current_day)
            
            # Days remaining
            days_left = max(days_in_month - current_day, 0)
            
            # Project spending
            projected_additional = daily_rate * days_left
            projected_total = current_spending + projected_additional
            
            # Determine overrun
            will_overrun = projected_total > budget_limit
            
            # Calculate confidence based on data points
            confidence = min(0.95, 0.6 + (len(expenses) * 0.01))
            
            # Risk level
            spending_ratio = projected_total / budget_limit if budget_limit > 0 else 0
            if spending_ratio > 1.0:
                risk_level = "high"
            elif spending_ratio > 0.85:
                risk_level = "medium"
            else:
                risk_level = "low"
            
            # Message
            if will_overrun:
                excess = projected_total - budget_limit
                message = f"⚠️ Warning: Projected to exceed budget by ${excess:.2f}"
            else:
                remaining = budget_limit - projected_total
                message = f"✅ You're on track to stay within budget (${remaining:.2f} remaining)"
            
            return {
                "will_overrun": will_overrun,
                "confidence": confidence,
                "projected_spending": round(projected_total, 2),
                "budget_limit": budget_limit,
                "current_spending": current_spending,
                "risk_level": risk_level,
                "days_left": days_left,
                "daily_rate": round(daily_rate, 2),
                "message": message
            }
        
        except Exception as e:
            logger.error(f"Error predicting overrun: {e}")
            return {
                "will_overrun": False,
                "confidence": 0.0,
                "projected_spending": current_spending,
                "budget_limit": budget_limit,
                "error": str(e)
            }
    
    def _calculate_weighted_daily_rate(
        self,
        expenses: List[Dict],
        days_in_month: int,
        current_day: int
    ) -> float:
        """
        Calculate weighted daily spending rate.
        Recent expenses weighted higher.
        """
        if not expenses or current_day == 0:
            return 0.0
        
        total_weighted = 0.0
        total_weight = 0.0
        
        # Sort by date (newest first for weighting)
        sorted_expenses = sorted(
            expenses,
            key=lambda x: x.get('date', ''),
            reverse=True
        )
        
        for idx, expense in enumerate(sorted_expenses[:current_day]):
            amount = expense.get('amount', 0)
            # Recent expenses get higher weight
            weight = (len(sorted_expenses[:current_day]) - idx) / len(sorted_expenses[:current_day])
            total_weighted += amount * weight
            total_weight += weight
        
        if total_weight == 0:
            return sum(e.get('amount', 0) for e in expenses) / max(current_day, 1)
        
        return total_weighted / total_weight / max(current_day, 1)
