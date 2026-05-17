"""
Configuration settings for API endpoints
This file can be modified based on deployment environment
"""

# API Configuration
API_BASE_URL = 'http://localhost:5000'
API_VERSION = 'v1'

# Prediction Service Endpoints
ENDPOINTS = {
    'predict_overrun': f'{API_BASE_URL}/api/predictions/predict-overrun',
    'forecast_monthly': f'{API_BASE_URL}/api/predictions/forecast-monthly',
    'classify_category': f'{API_BASE_URL}/api/predictions/classify-category',
    'generate_report': f'{API_BASE_URL}/api/predictions/generate-report',
    'generate_smart_tips': f'{API_BASE_URL}/api/predictions/generate-smart-tips',
    'health': f'{API_BASE_URL}/health',
}

# Request Configuration
REQUEST_TIMEOUT = 30  # seconds
RETRY_COUNT = 3
RETRY_DELAY = 1  # seconds

# Feature Flags
FEATURES = {
    'enable_ai_insights': True,
    'enable_predictions': True,
    'enable_category_classification': True,
    'enable_smart_tips': True,
}

# Environment Configuration
ENVIRONMENT = 'development'  # 'development', 'staging', 'production'

# Production Configuration (Override for production)
if ENVIRONMENT == 'production':
    API_BASE_URL = 'https://api.spendly.app'
    REQUEST_TIMEOUT = 60

# Development Configuration (Override for development)
if ENVIRONMENT == 'development':
    DEBUG = True
    LOG_LEVEL = 'DEBUG'
else:
    DEBUG = False
    LOG_LEVEL = 'INFO'
