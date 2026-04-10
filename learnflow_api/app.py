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

from auth import auth_bp
from quiz import quiz_bp
from result import result_bp
from analysis import analysis_bp
from recommendation import recommendation_bp
from profile import profile_bp


def setup_logging():
    """ตั้งค่า logging กลาง — INFO ขึ้นไปแสดงใน console พร้อม timestamp"""
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
    setup_logging()
    logger = logging.getLogger(__name__)

    app = Flask(__name__)

    # ADD: Rate Limiting — ป้องกัน submit ซ้ำเร็วเกิน
    limiter = Limiter(
        get_remote_address,
        app=app,
        default_limits=[],           # ไม่ limit ทุก endpoint โดย default
        storage_uri='memory://',     # dev ใช้ memory, production เปลี่ยนเป็น redis://
    )
    app.extensions['limiter'] = limiter  # เก็บไว้ให้ blueprint เรียกใช้ได้

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
