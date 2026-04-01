from flask import Flask
from flask_cors import CORS
from firebase_config import init_firebase

# Import blueprints
from auth import auth_bp
from quiz import quiz_bp
from result import result_bp
from analysis import analysis_bp
from recommendation import recommendation_bp
from profile import profile_bp

def create_app():
    app = Flask(__name__)
    CORS(app)  # อนุญาตให้ Flutter เรียก API ได้

    # Initialize Firebase Admin SDK
    init_firebase()

    # Register blueprints
    app.register_blueprint(auth_bp)
    app.register_blueprint(quiz_bp)
    app.register_blueprint(result_bp)
    app.register_blueprint(analysis_bp)
    app.register_blueprint(recommendation_bp)
    app.register_blueprint(profile_bp)

    @app.route('/')
    def index():
        return {'message': 'LearnFlow API is running'}, 200

    return app


if __name__ == '__main__':
    app = create_app()
    app.run(debug=True, host='0.0.0.0', port=5000)