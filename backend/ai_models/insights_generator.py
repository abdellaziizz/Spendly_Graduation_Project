"""AI Insights Generator."""
from typing import Dict, List, Optional
import logging
import statistics

logger = logging.getLogger(__name__)


class InsightsGenerator:
    """Generates AI-powered insights from financial data."""
    
    def __init__(self):
        """Initialize the insights generator."""
        pass
    
    def generate_insights(self, predictions: Dict, expenses: List[Dict]) -> Dict:
        """
        Generate comprehensive AI insights.
        
        Args:
            predictions: Dictionary with all predictions
            expenses: List of expense records
        
        Returns:
            Dictionary with insights and recommendations
        """
        try:
            category_outlooks = self._generate_category_outlooks(predictions, expenses)
            insights = {
                "budget_insights": self._generate_budget_insights(predictions),
                "spending_patterns": self._generate_spending_patterns(expenses),
                "recommendations": self._generate_recommendations(predictions, expenses),
                "alerts": self._generate_alerts(predictions, expenses),
                "category_outlooks": category_outlooks,
                "comparison_summary": self._generate_comparison_summary(predictions, expenses, category_outlooks),
                "summary": self._generate_summary(predictions, expenses)
            }
            return insights
        
        except Exception as e:
            logger.error(f"Error generating insights: {e}")
            return {"error": str(e)}
    
    def _generate_budget_insights(self, predictions: Dict) -> List[Dict]:
        """Generate budget-related insights."""
        insights = []
        
        overrun = predictions.get('overrun_prediction', {})
        if overrun:
            risk_level = overrun.get('risk_level', 'low')
            message = overrun.get('message', '')
            
            if risk_level == 'high':
                insights.append({
                    "type": "budget_alert",
                    "severity": "high",
                    "title": "🚨 High Budget Risk",
                    "description": message,
                    "action": "Review your spending immediately"
                })
            elif risk_level == 'medium':
                insights.append({
                    "type": "budget_warning",
                    "severity": "medium",
                    "title": "⚠️ Medium Budget Risk",
                    "description": message,
                    "action": "Consider reducing discretionary spending"
                })
            else:
                insights.append({
                    "type": "budget_success",
                    "severity": "low",
                    "title": "✅ Budget on Track",
                    "description": message,
                    "action": "Keep it up!"
                })
        
        return insights
    
    def _generate_spending_patterns(self, expenses: List[Dict]) -> Dict:
        """Analyze spending patterns."""
        if not expenses:
            return {"status": "no_data"}
        
        # Group by category
        categories = {}
        for expense in expenses:
            category = expense.get('category', 'other')
            amount = expense.get('amount', 0)
            categories[category] = categories.get(category, 0) + amount
        
        # Find top categories and keep the full ordered breakdown
        ordered_categories = sorted(
            categories.items(),
            key=lambda x: x[1],
            reverse=True
        )

        top_categories = ordered_categories[:3]
        
        # Calculate total
        total = sum(categories.values())
        
        patterns = {
            "total_spending": round(total, 2),
            "category_totals": {
                cat: round(amount, 2)
                for cat, amount in ordered_categories
            },
            "category_breakdown": [
                {
                    "category": cat,
                    "amount": round(amount, 2),
                    "percentage": round((amount / total * 100), 1) if total > 0 else 0
                }
                for cat, amount in ordered_categories
            ],
            "top_categories": [
                {
                    "category": cat,
                    "amount": round(amount, 2),
                    "percentage": round((amount / total * 100), 1) if total > 0 else 0
                }
                for cat, amount in top_categories
            ],
            "categories_used": len(categories)
        }
        
        return patterns

    def _generate_category_outlooks(self, predictions: Dict, expenses: List[Dict]) -> List[Dict]:
        """Project how each spending category may behave next month."""
        if not expenses:
            return []

        categories = {}
        for expense in expenses:
            category = expense.get('category', 'other')
            amount = expense.get('amount', 0)
            categories[category] = categories.get(category, 0) + amount

        current_total = sum(categories.values()) or 1
        forecast = predictions.get('forecast', {}) or {}
        forecast_amount = forecast.get('predicted_amount') or current_total
        trend = forecast.get('trend', 'stable')
        trend_multiplier = 1.0
        if trend == 'increasing':
            trend_multiplier = 1.08
        elif trend == 'decreasing':
            trend_multiplier = 0.94

        outlooks = []
        for category, amount in sorted(categories.items(), key=lambda x: x[1], reverse=True):
            share = amount / current_total
            category_growth = 1.0
            if share >= 0.30:
                category_growth = 1.08
            elif share <= 0.10:
                category_growth = 0.94

            projected_next_month = round(amount * trend_multiplier * category_growth, 2)
            delta = round(projected_next_month - amount, 2)

            if delta > amount * 0.05:
                outlook = 'likely_to_increase'
                impact = 'This category may exceed your current pace next month.'
            elif delta < -(amount * 0.05):
                outlook = 'likely_to_decrease'
                impact = 'This category looks like it can stay under control next month.'
            else:
                outlook = 'stable'
                impact = 'This category is expected to stay close to current levels.'

            if category in {'food', 'food & dining'} and trend == 'increasing':
                impact = 'Food is already running hot, so the next month is likely to stay above plan unless you trim dining and groceries.'
                outlook = 'budget_pressure'
            elif category in {'shopping', 'clothes'} and trend == 'decreasing':
                impact = 'Shopping looks disciplined right now, so next month should continue to improve if you keep the same pace.'
            elif category in {'transport', 'transportation'} and trend == 'increasing':
                impact = 'Transport is rising, so fuel, rides, or commuting could push next month higher too.'

            outlooks.append({
                'category': category,
                'current_amount': round(amount, 2),
                'current_share': round(share * 100, 1),
                'projected_next_month': projected_next_month,
                'delta': delta,
                'outlook': outlook,
                'trend_alignment': trend,
                'reason': impact,
                'budget_signal': 'watch' if delta > 0 else 'save' if delta < 0 else 'stable'
            })

        return outlooks

    def _generate_comparison_summary(self, predictions: Dict, expenses: List[Dict], category_outlooks: List[Dict]) -> Dict:
        """Compare current spend, forecast, and category-level outlooks."""
        overrun = predictions.get('overrun_prediction', {}) or {}
        forecast = predictions.get('forecast', {}) or {}
        total_now = round(sum(expense.get('amount', 0) for expense in expenses), 2)
        projected = round(forecast.get('predicted_amount') or total_now, 2)

        riskiest = next((item for item in category_outlooks if item.get('outlook') in {'budget_pressure', 'likely_to_increase'}), None)
        strongest_saver = next((item for item in category_outlooks if item.get('budget_signal') == 'save'), None)

        return {
            'current_total': total_now,
            'projected_total': projected,
            'difference': round(projected - total_now, 2),
            'budget_status': 'over_budget' if overrun.get('will_overrun') else 'on_track',
            'highest_risk_category': riskiest.get('category') if riskiest else None,
            'best_saving_category': strongest_saver.get('category') if strongest_saver else None,
            'message': self._build_comparison_message(overrun, forecast, riskiest, strongest_saver)
        }

    def _build_comparison_message(self, overrun: Dict, forecast: Dict, riskiest: Optional[Dict], strongest_saver: Optional[Dict]) -> str:
        parts = []
        if overrun.get('will_overrun'):
            parts.append('Your current budget is at risk of being exceeded overall.')
        else:
            parts.append('Your current budget is still under control overall.')

        trend = forecast.get('trend', 'stable')
        if trend == 'increasing':
            parts.append('The forecast suggests next month will be higher unless spending changes.')
        elif trend == 'decreasing':
            parts.append('The forecast suggests next month should improve if the same habits continue.')
        else:
            parts.append('The forecast is steady, so the next month should stay close to the current level.')

        if riskiest:
            parts.append(f"{riskiest.get('category', 'A category')} is the biggest pressure point right now.")
        if strongest_saver:
            parts.append(f"{strongest_saver.get('category', 'A category')} is the clearest saving opportunity.")

        return ' '.join(parts)
    
    def _generate_recommendations(self, predictions: Dict, expenses: List[Dict]) -> List[Dict]:
        """Generate personalized recommendations."""
        recommendations = []
        
        # Analyze high spending categories
        categories = {}
        for expense in expenses:
            category = expense.get('category', 'other')
            amount = expense.get('amount', 0)
            categories[category] = categories.get(category, [])
            categories[category].append(amount)
        
        # Find optimization opportunities
        for category, amounts in categories.items():
            if len(amounts) > 2:
                avg = statistics.mean(amounts)
                max_amount = max(amounts)
                
                if max_amount > avg * 2:
                    recommendations.append({
                        "category": category,
                        "type": "spending_spike",
                        "title": f"High {category.title()} Spending Detected",
                        "description": f"Your {category} spending varies significantly",
                        "potential_savings": round(max_amount - avg, 2)
                    })
        
        return recommendations
    
    def _generate_alerts(self, predictions: Dict, expenses: List[Dict]) -> List[Dict]:
        """Generate alerts based on predictions."""
        alerts = []
        
        forecast = predictions.get('forecast', {})
        if forecast:
            if forecast.get('trend') == 'increasing':
                alerts.append({
                    "type": "trend_alert",
                    "severity": "medium",
                    "title": "📈 Increasing Spending Trend",
                    "message": "Your spending is trending upward"
                })
        
        return alerts
    
    def _generate_summary(self, predictions: Dict, expenses: List[Dict]) -> str:
        """Generate executive summary."""
        overrun = predictions.get('overrun_prediction', {})
        forecast = predictions.get('forecast', {})
        
        summary_parts = []
        
        if overrun and not overrun.get('will_overrun'):
            summary_parts.append("✅ Your budget is on track")
        
        if forecast:
            trend = forecast.get('trend', 'stable')
            if trend == 'increasing':
                summary_parts.append("but your spending is increasing")
            elif trend == 'decreasing':
                summary_parts.append("and your spending is decreasing nicely")
        
        if not summary_parts:
            summary_parts.append("Continue monitoring your expenses")
        
        return ". ".join(summary_parts) + "."
