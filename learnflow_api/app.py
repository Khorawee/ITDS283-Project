"""Flask app factory — main entry point for LearnFlow API.

Setup:
- Initializes Firebase authentication
- Sets up global rate limiting (Flask-Limiter)
- Registers all route blueprints (auth, quiz, analysis, etc.)
- Configures CORS and database connection pooling
- Provides health check endpoint
"""

import sys
import os
import logging
import logging.config

BASE_DIR = os.path.dirname(__file__)
sys.path.insert(0, BASE_DIR)
sys.path.insert(0, os.path.join(BASE_DIR, 'config'))
sys.path.insert(0, os.path.join(BASE_DIR, 'routes'))
sys.path.insert(0, os.path.join(BASE_DIR, 'services'))
sys.path.insert(0, os.path.join(BASE_DIR, 'middleware'))

from flask import Flask, jsonify
from flask_cors import CORS
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from firebase_config import init_firebase
import secrets
import hashlib
import base64

from auth import auth_bp
from quiz import quiz_bp
from result import result_bp
from analysis import analysis_bp
from recommendation import recommendation_bp
from user_profile import profile_bp

# ADD: Global limiter instance — so blueprints can use it
limiter = Limiter(
    key_func=get_remote_address,
    default_limits=[],
    storage_uri='memory://',
)


def setup_logging():
    """ตั้งค่า logging กลาง — INFO ขึ้นไปแสดงใน console พร้อม timestamp
    
    ตัวอย่าง: [2025-04-18 10:30:45] INFO auth: Login successful
    """
    logging.config.dictConfig({
        'version': 1,
        'disable_existing_loggers': False,
        'formatters': {
            'default': {
                'format': '[%(asctime)s] %(levelname)s %(name)s: %(message)s',
                'datefmt': '%Y-%m-%d %H:%M:%S',
            }
        },
        'handlers': {
            'console': {
                'class':     'logging.StreamHandler',
                'formatter': 'default',
            }
        },
        'root': {
            'level':    os.getenv('LOG_LEVEL', 'INFO'),
            'handlers': ['console'],
        },
    })


def create_app():
    """สร้าง Flask app instance พร้อม setup Firebase, CORS, Rate Limiting, DB Pooling"""
    setup_logging()
    logger = logging.getLogger(__name__)

    app = Flask(__name__)
    
    # Store CSRF tokens in-memory (use Redis in production)
    app.csrf_tokens = {}

    # Init global limiter with app
    limiter.init_app(app)

    # CORS
    allowed_origins = os.getenv('CORS_ORIGINS', '*')
    origins = allowed_origins.split(',') if allowed_origins != '*' else '*'
    CORS(app, origins=origins)

    init_firebase()

    app.register_blueprint(auth_bp)
    app.register_blueprint(quiz_bp)
    app.register_blueprint(result_bp)
    app.register_blueprint(analysis_bp)
    app.register_blueprint(recommendation_bp)
    app.register_blueprint(profile_bp)

    # ADD: CSRF Token Generation Endpoint
    @app.route('/api/csrf-token', methods=['GET'])
    def get_csrf_token():
        """Generate and return a CSRF token for state-changing requests"""
        token = base64.b64encode(secrets.token_bytes(32)).decode('utf-8')
        app.csrf_tokens[token] = True
        return jsonify({'csrf_token': token}), 200

    # ADD: CSRF Protection Middleware for POST/PUT/DELETE requests
    @app.before_request
    def verify_csrf():
        """ตรวจสอบ CSRF token บน POST/PUT/DELETE requests (ยกเว้น health check)"""
        from flask import request
        
        # Skip CSRF check สำหรับ GET/HEAD/OPTIONS หรือ /health
        if request.method in ('GET', 'HEAD', 'OPTIONS'):
            return
        if request.path == '/health':
            return
        
        # สำหรับ state-changing requests ต้องมี CSRF token
        token = request.headers.get('X-CSRF-Token') or request.form.get('csrf_token')
        if not token or token not in app.csrf_tokens:
            logger.warning('CSRF token missing or invalid for %s %s from %s',
                           request.method, request.path, request.remote_addr)
            return jsonify({'error': 'CSRF token invalid or missing'}), 403
        
        # Cleanup token after use (one-time use)
        del app.csrf_tokens[token]

    # ADD: Health check endpoint — ตรวจสอบ DB connection จริง
    @app.route('/health')
    def health():
        from db_config import get_connection
        try:
            conn = get_connection()
            with conn.cursor() as cur:
                cur.execute('SELECT 1')
            conn.close()
            return jsonify({'status': 'ok', 'db': 'connected'}), 200
        except Exception as e:
            logger.error('Health check failed: %s', str(e))
            return jsonify({'status': 'error', 'db': str(e)}), 503

    @app.route('/')
    def index():
        return {'message': 'LearnFlow API is running'}, 200

    # ADD: Debug endpoint to list all registered routes
    @app.route('/api/debug/routes', methods=['GET'])
    def debug_routes():
        """List all registered routes for debugging"""
        routes = []
        for rule in app.url_map.iter_rules():
            routes.append({
                'rule': str(rule),
                'methods': list(rule.methods - {'HEAD', 'OPTIONS'}),
                'endpoint': rule.endpoint
            })
        return jsonify({'routes': sorted(routes, key=lambda x: x['rule'])}), 200

    # ADD: Global error handlers
    @app.errorhandler(429)
    def rate_limit_error(e):
        return jsonify({'error': 'Too many requests, please slow down'}), 429

    @app.errorhandler(500)
    def internal_error(e):
        logger.error('Unhandled error: %s', str(e))
        return jsonify({'error': 'Internal server error'}), 500

    logger.info('LearnFlow API started — debug=%s', os.getenv('FLASK_DEBUG', 'false'))
    return app


if __name__ == '__main__':
    app = create_app()
    debug_mode = os.getenv('FLASK_DEBUG', 'false').lower() == 'true'
    port       = int(os.getenv('FLASK_PORT', 5000))
    app.run(debug=debug_mode, host='0.0.0.0', port=port)