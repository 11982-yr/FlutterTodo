from flask import Flask, jsonify
from config import Config
from extensions import db, cors
from routes import tasks_bp
from models import Task


def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)

    db.init_app(app)
    cors.init_app(app)

    app.register_blueprint(tasks_bp)

    @app.route("/")
    def home():
        return jsonify({"message": "Backend is running successfully"})

    @app.route("/api/health", methods=["GET"])
    def health():
        return jsonify({"status": "ok"})

    with app.app_context():
        db.create_all()

    return app


app = create_app()

if __name__ == "__main__":
    app.run(
        debug=Config.DEBUG,
        host=Config.HOST,
        port=Config.PORT
    )
