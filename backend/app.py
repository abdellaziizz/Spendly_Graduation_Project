"""
Spendly Backend - Flask API for Insights and Reports
"""
from flask import Flask, jsonify
from flask_cors import CORS
import sys
import os

# Add parent directory to path to import backend module
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from backend.routes import predictions_bp
import logging

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def create_app():
    """Create and configure the Flask application"""
    
    app = Flask(__name__)
    # Enable debug and propagate exceptions for local troubleshooting
    app.debug = True
    app.config['PROPAGATE_EXCEPTIONS'] = True
    
    # Enable CORS for all routes
    CORS(app, resources={
        r"/api/*": {
            "origins": ["*"],
            "methods": ["GET", "POST", "PUT", "DELETE"],
            "allow_headers": ["Content-Type"]
        }
    })
    
    # Register blueprints
    app.register_blueprint(predictions_bp)
    
    # Global error handlers
    @app.errorhandler(404)
    def not_found(error):
        return jsonify({'error': 'Endpoint not found'}), 404
    
    @app.errorhandler(500)
    def internal_error(error):
        logger.error(f'Internal server error: {error}')
        return jsonify({'error': 'Internal server error'}), 500
    
    # Health check
    @app.route('/health', methods=['GET'])
    def health():
        return jsonify({
            'status': 'healthy',
            'service': 'Spendly Backend API',
            'version': '1.0.0'
        })
    
    return app


if __name__ == '__main__':
    app = create_app()
    app.run(
        host='0.0.0.0',
        # Use 5001 by default for local debug to avoid conflicts
        port=int(os.environ.get('PORT', 5001)),
        debug=os.environ.get('FLASK_ENV') == 'development'
    )
