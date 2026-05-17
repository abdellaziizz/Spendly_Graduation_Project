"""
API routes for predictions, insights and reports
"""
from flask import Blueprint, request, jsonify
from datetime import datetime
from typing import List, Dict
from backend.services import OverrunPredictor, MonthlyForecastEngine, CategoryClassifier
from backend.ai_models import AIInsightsGenerator
from backend.models import (
    ExpenseData, 
    Report,
    SmartTip,
    RiskLevel,
    TipPriority
)
import traceback
import logging

logger = logging.getLogger(__name__)

predictions_bp = Blueprint('predictions', __name__, url_prefix='/api/predictions')


@predictions_bp.route('/predict-overrun', methods=['POST'])
def predict_overrun():
    """
    Predict if budget will be exceeded.
    
    Expected JSON:
    {
        "currentSpending": float,
        "budgetLimit": float,
        "expenses": [{date, amount, category, description}, ...],
        "daysInMonth": int,
        "currentDay": int
    }
    """
    try:
        data = request.get_json()
        logger.info(f"predict_overrun called with payload keys: {list(data.keys()) if isinstance(data, dict) else 'invalid_json'}")
        print(f"[DEBUG] predict_overrun payload keys: {list(data.keys()) if isinstance(data, dict) else 'invalid_json'}")
        
        # Convert expense dicts to ExpenseData objects
        expenses = [
            ExpenseData(
                date=datetime.fromisoformat(exp['date']),
                amount=exp['amount'],
                category=exp['category'],
                description=exp['description']
            )
            for exp in data.get('expenses', [])
        ]
        
        prediction = OverrunPredictor.predict_overrun(
            current_spending=data['currentSpending'],
            budget_limit=data['budgetLimit'],
            daily_expenses=expenses,
            days_in_month=data['daysInMonth'],
            current_day=data['currentDay']
        )
        # Debug information about prediction object
        try:
            logger.info(f'Prediction repr: {repr(prediction)}')
            logger.info(f'Prediction attrs: {prediction.__dict__}')
            logger.info(f'Risk level type: {type(prediction.risk_level)} value: {prediction.risk_level}')
            print(f"[DEBUG] prediction repr: {repr(prediction)}")
            print(f"[DEBUG] prediction attrs: {getattr(prediction, '__dict__', {})}")
            print(f"[DEBUG] risk level type: {type(prediction.risk_level)} value: {prediction.risk_level}")
        except Exception as _:
            logger.exception('Error while logging prediction details')
            print('[DEBUG] exception while logging prediction details')
        # Ensure risk_level is an instance of RiskLevel enum
        try:
            if isinstance(prediction.risk_level, str):
                prediction.risk_level = RiskLevel(prediction.risk_level)
        except Exception:
            pass
        logger.info(f'predict_overrun: risk_level type={type(prediction.risk_level)} value={prediction.risk_level}')
        
        # Defensive: build a safe dict to avoid enum/string attribute errors
        try:
            def _safe_value(obj):
                try:
                    return obj.value
                except Exception:
                    try:
                        return str(obj)
                    except Exception:
                        return None

            pred_dict = {
                'willOverrun': getattr(prediction, 'will_overrun', False),
                'confidence': getattr(prediction, 'confidence', 0.0),
                'projectedSpending': getattr(prediction, 'projected_spending', 0.0),
                'budgetLimit': getattr(prediction, 'budget_limit', None),
                'daysRemaining': getattr(prediction, 'days_remaining', None),
                'riskLevel': _safe_value(getattr(prediction, 'risk_level', None)),
                'message': getattr(prediction, 'message', '')
            }
        except Exception:
            pred_dict = {'willOverrun': getattr(prediction, 'will_overrun', False)}

        return jsonify(pred_dict)
    
    except Exception as e:
        tb = traceback.format_exc()
        traceback.print_exc()
        logger.error(f'predict_overrun error: {e}\n{tb}')
        # Include traceback in response for debugging (remove in production)
        return jsonify({'error': str(e), 'trace': tb}), 400


@predictions_bp.route('/predict-overrun', methods=['GET'])
def predict_overrun_get():
    """Simple GET test endpoint returning sample prediction JSON"""
    sample = {
        'willOverrun': False,
        'confidence': 0.6,
        'projectedSpending': 800.0,
        'budgetLimit': 1000.0,
        'daysRemaining': 15,
        'riskLevel': 'low',
        'message': 'Sample prediction response'
    }
    return jsonify(sample)


