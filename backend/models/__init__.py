"""Data models for predictions."""
from dataclasses import dataclass
from typing import List, Optional, Dict, Any


@dataclass
class TransactionData:
    """Transaction data."""
    description: str
    amount: float
    date: str
    category: Optional[str] = None


@dataclass
class PredictionResult:
    """Generic prediction result."""
    success: bool
    data: Dict[str, Any]
    error: Optional[str] = None
    confidence: float = 0.0


@dataclass
class OverrunPrediction:
    """Budget overrun prediction."""
    will_overrun: bool
    confidence: float
    projected_spending: float
    risk_level: str  # 'low', 'medium', 'high'
    days_left: int
    message: str


@dataclass
class ForecastResult:
    """Monthly spending forecast."""
    predicted_amount: float
    confidence: float
    trend: str  # 'increasing', 'decreasing', 'stable'
    trend_description: str


@dataclass
class CategoryPrediction:
    """Category classification result."""
    category: str
    confidence: float
    alternatives: List[Dict[str, float]]


@dataclass
class InsightCard:
    """AI insight card."""
    title: str
    description: str
    type: str  # 'budget', 'forecast', 'category', 'savings'
    icon: str
    priority: str  # 'high', 'medium', 'low'
    action: Optional[str] = None
