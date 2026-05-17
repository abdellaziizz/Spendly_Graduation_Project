# Spendly Backend - AI-Powered Insights & Predictions Engine

## Overview

The Spendly Backend is a Python-based REST API that provides AI-powered financial insights and predictions for expense tracking. It integrates with the Flutter Spendly app to deliver intelligent budget analysis, spending pattern recognition, and actionable recommendations.

## Architecture

### Core Components

1. **Prediction Services** (`backend/services/`)
   - `overrun_predictor.py` - Predicts budget overruns with confidence scoring
   - `monthly_forecast_engine.py` - Forecasts next month's spending using linear regression
   - `category_classifier.py` - Classifies transactions using fuzzy matching and NLP

2. **AI Models** (`backend/ai_models/`)
   - `insights_generator.py` - Generates AI-powered insights from spending patterns
   - Uses machine learning for anomaly detection, trend analysis, and recommendations

3. **Data Models** (`backend/models/`)
   - Pydantic models for type-safe data handling
   - Enums for risk levels and priorities
   - Serialization to JSON for API responses

4. **API Routes** (`backend/routes/`)
   - `/api/predictions/predict-overrun` - Budget overrun predictions
   - `/api/predictions/forecast-monthly` - Monthly expense forecasts
   - `/api/predictions/classify-category` - Transaction categorization
   - `/api/predictions/generate-report` - Comprehensive reports with insights
   - `/api/predictions/generate-smart-tips` - Smart recommendations

## Installation

### Prerequisites
- Python 3.9+
- pip

### Setup

```bash
# Navigate to backend directory
cd backend

# Create virtual environment (recommended)
python -m venv venv

# Activate virtual environment
# On Windows:
venv\Scripts\activate
# On macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

## Running the Server

### Development

```bash
python app.py
```

Server runs on `http://localhost:5000`

### Production

```bash
gunicorn -w 4 -b 0.0.0.0:5000 app:create_app
```

## API Endpoints

### 1. Budget Overrun Prediction

**Endpoint:** `POST /api/predictions/predict-overrun`

**Request:**
```json
{
    "currentSpending": 2500.00,
    "budgetLimit": 3000.00,
    "expenses": [
        {
            "date": "2026-05-01T10:30:00",
            "amount": 50.00,
            "category": "food",
            "description": "Lunch at cafe"
        }
    ],
    "daysInMonth": 30,
    "currentDay": 15
}
```

**Response:**
```json
{
    "willOverrun": false,
    "confidence": 0.87,
    "projectedSpending": 2850.00,
    "budgetLimit": 3000.00,
    "daysRemaining": 15,
    "riskLevel": "low",
    "message": "Looking good! You're on track to stay within budget"
}
```

### 2. Monthly Forecast

**Endpoint:** `POST /api/predictions/forecast-monthly`

**Request:**
```json
{
    "historicalMonthlyExpenses": [2000, 2200, 2150, 2300, 2400, 2350]
}
```

**Response:**
```json
{
    "predictedAmount": 2420.50,
    "confidence": 0.82,
    "historicalData": [2000, 2200, 2150, 2300, 2400, 2350],
    "trend": 45.50,
    "trendDescription": "Your spending is gradually increasing"
}
```

### 3. Category Classification

**Endpoint:** `POST /api/predictions/classify-category`

**Request:**
```json
{
    "description": "Starbucks Coffee"
}
```

**Response:**
```json
{
    "category": "food",
    "confidence": 0.98,
    "alternativeMatches": [
        {
            "category": "entertainment",
            "score": 0.25
        }
    ]
}
```

### 4. Generate Comprehensive Report

**Endpoint:** `POST /api/predictions/generate-report`

**Request:**
```json
{
    "userId": "user123",
    "expenses": [...],
    "budgets": {
        "food": 500,
        "transport": 300,
        "entertainment": 200
    },
    "currentSpending": {
        "food": 450,
        "transport": 250,
        "entertainment": 150
    },
    "historicalMonthly": [2000, 2100, 2150],
    "daysInMonth": 30,
    "currentDay": 15
}
```

**Response:**
```json
{
    "userId": "user123",
    "periodStart": "2026-05-01T00:00:00",
    "periodEnd": "2026-05-15T10:30:00",
    "totalSpending": 850.00,
    "totalBudget": 1000.00,
    "overallProgress": 0.85,
    "overrunPrediction": {...},
    "monthlyForecast": {...},
    "smartTips": [...],
    "insights": [...],
    "categoryBreakdown": {...}
}
```

### 5. Generate Smart Tips