@predictions_bp.route('/predict-overrun-safe', methods=['POST'])
def predict_overrun_safe():
    """Safe prediction endpoint that builds JSON manually to avoid encoder issues."""
    try:
        data = request.get_json() or {}

        # Basic input extraction with defaults
        current_spending = float(data.get('currentSpending', 0))
        budget_limit = float(data.get('budgetLimit', 0))
        days_in_month = int(data.get('daysInMonth', 30))
        current_day = int(data.get('currentDay', 1))

        # Convert expenses defensively
        expenses = []
        for exp in data.get('expenses', []) or []:
            try:
                expenses.append(ExpenseData(
                    date=datetime.fromisoformat(exp.get('date')) if exp.get('date') else datetime.now(),
                    amount=float(exp.get('amount', 0)),
                    category=exp.get('category', ''),
                    description=exp.get('description', '')
                ))
            except Exception:
                continue

        prediction = OverrunPredictor.predict_overrun(
            current_spending=current_spending,
            budget_limit=budget_limit,
            daily_expenses=expenses,
            days_in_month=days_in_month,
            current_day=current_day
        )

        # Build plain JSON-serializable dict
        resp = {
            'willOverrun': bool(getattr(prediction, 'will_overrun', False)),
            'confidence': float(getattr(prediction, 'confidence', 0.0)),
            'projectedSpending': float(getattr(prediction, 'projected_spending', 0.0)),
            'budgetLimit': float(getattr(prediction, 'budget_limit', 0.0)) if getattr(prediction, 'budget_limit', None) is not None else None,
            'daysRemaining': int(getattr(prediction, 'days_remaining', 0)),
            'riskLevel': (getattr(prediction, 'risk_level').value
                          if hasattr(getattr(prediction, 'risk_level', None), 'value')
                          else str(getattr(prediction, 'risk_level', ''))),
            'message': str(getattr(prediction, 'message', ''))
        }

        # Return with manual JSON serialization to avoid framework encoders
        from flask import make_response
        import json as _json
        body = _json.dumps(resp, ensure_ascii=False)
        r = make_response(body, 200)
        r.headers['Content-Type'] = 'application/json; charset=utf-8'
        return r

    except Exception as e:
        import traceback as _tb
        tb = _tb.format_exc()
        return jsonify({'error': str(e), 'trace': tb}), 400


@predictions_bp.route('/forecast-monthly', methods=['POST'])
def forecast_monthly():
    """
    Forecast next month's spending.
    
    Expected JSON:
    {
        "historicalMonthlyExpenses": [float, ...]  // List of monthly totals
    }
    """
    try:
        data = request.get_json()
        
        forecast = MonthlyForecastEngine.predict_next_month(
            monthly_expenses=data.get('historicalMonthlyExpenses', [])
        )
        
        return jsonify(forecast.to_dict())
    
    except Exception as e:
        return jsonify({'error': str(e)}), 400


@predictions_bp.route('/classify-category', methods=['POST'])
def classify_category():
    """
    Classify transaction to a category.
    
    Expected JSON:
    {
        "description": str
    }
    """
    try:
        data = request.get_json()
        
        prediction = CategoryClassifier.predict_category(
            description=data.get('description', '')
        )
        
        return jsonify(prediction.to_dict())
    
    except Exception as e:
        return jsonify({'error': str(e)}), 400


