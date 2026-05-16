"""
Model loader and manager for Spendly ML models.
Loads trained models and provides inference functions.
"""

import os
import pickle
import logging
from typing import Optional
from .ml_models import SpendlyCategoryClassifier, SpendlyOverrunPredictor, SpendlyForecastPredictor

logger = logging.getLogger(__name__)


class ModelManager:
    """Manages loading and using ML models."""
    
    _instance = None
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(ModelManager, cls).__new__(cls)
            cls._instance._initialized = False
        return cls._instance
    
    def __init__(self):
        if self._initialized:
            return
        
        self.models_dir = os.path.join(os.path.dirname(__file__), 'models')
        
        self.category_classifier: Optional[SpendlyCategoryClassifier] = None
        self.overrun_predictor: Optional[SpendlyOverrunPredictor] = None
        self.forecast_predictor: Optional[SpendlyForecastPredictor] = None
        
        self.models_loaded = False
        self._load_models()
        
        self._initialized = True
    
    def _load_models(self):
        """Load all trained models from disk."""
        try:
            # Load category classifier
            classifier_path = os.path.join(self.models_dir, 'category_classifier.pkl')
            if os.path.exists(classifier_path):
                with open(classifier_path, 'rb') as f:
                    self.category_classifier = pickle.load(f)
                logger.info("✅ Category Classifier loaded")
            else:
                logger.warning("⚠️ Category Classifier not found, creating new one")
                self.category_classifier = SpendlyCategoryClassifier()
            
            # Load overrun predictor
            overrun_path = os.path.join(self.models_dir, 'overrun_predictor.pkl')
            if os.path.exists(overrun_path):
                with open(overrun_path, 'rb') as f:
                    self.overrun_predictor = pickle.load(f)
                logger.info("✅ Overrun Predictor loaded")
            else:
                logger.warning("⚠️ Overrun Predictor not found, creating new one")
                self.overrun_predictor = SpendlyOverrunPredictor()
            
            # Load forecast predictor
            forecast_path = os.path.join(self.models_dir, 'forecast_predictor.pkl')
            if os.path.exists(forecast_path):
                with open(forecast_path, 'rb') as f:
                    self.forecast_predictor = pickle.load(f)
                logger.info("✅ Forecast Predictor loaded")
            else:
                logger.warning("⚠️ Forecast Predictor not found, creating new one")
                self.forecast_predictor = SpendlyForecastPredictor()
            
            self.models_loaded = True
            logger.info("🎯 All ML models loaded successfully")
        
        except Exception as e:
            logger.error(f"Error loading models: {e}")
            self.models_loaded = False
    
    def get_category_classifier(self) -> SpendlyCategoryClassifier:
        """Get category classifier instance."""
        if self.category_classifier is None:
            self.category_classifier = SpendlyCategoryClassifier()
        return self.category_classifier
    
    def get_overrun_predictor(self) -> SpendlyOverrunPredictor:
        """Get overrun predictor instance."""
        if self.overrun_predictor is None:
            self.overrun_predictor = SpendlyOverrunPredictor()
        return self.overrun_predictor
    
    def get_forecast_predictor(self) -> SpendlyForecastPredictor:
        """Get forecast predictor instance."""
        if self.forecast_predictor is None:
            self.forecast_predictor = SpendlyForecastPredictor()
        return self.forecast_predictor
    
    def reload_models(self):
        """Reload models from disk."""
        logger.info("Reloading ML models...")
        self.models_loaded = False
        self._load_models()
        logger.info("✅ Models reloaded")
    
    def save_models(self):
        """Save all current models to disk."""
        os.makedirs(self.models_dir, exist_ok=True)
        
        if self.category_classifier:
            with open(os.path.join(self.models_dir, 'category_classifier.pkl'), 'wb') as f:
                pickle.dump(self.category_classifier, f)
            logger.info("✅ Category Classifier saved")
        
        if self.overrun_predictor:
            with open(os.path.join(self.models_dir, 'overrun_predictor.pkl'), 'wb') as f:
                pickle.dump(self.overrun_predictor, f)
            logger.info("✅ Overrun Predictor saved")
        
        if self.forecast_predictor:
            with open(os.path.join(self.models_dir, 'forecast_predictor.pkl'), 'wb') as f:
                pickle.dump(self.forecast_predictor, f)
            logger.info("✅ Forecast Predictor saved")


def get_model_manager() -> ModelManager:
    """Get singleton ModelManager instance."""
    return ModelManager()
