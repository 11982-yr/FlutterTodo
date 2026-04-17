import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    # Use DATABASE_URL if available (for production)
    SQLALCHEMY_DATABASE_URI = os.getenv("DATABASE_URL") or (
        f"postgresql://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}"
        f"@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
    )

    SQLALCHEMY_TRACK_MODIFICATIONS = False

    # Flask settings
    DEBUG = os.getenv("FLASK_DEBUG", "False").lower() == "true"
    HOST = os.getenv("HOST", "0.0.0.0")
    PORT = int(os.getenv("PORT", "5000"))
