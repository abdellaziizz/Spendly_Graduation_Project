# Spendly ML Backend

Python Flask API server for AI-powered financial predictions and insights.

## Features

- 🤖 **Budget Overrun Prediction** - Predict if you'll exceed budget
- 📊 **Monthly Forecast** - Predict next month's spending
- 🏷️ **Category Classification** - Auto-categorize transactions
- 💡 **AI Insights** - Generate personalized recommendations

## Quick Start

### 1. Setup Virtual Environment

```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

### 3. Configure Environment

```bash
cp .env.example .env
# Edit .env if needed
```

### 4. Run the Server

```bash
python app.py
```

Server will start on `http://localhost:5000`

## API Endpoints

### GET /health
Health check endpoint.

```bash
curl http://localhost:5000/health
```

### GET /api/predictions/health
Predictions API health check.

```bash
curl http://localhost:5000/api/predictions/health
```

### POST /api/predictions/predict-overrun
Predict budget overrun.

**Request:**
```json
{
  "currentSpending": 2500,
  "budgetLimit": 3000,
  "daysInMonth": 30,
  "currentDay": 15,
  "expenses": [
    {"amount": 50, "date": "2024-01-01", "description": "Grocery"}
  ]
}
```

**Response:**
```json
{
  "will_overrun": false,
  "confidence": 0.85,
  "projected_spending": 2800.50,
  "risk_level": "medium",
  "days_left": 15,
  "message": "⚠️ Warning: Projected to exceed budget by $50"
}
```

### POST /api/predictions/forecast-monthly
Forecast next month's spending.

**Request:**
```json
{
  "historicalMonthly": [2500, 2600, 2700, 2800],
  "currentMonth": 2400
}
```

**Response:**
```json
{
  "predicted_amount": 2750.00,
  "confidence": 0.88,
  "trend": "increasing",
  "trend_description": "📈 Your spending is gradually increasing",
  "average": 2650.00,
  "months_analyzed": 4
}
```

### POST /api/predictions/classify-category
Classify transaction category.

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
  "confidence": 0.95,
  "alternatives": [
    {"category": "entertainment", "confidence": 0.1}
  ]
}
```

### POST /api/predictions/generate-insights
Generate AI insights.

**Request:**
```json
{
  "overrunPrediction": {...},
  "forecast": {...},
  "expenses": [...]
}
```

**Response:**
```json
{
  "budget_insights": [...],
  "spending_patterns": {...},
  "recommendations": [...],
  "alerts": [...],
  "summary": "✅ Your budget is on track..."
}
```

### POST /api/predictions/all-predictions
Get all predictions at once (recommended).

**Request:**
```json
{
  "currentSpending": 2500,
  "budgetLimit": 3000,
  "daysInMonth": 30,
  "currentDay": 15,
  "historicalMonthly": [2500, 2600, 2700],
  "currentMonth": 2400,
  "expenses": [...]
}
```

**Response:**
```json
{
  "overrunPrediction": {...},
  "forecast": {...},
  "insights": {...},
  "classifiedExpenses": [...]
}
```

## Testing

### Using curl

```bash
# Test health
curl http://localhost:5000/health

# Test predictions
curl -X POST http://localhost:5000/api/predictions/predict-overrun \
  -H "Content-Type: application/json" \
  -d '{
    "currentSpending": 2500,
    "budgetLimit": 3000,
    "expenses": [],
    "daysInMonth": 30,
    "currentDay": 15
  }'
```

### Using Python requests

```python
import requests

response = requests.post(
    'http://localhost:5000/api/predictions/predict-overrun',
    json={
        'currentSpending': 2500,
        'budgetLimit': 3000,
        'expenses': [],
        'daysInMonth': 30,
        'currentDay': 15
    }
)
print(response.json())
```

## File Structure

```
backend/
├── app.py                      # Flask application
├── config.py                   # Configuration
├── requirements.txt            # Python dependencies
├── .env.example               # Environment template
├── models/
│   └── __init__.py            # Data models
├── services/
│   ├── __init__.py
│   ├── overrun_predictor.py    # Budget prediction
│   ├── monthly_forecast_engine.py  # Forecasting
│   └── category_classifier.py  # Category classification
├── ai_models/
│   ├── __init__.py
│   └── insights_generator.py   # AI insights
└── routes/
    ├── __init__.py
    └── predictions.py          # API endpoints
```

## Services

### OverrunPredictor
Predicts whether user will exceed budget before month ends.

**Features:**
- Weighted daily spending rate calculation
- Confidence scoring
- Risk level assessment (low/medium/high)

### MonthlyForecastEngine
Forecasts next month's spending using historical data.

**Features:**
- Trend analysis (increasing/decreasing/stable)
- Confidence based on data consistency
- Linear regression

### CategoryClassifier
Classifies transactions into categories.

**Categories:**
- Food & Dining
- Entertainment
- Transport
- Shopping
- Health
- Utilities
- Education
- Other

**Features:**
- Keyword matching
- Confidence scoring
- Alternative suggestions

### InsightsGenerator
Generates AI-powered insights and recommendations.

**Features:**
- Budget insights
- Spending pattern analysis
- Personalized recommendations
- Alert generation
- Executive summary

## Configuration

### Environment Variables

- `FLASK_ENV` - Environment (development/production)
- `FLASK_DEBUG` - Enable debug mode
- `PORT` - Server port (default: 5000)
- `API_BASE_URL` - API base URL
- `CORS_ORIGINS` - Allowed CORS origins
- `LOG_LEVEL` - Logging level

### CORS Configuration

By default, CORS is enabled for all origins. To restrict:

```python
# In app.py
CORS(app, resources={
    r"/api/*": {
        "origins": ["http://localhost:3000"],
        "methods": ["GET", "POST"],
        "allow_headers": ["Content-Type"]
    }
})
```

## Deployment

### Using Gunicorn (Production)

```bash
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:5000 "backend.app:create_app()"
```

### Using Docker

```dockerfile
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "backend.app:create_app()"]
```

## Performance

- Budget Prediction: <100ms
- Forecast: <50ms
- Category Classification: <10ms
- **Total API Response: <200ms**

## Troubleshooting

### Port Already in Use

```bash
# Find process using port 5000
lsof -i :5000

# Kill process
kill -9 <PID>

# Or use different port
PORT=8000 python app.py
```

### CORS Errors

Update `CORS_ORIGINS` in `.env` or add your frontend URL.

### Import Errors

Ensure you're running from the project root:
```bash
cd path/to/tspendly
python backend/app.py
```

## Support

For issues or questions, check the logs:

```bash
python app.py  # Logs appear in console
```

## License

Part of Spendly financial tracking application.