@predictions_bp.route('/generate-report', methods=['POST'])
def generate_report():
    """
    Generate comprehensive insights and report.
    
    Expected JSON:
    {
        "userId": str,
        "expenses": [{date, amount, category, description}, ...],
        "budgets": {category: limit, ...},
        "currentSpending": {category: amount, ...},
        "historicalMonthly": [float, ...],
        "daysInMonth": int,
        "currentDay": int
    }
    """
    try:
        data = request.get_json()
        
        # Convert expense dicts to ExpenseData objects
        expenses = [
            ExpenseData(
                date=datetime.fromisoformat(exp['date']),
                amount=exp['amount'],
                category=exp['category'],
                description=exp['description']
            )
            for exp in data.get('expenses', [])
        ]
        
        # Generate predictions
        overrun_pred = OverrunPredictor.predict_overrun(
            current_spending=sum(data.get('currentSpending', {}).values()),
            budget_limit=sum(data.get('budgets', {}).values()),
            daily_expenses=expenses,
            days_in_month=data.get('daysInMonth', 30),
            current_day=data.get('currentDay', 15)
        )
        
        forecast = MonthlyForecastEngine.predict_next_month(
            monthly_expenses=data.get('historicalMonthly', [])
        )
        
        # Generate AI insights
        insights = AIInsightsGenerator.generate_insights(
            user_id=data.get('userId', ''),
            expenses=expenses,
            budget_limits=data.get('budgets', {}),
            current_spending=data.get('currentSpending', {}),
            historical_monthly=data.get('historicalMonthly', []),
            overrun_prediction=overrun_pred,
            monthly_forecast=forecast
        )
        
        # Generate smart tips
        budgets = [{'category': cat, 'limit': limit} for cat, limit in data.get('budgets', {}).items()]
        smart_tips = AIInsightsGenerator.generate_smart_tips(budgets, None, insights)
        
        # Calculate overall progress
        total_spent = sum(data.get('currentSpending', {}).values())
        total_budget = sum(data.get('budgets', {}).values())
        overall_progress = (total_spent / total_budget) if total_budget > 0 else 0
        
        # Create report
        now = datetime.now()
        report = Report(
            user_id=data.get('userId', ''),
            period_start=datetime(now.year, now.month, 1),
            period_end=now,
            total_spending=total_spent,
            total_budget=total_budget,
            overall_progress=overall_progress,
            overrun_prediction=overrun_pred,
            monthly_forecast=forecast,
            smart_tips=smart_tips,
            insights=insights,
            category_breakdown=data.get('currentSpending', {})
        )
        
        return jsonify(report.to_dict())
    
    except Exception as e:
        import traceback
        traceback.print_exc()
        return jsonify({'error': str(e)}), 400


@predictions_bp.route('/generate-smart-tips', methods=['POST'])
def generate_smart_tips():
    """
    Generate smart tips based on budget data.
    
    Expected JSON:
    {
        "budgets": [{title, spentAmount, limitAmount}, ...],
        "predictions": {overrunPrediction, monthlyForecast}
    }
    """
    try:
        data = request.get_json()
        budgets = data.get('budgets', [])
        predictions = data.get('predictions', {})
        
        tips: List[SmartTip] = []
        
        # Analyze each budget
        for budget in budgets:
            if budget.get('limitAmount', 0) > 0:
                percent_used = (budget.get('spentAmount', 0) / budget.get('limitAmount', 1)) * 100
                
                if percent_used >= 90:
                    tips.append({
                        'title': f"{budget.get('title')} Budget Alert",
                        'description': f"You've used {percent_used:.0f}% of your {budget.get('title')} budget",
                        'recommendation': f"Consider reducing {budget.get('title').lower()} expenses",
                        'priority': 'high',
                        'iconType': 'warning'
                    })
                elif percent_used >= 75:
                    tips.append({
                        'title': f"{budget.get('title')} Tracking Well",
                        'description': f"You've used {percent_used:.0f}% of your {budget.get('title')} budget",
                        'recommendation': 'You\'re on track! Monitor spending to stay within budget.',
                        'priority': 'medium',
                        'iconType': 'info'
                    })
                elif percent_used < 50 and budget.get('spentAmount', 0) > 0:
                    tips.append({
                        'title': f"{budget.get('title')} Under Control",
                        'description': f"Great! Only {percent_used:.0f}% used.",
                        'recommendation': 'Keep up the good spending habits!',
                        'priority': 'low',
                        'iconType': 'success'
                    })
        
        # Add prediction tips
        overrun_pred = predictions.get('overrunPrediction')
        if overrun_pred and overrun_pred.get('willOverrun') and overrun_pred.get('riskLevel') == 'high':
            tips.append({
                'title': 'AI Prediction: Budget Risk',
                'description': 'Based on your spending patterns, you may exceed your budget before month-end.',
                'recommendation': 'Review the Insights tab for detailed predictions.',
                'priority': 'high',
                'iconType': 'ai'
            })
        
        monthly_forecast = predictions.get('monthlyForecast')
        if monthly_forecast and monthly_forecast.get('trend', 0) > 50:
            tips.append({
                'title': 'Spending Trend Increasing',
                'description': f"Your spending is trending upward. {monthly_forecast.get('trendDescription')}",
                'recommendation': 'Review recurring expenses and identify areas to cut back.',
                'priority': 'medium',
                'iconType': 'trending_up'
            })
        
        return jsonify({'smartTips': tips})
    
    except Exception as e:
        return jsonify({'error': str(e)}), 400


@predictions_bp.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({'status': 'healthy'})
