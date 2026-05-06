"""Flask Application for Spendly ML Predictions."""
import os
import logging
from flask import Flask, jsonify
from flask_cors import CORS
from dotenv import load_dotenv

from .config import config
from .routes.predictions import predictions_bp

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Create Flask app
app = Flask(__name__)

# Load configuration
env = os.getenv('FLASK_ENV', 'development')
app.config.from_object(config.get(env, config['development']))

# Enable CORS - Force '*' for all origins in development
CORS(app, 
     resources={r"/api/*": {"origins": "*", "methods": ["GET", "POST", "OPTIONS", "PUT", "DELETE"], "allow_headers": ["Content-Type", "Authorization"]}},
     supports_credentials=False)

# Register blueprints
app.register_blueprint(predictions_bp)


@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint."""
    return jsonify({
        "status": "healthy",
        "service": "Spendly ML Predictions API",
        "version": "1.0.0"
    }), 200


@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors."""
    return jsonify({"error": "Endpoint not found"}), 404


@app.errorhandler(500)
def server_error(error):
    """Handle 500 errors."""
    logger.error(f"Server error: {error}")
    return jsonify({"error": "Internal server error"}), 500


def create_app():
    """Create and configure the Flask application."""
    return app


if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    debug = os.getenv('FLASK_ENV', 'development') == 'development'
    
    logger.info(f"Starting Spendly ML Predictions API on port {port}...")
    logger.info(f"Debug mode: {debug}")
    
    app.run(
        host='0.0.0.0',
        port=port,
        debug=debug
    )
