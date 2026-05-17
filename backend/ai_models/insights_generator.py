"""
AI Insights Generator
Uses machine learning and statistical analysis for spending insights
"""
from typing import List, Dict, Tuple
from datetime import datetime
from backend.models import InsightData, ExpenseData, SmartTip, TipPriority
import logging

logger = logging.getLogger(__name__)

try:
    from backend.ml_models import get_model_manager
    ML_AVAILABLE = True
except ImportError:
    ML_AVAILABLE = False
    logger.warning("ML models not available for insights generation")


class AIInsightsGenerator:
    """
    AI-powered insights generator for spending analysis and recommendations.
    Uses statistical analysis and pattern recognition.
    """
    
    @staticmethod
    def generate_insights(
        user_id: str,
        expenses: List[ExpenseData],
        budget_limits: Dict[str, float],
        current_spending: Dict[str, float],
        historical_monthly: List[float],
        overrun_prediction=None,
        monthly_forecast=None
    ) -> List[InsightData]:
        """
        Generate AI insights about user's spending patterns.
        
        Args:
            user_id: User ID
            expenses: List of recent expenses
            budget_limits: Dictionary of budget limits by category
            current_spending: Dictionary of current spending by category
            historical_monthly: Historical monthly spending data
            overrun_prediction: Budget overrun prediction
            monthly_forecast: Monthly forecast prediction
            
        Returns:
            List of InsightData objects with AI-generated insights
        """
        
        insights = []
        
        # 1. Category spending patterns
        category_insights = AIInsightsGenerator._analyze_category_patterns(
            expenses, budget_limits, current_spending
        )
        insights.extend(category_insights)
        
        # 2. Spending trends
        trend_insights = AIInsightsGenerator._analyze_spending_trends(historical_monthly)
        insights.extend(trend_insights)
        
        # 3. Anomaly detection
        anomaly_insights = AIInsightsGenerator._detect_anomalies(expenses)
        insights.extend(anomaly_insights)
        
        # 4. Savings opportunities
        savings_insights = AIInsightsGenerator._identify_savings_opportunities(
            expenses, current_spending, budget_limits
        )
        insights.extend(savings_insights)
        
        # 5. Prediction-based insights
        if overrun_prediction or monthly_forecast:
            prediction_insights = AIInsightsGenerator._generate_prediction_insights(
                overrun_prediction, monthly_forecast
            )
            insights.extend(prediction_insights)
        
        # Sort by confidence (highest first)
        insights.sort(key=lambda x: x.confidence, reverse=True)
        
        # Limit to top 10 insights
        return insights[:10]
    
    @staticmethod
    def _analyze_category_patterns(
        expenses: List[ExpenseData],
        budget_limits: Dict[str, float],
        current_spending: Dict[str, float]
    ) -> List[InsightData]:
        """Analyze spending patterns by category"""
        
        insights = []
        
        # Group expenses by category
        category_expenses = {}
        category_frequency = {}
        
        for expense in expenses:
            cat = expense.category.lower()
            category_expenses[cat] = category_expenses.get(cat, 0.0) + expense.amount
            category_frequency[cat] = category_frequency.get(cat, 0) + 1
        
        # Analyze each category
        for category, amount in current_spending.items():
            budget = budget_limits.get(category, 0)
            
            if budget > 0:
                usage_percentage = (amount / budget) * 100
                frequency = category_frequency.get(category, 0)
                
                # High usage alert
                if usage_percentage >= 90:
                    insights.append(InsightData(
                        title=f'⚠️ {category.capitalize()} Budget Alert',
                        description=f'You\'ve used {usage_percentage:.1f}% of your {category} budget.',
                        insights=[
                            f'Current spending: ${amount:.2f} of ${budget:.2f}',
                            f'Frequency: {frequency} transactions',
                            f'Average per transaction: ${amount/frequency:.2f}' if frequency > 0 else ''
                        ],
                        recommendations=[
                            f'Review and reduce {category} expenses',
                            'Look for discounts or alternatives',
                            'Set daily spending limits for this category'
                        ],
                        confidence=0.9,
                        category='risk_alert',
                        generated_at=datetime.now()
                    ))
                
                # Good tracking insight
                elif 30 <= usage_percentage < 70:
                    insights.append(InsightData(
                        title=f'✓ {category.capitalize()} on Track',
                        description=f'Your {category} spending is well-controlled.',
                        insights=[
                            f'Using {usage_percentage:.1f}% of budget',
                            f'Average transaction: ${amount/frequency:.2f}' if frequency > 0 else '',
                            'Maintaining good spending habits'
                        ],
                        recommendations=[
                            'Keep up the good spending habits',
                            'Monitor for any sudden increases'
                        ],
                        confidence=0.85,
                        category='positive_trend',
                        generated_at=datetime.now()
                    ))
        
        return insights
    
    @staticmethod
    def _analyze_spending_trends(historical_monthly: List[float]) -> List[InsightData]:
        """Analyze spending trends over time"""
        
        insights = []
        
        if len(historical_monthly) < 2:
            return insights
        
        # Calculate trend
        recent_avg = sum(historical_monthly[-3:]) / 3 if len(historical_monthly) >= 3 else historical_monthly[-1]
        older_avg = sum(historical_monthly[:-3]) / (len(historical_monthly) - 3) if len(historical_monthly) > 3 else historical_monthly[0]
        
        if older_avg > 0:
            trend_percentage = ((recent_avg - older_avg) / older_avg) * 100
        else:
            trend_percentage = 0
        
        if trend_percentage > 20:
            insights.append(InsightData(
                title='📈 Spending Increasing',
                description='Your spending is trending upward.',
                insights=[
                    f'Increased by {trend_percentage:.1f}% compared to previous months',
                    f'Recent average: ${recent_avg:.2f}',
                    'Rate of increase is significant'
                ],
                recommendations=[
                    'Review recurring expenses',
                    'Identify new spending habits',
                    'Consider adjusting budgets or cutting expenses'
                ],
                confidence=0.88,
                category='spending_pattern',
                generated_at=datetime.now()
            ))
        elif trend_percentage < -20:
            insights.append(InsightData(
                title='📉 Great Progress!',
                description='Your spending is decreasing.',
                insights=[
                    f'Decreased by {abs(trend_percentage):.1f}%',
                    f'Recent average: ${recent_avg:.2f}',
                    'Excellent cost management'
                ],
                recommendations=[
                    'Continue your cost-saving strategies',
                    'Consider saving the extra money',
                    'Review what\'s working for you'
                ],
                confidence=0.88,
                category='positive_trend',
                generated_at=datetime.now()
            ))
        
        return insights
    
    @staticmethod
    def _detect_anomalies(expenses: List[ExpenseData]) -> List[InsightData]:
        """Detect unusual spending patterns"""
        
        insights = []
        
        if not expenses:
            return insights
        
        # Calculate average transaction amount
        amounts = [exp.amount for exp in expenses]
        avg_amount = sum(amounts) / len(amounts) if amounts else 0
        std_dev = (sum((x - avg_amount) ** 2 for x in amounts) / len(amounts)) ** 0.5 if len(amounts) > 1 else 0
        
        # Find outliers (transactions > 2 std dev from mean)
        outliers = [exp for exp in expenses if exp.amount > avg_amount + (2 * std_dev)]
        
        if outliers:
            high_value_total = sum(exp.amount for exp in outliers)
            high_value_percentage = (high_value_total / sum(amounts)) * 100 if amounts else 0
            
            insights.append(InsightData(
                title='🔍 Unusual Transactions Detected',
                description='Some unusually high transactions were found.',
                insights=[
                    f'Found {len(outliers)} high-value transactions',
                    f'These account for {high_value_percentage:.1f}% of total spending',
                    f'Average: ${avg_amount:.2f}, Outlier threshold: ${avg_amount + (2 * std_dev):.2f}'
                ],
                recommendations=[
                    'Review these transactions for validity',
                    'Verify if these are one-time or recurring expenses',
                    'Budget accordingly for similar expenses'
                ],
                confidence=0.82,
                category='spending_pattern',
                generated_at=datetime.now()
            ))
        
        return insights
    
    @staticmethod
    def _identify_savings_opportunities(
        expenses: List[ExpenseData],
        current_spending: Dict[str, float],
        budget_limits: Dict[str, float]
    ) -> List[InsightData]:
        """Identify potential savings opportunities"""
        
        insights = []
        
        # Group expenses by category and find high-frequency, low-value categories
        category_data = {}
        
        for expense in expenses:
            cat = expense.category.lower()
            if cat not in category_data:
                category_data[cat] = {'count': 0, 'total': 0.0}
            category_data[cat]['count'] += 1
            category_data[cat]['total'] += expense.amount
        
        # Find high-frequency small purchases
        for category, data in category_data.items():
            if data['count'] >= 5:  # At least 5 transactions
                avg_per_transaction = data['total'] / data['count']
                
                if 5 <= avg_per_transaction <= 30:  # Typical small purchases
                    monthly_savings = avg_per_transaction * 0.2 * 30  # 20% reduction projected to full month
                    
                    insights.append(InsightData(
                        title=f'💰 Savings Opportunity: {category.capitalize()}',
                        description=f'Potential to save on {category} purchases.',
                        insights=[
                            f'You have {data["count"]} {category} transactions',
                            f'Average: ${avg_per_transaction:.2f} per transaction',
                            f'Potential monthly savings: ${monthly_savings:.2f}'
                        ],
                        recommendations=[
                            f'Try reducing {category} frequency by 20%',
                            'Look for bulk or discounted options',
                            'Set up alerts for deals in this category'
                        ],
                        confidence=0.75,
                        category='savings_opportunity',
                        generated_at=datetime.now()
                    ))
        
        return insights
    
    @staticmethod
    def _generate_prediction_insights(overrun_prediction, monthly_forecast) -> List[InsightData]:
        """Generate insights based on predictions"""
        
        insights = []
        
        # Overrun prediction insights
        if overrun_prediction and overrun_prediction.will_overrun:
            insights.append(InsightData(
                title='⚡ Budget Overrun Warning',
                description='AI predicts you may exceed your budget.',
                insights=[
                    f'Projected spending: ${overrun_prediction.projected_spending:.2f}',
                    f'Budget limit: ${overrun_prediction.budget_limit:.2f}',
                    f'Potential overrun: ${max(0, overrun_prediction.projected_spending - overrun_prediction.budget_limit):.2f}',
                    f'Days remaining: {overrun_prediction.days_remaining}',
                    f'Confidence: {overrun_prediction.confidence*100:.0f}%'
                ],
                recommendations=[
                    'Reduce discretionary spending immediately',
                    'Review upcoming expenses',
                    'Adjust budget limits if needed',
                    f'Allow ~${(overrun_prediction.budget_limit - (overrun_prediction.projected_spending - overrun_prediction.days_remaining*50))/overrun_prediction.days_remaining:.2f} per day to stay on track'
                ],
                confidence=overrun_prediction.confidence,
                category='risk_alert',
                generated_at=datetime.now()
            ))
        
        # Monthly forecast insights
        if monthly_forecast:
            insights.append(InsightData(
                title='🔮 Next Month Forecast',
                description=monthly_forecast.trend_description,
                insights=[
                    f'Predicted next month spending: ${monthly_forecast.predicted_amount:.2f}',
                    f'Trend: {monthly_forecast.trend_description}',
                    f'Confidence: {monthly_forecast.confidence*100:.0f}%',
                    f'Trend rate: {monthly_forecast.trend:.2f}/month'
                ],
                recommendations=[
                    'Prepare your budget accordingly',
                    'Monitor spending closely',
                    'Adjust savings goals if needed'
                ],
                confidence=monthly_forecast.confidence,
                category='spending_pattern',
                generated_at=datetime.now()
            ))
        
        return insights
    
    @staticmethod
    def generate_smart_tips(
        budgets,
        predictions,
        insights: List[InsightData]
    ) -> List[SmartTip]:
        """Generate smart tips for UI display"""
        
        tips = []
        
        # Convert insights to tips
        for insight in insights:
            priority = TipPriority.HIGH if insight.confidence >= 0.85 else TipPriority.MEDIUM if insight.confidence >= 0.7 else TipPriority.LOW
            
            icon_type = 'warning' if insight.category == 'risk_alert' else \
                       'success' if insight.category == 'positive_trend' else \
                       'trending_up' if 'increasing' in insight.title.lower() else \
                       'trending_down' if 'decreasing' in insight.title.lower() else 'info'
            
            tips.append(SmartTip(
                title=insight.title,
                description=insight.description,
                recommendation=insight.recommendations[0] if insight.recommendations else '',
                priority=priority,
                icon_type=icon_type
            ))
        
        # Sort by priority (high > medium > low)
        priority_order = {TipPriority.HIGH: 0, TipPriority.MEDIUM: 1, TipPriority.LOW: 2}
        tips.sort(key=lambda x: priority_order.get(x.priority, 3))
        
        return tips
