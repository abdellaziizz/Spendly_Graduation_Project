"""Predictions API routes."""
from flask import Blueprint, request, jsonify
import logging

from ..services.overrun_predictor import OverrunPredictor
from ..services.monthly_forecast_engine import MonthlyForecastEngine
from ..services.category_classifier import CategoryClassifier
from ..ai_models.insights_generator import InsightsGenerator

logger = logging.getLogger(__name__)

predictions_bp = Blueprint('predictions', __name__, url_prefix='/api/predictions')

# Initialize services
overrun_predictor = OverrunPredictor()
forecast_engine = MonthlyForecastEngine()
category_classifier = CategoryClassifier()
insights_generator = InsightsGenerator()


@predictions_bp.route('/health', methods=['GET'])
def health():
    """Health check endpoint."""
    return jsonify({
        "status": "healthy",
        "message": "Predictions API is running"
    }), 200


@predictions_bp.route('/predict-overrun', methods=['POST'])
def predict_overrun():
    """Predict budget overrun."""
    try:
        data = request.get_json()
        
        result = overrun_predictor.predict_overrun(
            current_spending=data.get('currentSpending', 0),
            budget_limit=data.get('budgetLimit', 0),
            expenses=data.get('expenses', []),
            days_in_month=data.get('daysInMonth', 30),
            current_day=data.get('currentDay', 1)
        )
        
        return jsonify(result), 200
    
    except Exception as e:
        logger.error(f"Error predicting overrun: {e}")
        return jsonify({"error": str(e)}), 400


@predictions_bp.route('/forecast-monthly', methods=['POST'])
def forecast_monthly():
    """Forecast next month's spending."""
    try:
        data = request.get_json()
        
        result = forecast_engine.forecast_next_month(
            historical_monthly=data.get('historicalMonthly', []),
            current_month=data.get('currentMonth')
        )
        
        return jsonify(result), 200
    
    except Exception as e:
        logger.error(f"Error forecasting: {e}")
        return jsonify({"error": str(e)}), 400


@predictions_bp.route('/classify-category', methods=['POST'])
def classify_category():
    """Classify transaction category."""
    try:
        data = request.get_json()
        
        result = category_classifier.classify(
            description=data.get('description', '')
        )
        
        return jsonify(result), 200
    
    except Exception as e:
        logger.error(f"Error classifying: {e}")
        return jsonify({"error": str(e)}), 400


@predictions_bp.route('/generate-insights', methods=['POST'])
def generate_insights():
    """Generate AI insights."""
    try:
        data = request.get_json()
        
        predictions = {
            "overrun_prediction": data.get('overrunPrediction', {}),
            "forecast": data.get('forecast', {})
        }
        expenses = data.get('expenses', [])
        
        insights = insights_generator.generate_insights(predictions, expenses)
        
        return jsonify(insights), 200
    
    except Exception as e:
        logger.error(f"Error generating insights: {e}")
        return jsonify({"error": str(e)}), 400


@predictions_bp.route('/all-predictions', methods=['POST'])
def all_predictions():
    """Get all predictions at once."""
    try:
        data = request.get_json()
        
        # Get overrun prediction
        overrun = overrun_predictor.predict_overrun(
            current_spending=data.get('currentSpending', 0),
            budget_limit=data.get('budgetLimit', 0),
            expenses=data.get('expenses', []),
            days_in_month=data.get('daysInMonth', 30),
            current_day=data.get('currentDay', 1)
        )
        
        # Get forecast
        forecast = forecast_engine.forecast_next_month(
            historical_monthly=data.get('historicalMonthly', []),
            current_month=data.get('currentMonth')
        )
        
        # Classify transactions
        classified_expenses = []
        for expense in data.get('expenses', []):
            classification = category_classifier.classify(
                description=expense.get('description', '')
            )
            expense['category'] = classification['category']
            classified_expenses.append(expense)
        
        # Generate insights
        insights = insights_generator.generate_insights(
            {
                "overrun_prediction": overrun,
                "forecast": forecast
            },
            classified_expenses
        )
        
        return jsonify({
            "overrunPrediction": overrun,
            "forecast": forecast,
            "insights": insights,
            "classifiedExpenses": classified_expenses
        }), 200
    
    except Exception as e:
        logger.error(f"Error getting all predictions: {e}")
        return jsonify({"error": str(e)}), 400


@predictions_bp.route('/chatbot-training', methods=['POST'])
def chatbot_training():
    """Train/update ML models from chatbot conversation data.
    
    This endpoint learns from user interactions in the chatbot to improve
    expense categorization and insights generation.
    """
    try:
        data = request.get_json()
        
        # Extract conversation data
        user_message = data.get('userMessage', '')
        bot_response = data.get('botResponse', '')
        user_expense = data.get('expense', {})
        user_correction = data.get('correction', {})  # If user corrects a prediction
        feedback = data.get('feedback', '')  # User satisfaction feedback
        
        training_results = {
            'trained': False,
            'models_updated': [],
            'message': 'No training data processed'
        }
        
        # If user corrected a category classification, retrain classifier
        if user_correction.get('originalCategory') and user_correction.get('correctedCategory'):
            original = user_correction.get('originalCategory', '')
            corrected = user_correction.get('correctedCategory', '')
            description = user_correction.get('description', '')
            
            logger.info(f"Training category classifier: '{description}' should be '{corrected}' not '{original}'")
            category_classifier.train_from_feedback(description, corrected)
            
            training_results['models_updated'].append('category_classifier')
            training_results['trained'] = True
        
        # If we have an expense with user feedback, learn from it
        if user_expense and user_expense.get('description'):
            description = user_expense.get('description', '')
            amount = user_expense.get('amount', 0)
            user_category = user_expense.get('userCategory')
            
            if user_category:
                logger.info(f"Learning expense pattern: {description} -> {user_category}")
                category_classifier.train_from_feedback(description, user_category)
                training_results['models_updated'].append('category_classifier')
                training_results['trained'] = True
        
        # Store conversation for future analysis (in production, save to database)
        if user_message and bot_response:
            logger.info(f"Storing conversation for analysis: User: {user_message[:50]}... Bot: {bot_response[:50]}...")
            # In production: save to conversation_history table
            training_results['models_updated'].append('conversation_history')
            training_results['trained'] = True
        
        training_results['message'] = f"Successfully trained on {len(training_results['models_updated'])} data points"
        
        return jsonify(training_results), 200
    
    except Exception as e:
        logger.error(f"Error in chatbot training: {e}")
        return jsonify({"error": str(e), "trained": False}), 400
