"""
Prediction and Insight Data Models
"""
from dataclasses import dataclass
from datetime import datetime
from typing import List, Optional
from enum import Enum


class RiskLevel(str, Enum):
    """Risk level enumeration"""
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"


class TipPriority(str, Enum):
    """Tip priority enumeration"""
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"


@dataclass
class ExpenseData:
    """Model for expense data used in predictions"""
    date: datetime
    amount: float
    category: str
    description: str
    
    def to_dict(self):
        return {
            'date': self.date.isoformat(),
            'amount': self.amount,
            'category': self.category,
            'description': self.description
        }


@dataclass
class OverrunPrediction:
    """Result of budget overrun prediction"""
    will_overrun: bool
    confidence: float
    projected_spending: float
    budget_limit: float
    days_remaining: int
    risk_level: RiskLevel
    message: str
    
    def to_dict(self):
        return {
            'willOverrun': self.will_overrun,
            'confidence': self.confidence,
            'projectedSpending': self.projected_spending,
            'budgetLimit': self.budget_limit,
            'daysRemaining': self.days_remaining,
            'riskLevel': self.risk_level.value if hasattr(self.risk_level, 'value') else str(self.risk_level),
            'message': self.message
        }


@dataclass
class MonthlyForecast:
    """Result of monthly forecast prediction"""
    predicted_amount: float
    confidence: float
    historical_data: List[float]
    trend: float  # positive = increasing, negative = decreasing
    trend_description: str
    
    def to_dict(self):
        return {
            'predictedAmount': self.predicted_amount,
            'confidence': self.confidence,
            'historicalData': self.historical_data,
            'trend': self.trend,
            'trendDescription': self.trend_description
        }


@dataclass
class CategoryMatch:
    """Individual category match with confidence score"""
    category: str
    score: float
    
    def to_dict(self):
        return {
            'category': self.category,
            'score': self.score
        }


@dataclass
class CategoryPrediction:
    """Result of category classification"""
    category: str
    confidence: float
    alternative_matches: List[CategoryMatch]
    
    def to_dict(self):
        return {
            'category': self.category,
            'confidence': self.confidence,
            'alternativeMatches': [m.to_dict() for m in self.alternative_matches]
        }


@dataclass
class SmartTip:
    """Smart recommendation tip"""
    title: str
    description: str
    recommendation: str
    priority: TipPriority
    icon_type: str  # 'warning', 'info', 'success', 'ai', 'trending_up', 'trending_down'
    
    def to_dict(self):
        return {
            'title': self.title,
            'description': self.description,
            'recommendation': self.recommendation,
            'priority': self.priority.value if hasattr(self.priority, 'value') else str(self.priority),
            'iconType': self.icon_type
        }


@dataclass
class InsightData:
    """AI-generated insight about spending patterns"""
    title: str
    description: str
    insights: List[str]
    recommendations: List[str]
    confidence: float
    category: str  # 'spending_pattern', 'savings_opportunity', 'risk_alert', 'positive_trend'
    generated_at: datetime
    
    def to_dict(self):
        return {
            'title': self.title,
            'description': self.description,
            'insights': self.insights,
            'recommendations': self.recommendations,
            'confidence': self.confidence,
            'category': self.category,
            'generatedAt': self.generated_at.isoformat()
        }


@dataclass
class Report:
    """Complete report with all insights and predictions"""
    user_id: str
    period_start: datetime
    period_end: datetime
    total_spending: float
    total_budget: float
    overall_progress: float
    overrun_prediction: Optional[OverrunPrediction]
    monthly_forecast: Optional[MonthlyForecast]
    smart_tips: List[SmartTip]
    insights: List[InsightData]
    category_breakdown: dict  # {category: amount}
    
    def to_dict(self):
        return {
            'userId': self.user_id,
            'periodStart': self.period_start.isoformat(),
            'periodEnd': self.period_end.isoformat(),
            'totalSpending': self.total_spending,
            'totalBudget': self.total_budget,
            'overallProgress': self.overall_progress,
            'overrunPrediction': self.overrun_prediction.to_dict() if self.overrun_prediction else None,
            'monthlyForecast': self.monthly_forecast.to_dict() if self.monthly_forecast else None,
            'smartTips': [tip.to_dict() for tip in self.smart_tips],
            'insights': [insight.to_dict() for insight in self.insights],
            'categoryBreakdown': self.category_breakdown
        }
