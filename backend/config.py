"""Configuration for Spendly ML Backend."""
import os
from dotenv import load_dotenv

load_dotenv()


class Config:
    """Base configuration."""
    
    FLASK_ENV = os.getenv('FLASK_ENV', 'development')
    FLASK_DEBUG = os.getenv('FLASK_DEBUG', 'True').lower() == 'true'
    PORT = int(os.getenv('PORT', 5000))
    API_BASE_URL = os.getenv('API_BASE_URL', 'http://localhost:5000')
    
    # CORS - Allow all origins in development, restrict in production
    CORS_ORIGINS = ["*"] if os.getenv('FLASK_ENV') == 'development' else os.getenv('CORS_ORIGINS', 'http://localhost:3000').split(',')
    
    # Logging
    LOG_LEVEL = os.getenv('LOG_LEVEL', 'DEBUG')
    
    # API Settings
    REQUEST_TIMEOUT = 30
    MAX_RETRIES = 3


class DevelopmentConfig(Config):
    """Development configuration."""
    FLASK_DEBUG = True


class ProductionConfig(Config):
    """Production configuration."""
    FLASK_DEBUG = False


config = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
    'default': DevelopmentConfig
}
