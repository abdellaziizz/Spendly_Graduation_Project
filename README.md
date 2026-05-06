# Tspendly - AI-Powered Expense Tracker

A modern Flutter expense tracking application with AI-powered predictions, intelligent category classification, and personalized financial insights.

## Features

### 💰 Core Features
- Track daily expenses
- Manage budgets by category
- Wallet management with multi-currency support
- Beautiful charts and analytics
- Receipt scanning with OCR
- Voice transaction logging

### 🤖 AI-Powered Features (NEW!)
- **Budget Overrun Prediction** - Get alerted before exceeding budget
- **Monthly Spending Forecast** - Predict next month's spending trends
- **Smart Category Classification** - Auto-categorize transactions
- **Personalized Insights** - Get AI-generated recommendations

## Getting Started

See [ML_SETUP_GUIDE.md](ML_SETUP_GUIDE.md) for detailed setup instructions.

### Quick Start

```bash
# 1. Setup Python Backend
python -m venv venv
source venv/bin/activate
cd backend
pip install -r requirements.txt
python app.py

# 2. In another terminal, setup Flutter
cd ..
flutter pub get
flutter run -d web
```

## Project Structure

```
tspendly/
├── backend/                    # Python ML Backend
│   ├── app.py                 
│   ├── services/              # ML services
│   │   ├── overrun_predictor.py
│   │   ├── monthly_forecast_engine.py
│   │   └── category_classifier.py
│   └── routes/
│       └── predictions.py
│
├── lib/features/predictions/  # Flutter ML Integration
│   ├── models/
│   ├── providers/
│   └── screens/
│       └── future_insights_screen.dart
│
└── assets/
```

## API Endpoints

- `POST /api/predictions/predict-overrun` - Budget prediction
- `POST /api/predictions/forecast-monthly` - Spending forecast  
- `POST /api/predictions/classify-category` - Category classification
- `POST /api/predictions/all-predictions` - All predictions at once

## Technologies

- **Flutter** - Cross-platform UI
- **Python/Flask** - ML backend
- **Riverpod** - State management
- **Supabase** - Backend & Auth

For detailed documentation, see [ML_SETUP_GUIDE.md](ML_SETUP_GUIDE.md)
