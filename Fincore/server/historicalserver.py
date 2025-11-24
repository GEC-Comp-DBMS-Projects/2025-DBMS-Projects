from flask import Flask, jsonify, request, send_file
from SmartApi import SmartConnect
from SmartApi.smartWebSocketV2 import SmartWebSocketV2
import pyotp
from logzero import logger
from flask_cors import CORS
from datetime import datetime, timedelta
import os
from dotenv import load_dotenv
from flask_socketio import SocketIO
import threading
import pytz
import mysql.connector
from mysql.connector import Error
import bcrypt
import secrets

smartApi = None
totp = None
data = None
active_sws = {} 

load_dotenv()

app = Flask(__name__)
CORS(app)
socketio = SocketIO(app, cors_allowed_origins="*")

api_key = os.getenv("API_KEY")
username = "AAAV325665"
pwd = os.getenv("PASSWORD")
token_secret = os.getenv("TOKEN_SECRET")

print("Using username:", username)
print("Using API Key:", api_key)
print("Using Token Secret:", token_secret)

DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': '',  
    'database': 'stock_trading_app'
}

def get_db_connection():
    """Create and return a database connection"""
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        return connection
    except Error as e:
        logger.error(f"Database connection error: {e}")
        return None

def init_database():
    """Initialize database and create tables if they don't exist"""
    try:
        
        connection = mysql.connector.connect(
            host=DB_CONFIG['host'],
            user=DB_CONFIG['user'],
            password=DB_CONFIG['password']
        )
        cursor = connection.cursor()

        cursor.execute(f"CREATE DATABASE IF NOT EXISTS {DB_CONFIG['database']}")
        cursor.execute(f"USE {DB_CONFIG['database']}")
       
        """)
        
        connection.commit()
        logger.info(" Database and tables initialized successfully")
        cursor.close()
        connection.close()
        return True
    except Error as e:
        logger.error(f" Database initialization error: {e}")
        return False

@app.route('/api/auth/register', methods=['POST'])
def register_user():
    """Register a new user with their Angel One credentials"""
    try:
        data = request.json
     
        required_fields = ['full_name', 'email', 'phone', 'angel_username', 
                          'angel_api_key', 'angel_password', 'angel_token_secret']
        for field in required_fields:
            if not data.get(field):
                return jsonify({"error": f"{field} is required"}), 400

        password_hash = bcrypt.hashpw(data['angel_password'].encode('utf-8'), bcrypt.gensalt())
        
        connection = get_db_connection()
        if not connection:
            return jsonify({"error": "Database connection failed"}), 500
        
        cursor = connection.cursor()

        cursor.execute("SELECT user_id FROM users WHERE email = %s", (data['email'],))
        if cursor.fetchone():
            cursor.close()
            connection.close()
            return jsonify({"error": "User with this email already exists"}), 409
        
        """, (user_id, session_token, expires_at))
        
        connection.commit()
        cursor.close()
        connection.close()
        
        logger.info(f" User registered successfully: {data['email']}")
        
        return jsonify({
            "success": True,
            "message": "Registration successful",
            "user_id": user_id,
            "session_token": session_token,
            "full_name": data['full_name']
        }), 201
        
    except Error as e:
        logger.error(f" Registration error: {e}")
        return jsonify({"error": "Registration failed", "details": str(e)}), 500

@app.route('/api/auth/login', methods=['POST'])
def login_user():
    """Login user with email and verify credentials"""
    try:
        data = request.json
        email = data.get('email')
        angel_password = data.get('angel_password')
        
        if not email or not angel_password:
            return jsonify({"error": "Email and password are required"}), 400
        
        connection = get_db_connection()
        if not connection:
            return jsonify({"error": "Database connection failed"}), 500
        
        cursor = connection.cursor(dictionary=True)
        
        """, (user['user_id'],))
        
        session_token = secrets.token_urlsafe(32)
        expires_at = datetime.now() + timedelta(days=30)
        
        """, (session_token,))
        
        session = cursor.fetchone()
        cursor.close()
        connection.close()
        
        if not session:
            return jsonify({"valid": False, "error": "Invalid session"}), 401
        
        if not session['is_active']:
            return jsonify({"valid": False, "error": "Account deactivated"}), 403
        
        if datetime.now() > session['expires_at']:
            return jsonify({"valid": False, "error": "Session expired"}), 401
        
        return jsonify({
            "valid": True,
            "user_id": session['user_id'],
            "full_name": session['full_name'],
            "email": session['email']
        }), 200
        
    except Error as e:
        logger.error(f" Session verification error: {e}")
        return jsonify({"error": "Verification failed"}), 500

@app.route('/api/auth/logout', methods=['POST'])
def logout_user():
    """Logout user by invalidating session"""
    try:
        data = request.json
        session_token = data.get('session_token')
        
        if not session_token:
            return jsonify({"error": "Session token required"}), 400
        
        connection = get_db_connection()
        if not connection:
            return jsonify({"error": "Database connection failed"}), 500
        
        cursor = connection.cursor()