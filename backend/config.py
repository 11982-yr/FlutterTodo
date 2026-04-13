import os
from dotenv import load_dotenv
"""
this file connect flask app to the database.
"""

load_dotenv() #this line loads the .env file.


class Config:
    # connect the app to PostgreSQL
    DB_HOST = os.getenv("DB_HOST")
    DB_NAME = os.getenv("DB_NAME")
    DB_USER = os.getenv("DB_USER")
    DB_PASSWORD = os.getenv("DB_PASSWORD")
    DB_PORT = os.getenv("DB_PORT")

    # the line here build the database connection URL.
    """
    since we use PostgreSQL database this will Connect to a PostgreSQL
    database running on localhost, port 5432, with user postgres,
    password postgres123, and use the database todo_app.
    """
    SQLALCHEMY_DATABASE_URI = (
    f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)
    
    SQLALCHEMY_TRACK_MODIFICATIONS = False

    # the 3 line below tells the Flask how to run backend server

    # 1- read FLASK_DEBUG from .env and convert it into True or False
    DEBUG = os.getenv("FLASK_DEBUG", "True").lower() == "true"
    # 2- read the server host from .env, if the HOST missing use 0.0.0.0
    HOST = os.getenv("HOST", "0.0.0.0")
    # 3- read the port from .env then convert it to int
    PORT = int(os.getenv("PORT", "5000"))