**Endpoint:** `POST /api/predictions/generate-smart-tips`

**Request:**
```json
{
    "budgets": [
        {
            "title": "Food",
            "spentAmount": 450,
            "limitAmount": 500
        }
    ],
    "predictions": {
        "overrunPrediction": {...},
        "monthlyForecast": {...}
    }
}
```

**Response:**
```json
{
    "smartTips": [
        {
            "title": "Food Tracking Well",
            "description": "You've used 90% of your Food budget",
            "recommendation": "You're on track! Monitor spending to stay within budget.",
            "priority": "medium",
            "iconType": "info"
        }
    ]
}
```

## AI Insights Features

### 1. Category Spending Analysis
- Analyzes spending patterns by category
- Identifies budget alerts and warnings
- Tracks transaction frequency and averages

### 2. Spending Trends
- Detects increasing/decreasing spending trends
- Calculates month-over-month changes
- Provides trend descriptions

### 3. Anomaly Detection
- Identifies unusual high-value transactions
- Calculates outlier thresholds
- Flags suspicious spending patterns

### 4. Savings Opportunities
- Identifies high-frequency small purchases
- Calculates potential monthly savings
- Suggests reduction targets

### 5. Prediction-Based Insights
- Budget overrun warnings
- Monthly spending forecasts
- Risk assessment and recommendations

## Prediction Algorithms

### 1. Budget Overrun Prediction
- **Method:** Weighted time-series forecasting
- **Features:**
  - Weighted daily spending rate (recent days have higher weight)
  - Confidence scoring based on data consistency
  - Risk level determination (low/medium/high)
  - Remaining budget calculations

### 2. Monthly Forecast
- **Method:** Linear regression
- **Features:**
  - Calculates trend line through historical data
  - Predicts next month's spending
  - R-squared confidence scoring
  - Trend description generation

### 3. Category Classification
- **Method:** Fuzzy string matching + NLP
- **Features:**
  - Keyword-based matching with 8 categories
  - Levenshtein distance calculation
  - Similarity scoring (0-1 scale)
  - Alternative match suggestions

## Configuration

### Environment Variables

Create a `.env` file in the backend directory:

```env
FLASK_ENV=development
FLASK_DEBUG=True
PORT=5000
CORS_ORIGINS=http://localhost:8000,http://localhost:3000

# API Keys (if using external services)
# OPENAI_API_KEY=your_key_here
# STRIPE_API_KEY=your_key_here
```

## Extension Points

The backend is designed for easy expansion:

### Adding New Prediction Models
1. Create service in `backend/services/`
2. Implement prediction algorithm
3. Add API endpoint in `backend/routes/predictions.py`

### Adding New Insights
1. Extend `AIInsightsGenerator` in `backend/ai_models/insights_generator.py`
2. Add new analysis methods following existing patterns
3. Update insight categories and priorities

### Integrating ML Models
1. Create model training scripts in `backend/ai_models/`
2. Use scikit-learn or TensorFlow for training
3. Save models to `backend/models/` directory
4. Load models in service initialization

## Testing

```bash
# Run tests (if test suite exists)
python -m pytest tests/

# Test specific endpoint
curl -X POST http://localhost:5000/api/predictions/predict-overrun \
  -H "Content-Type: application/json" \
  -d @test_payload.json
```

## Performance Optimization

- **Caching:** Consider adding Redis for frequently accessed predictions
- **Async Processing:** Use Celery for long-running calculations
- **Database:** Add PostgreSQL for persistence
- **ML Models:** Use joblib for model serialization

## Deployment

### Docker

```dockerfile
FROM python:3.9
WORKDIR /app
COPY backend/requirements.txt .
RUN pip install -r requirements.txt
COPY backend/ .
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "app:create_app"]
```

### Heroku

```bash
heroku create spendly-backend
heroku buildpacks:add heroku/python
git push heroku main
```

## Troubleshooting

### Common Issues

1. **CORS Errors**
   - Check Flask-CORS is installed
   - Verify origin is in CORS_ORIGINS

2. **Import Errors**
   - Ensure backend/ directory is in Python path
   - Check __init__.py files exist in all packages

3. **Prediction Accuracy**
   - Requires minimum 3 historical data points
   - Ensure dates are in ISO format
   - Check for data quality issues

## Contributing

When adding new features:
1. Follow existing code structure
2. Add docstrings to all functions
3. Update API documentation
4. Test with sample data
5. Update requirements.txt if adding dependencies

## License

Part of Spendly Graduation Project

## Support

For issues and questions, contact the development team.
