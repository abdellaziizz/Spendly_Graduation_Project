"""Monthly Spending Forecast Engine."""
from typing import List, Dict, Optional
import logging
import statistics

logger = logging.getLogger(__name__)


class MonthlyForecastEngine:
    """Forecasts spending for upcoming month."""
    
    def __init__(self):
        """Initialize the forecast engine."""
        pass
    
    def forecast_next_month(
        self,
        historical_monthly: List[float],
        current_month: Optional[float] = None
    ) -> Dict:
        """
        Forecast next month's spending using historical data.
        
        Args:
            historical_monthly: List of previous months' spending
            current_month: Current month's spending so far (optional)
        
        Returns:
            Dictionary with forecast results
        """
        try:
            if not historical_monthly or len(historical_monthly) == 0:
                return self._empty_forecast()
            
            # Calculate statistics
            avg_spending = statistics.mean(historical_monthly)
            
            # Trend analysis
            trend = self._analyze_trend(historical_monthly)
            
            # Forecast with trend adjustment
            if trend == "increasing":
                predicted = avg_spending * 1.05  # 5% increase
                trend_desc = "📈 Your spending is gradually increasing"
            elif trend == "decreasing":
                predicted = avg_spending * 0.95  # 5% decrease
                trend_desc = "📉 Your spending is decreasing"
            else:
                predicted = avg_spending
                trend_desc = "→ Your spending remains stable"
            
            # Confidence based on data consistency
            confidence = self._calculate_confidence(historical_monthly)
            
            return {
                "predicted_amount": round(predicted, 2),
                "confidence": confidence,
                "trend": trend,
                "trend_description": trend_desc,
                "average": round(avg_spending, 2),
                "months_analyzed": len(historical_monthly),
                "min_spending": round(min(historical_monthly), 2),
                "max_spending": round(max(historical_monthly), 2),
                "current_month": current_month or 0.0
            }
        
        except Exception as e:
            logger.error(f"Error forecasting: {e}")
            return self._empty_forecast(error=str(e))
    
    def _analyze_trend(self, historical: List[float]) -> str:
        """
        Analyze spending trend from historical data.
        """
        if len(historical) < 2:
            return "stable"
        
        # Simple linear regression
        recent = historical[-3:] if len(historical) >= 3 else historical
        older = historical[:-1] if len(historical) >= 2 else historical[:-1]
        
        if not recent or not older:
            return "stable"
        
        recent_avg = statistics.mean(recent)
        older_avg = statistics.mean(older)
        
        change_percent = ((recent_avg - older_avg) / older_avg * 100) if older_avg != 0 else 0
        
        if change_percent > 5:
            return "increasing"
        elif change_percent < -5:
            return "decreasing"
        else:
            return "stable"
    
    def _calculate_confidence(self, historical: List[float]) -> float:
        """
        Calculate confidence score based on data variance.
        Lower variance = higher confidence.
        """
        if len(historical) < 2:
            return 0.5
        
        try:
            stdev = statistics.stdev(historical)
            mean = statistics.mean(historical)
            
            # Coefficient of variation
            cv = (stdev / mean) if mean != 0 else 1.0
            
            # Convert CV to confidence (0-1)
            confidence = max(0.5, 1.0 - min(cv, 1.0))
            return round(confidence, 2)
        except:
            return 0.7
    
    def _empty_forecast(self, error: Optional[str] = None) -> Dict:
        """Return empty forecast."""
        return {
            "predicted_amount": 0.0,
            "confidence": 0.0,
            "trend": "stable",
            "trend_description": "Insufficient data",
            "average": 0.0,
            "months_analyzed": 0,
            "error": error
        }
