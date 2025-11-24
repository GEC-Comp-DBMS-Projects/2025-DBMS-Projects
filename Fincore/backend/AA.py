
import requests
from flask import Flask, request, abort, jsonify
from flask_cors import CORS
import mysql.connector
from mysql.connector import Error
from datetime import datetime
import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
CORS(app)

DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'localhost'),
    'user': os.getenv('DB_USER', 'root'),
    'password': os.getenv('DB_PASSWORD', ''),
    'database': os.getenv('DB_NAME', 'DBMS')
}

def get_db_connection():
    """Create and return a database connection"""
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        return connection
    except Error as e:
        print(f"Error connecting to MySQL: {e}")
        return None

def init_db():
    """Initialize database tables"""
    connection = get_db_connection()
    if not connection:
        return
    
    cursor = connection.cursor()
    
    try:
        ''')
        
        ''')
        
        connection.commit()
        print("✓ Database tables created successfully")
    except Error as e:
        print(f"Error creating tables: {e}")
    finally:
        cursor.close()
        connection.close()

@app.route('/webhook', methods=['POST'])
def webhook():
	"""Handle Setu AA webhooks for consent and session status updates"""
	if request.method == 'POST':
		data = request.json
		print("Webhook received:", data)
		
		notification_type = data.get('type')
		
		if notification_type == 'CONSENT_STATUS_UPDATE':
			handle_consent_notification(data)
		elif notification_type == 'SESSION_STATUS_UPDATE':
			handle_session_notification(data)
		
		return jsonify({'success': True}), 200
	else:
		return jsonify({'error': 'Method not allowed'}), 400

def handle_consent_notification(data):
	"""Handle consent status update notifications"""
	try:
		consent_id = data.get('consentId')
		status = data.get('data', {}).get('status')
		accounts = data.get('data', {}).get('detail', {}).get('accounts', [])
		
		connection = get_db_connection()
		if not connection:
			return
		
		cursor = connection.cursor()
		
		cursor.execute(
			'UPDATE consents SET status = %s WHERE consent_id = %s',
			(status, consent_id)
		)
		
		if status == 'ACTIVE' and accounts:
			cursor.execute('SELECT user_id FROM consents WHERE consent_id = %s', (consent_id,))
			result = cursor.fetchone()
			
			if result:
				user_id = result[0]
				
				for account in accounts:
				''', (fi_status, link_ref))
		
		connection.commit()
		cursor.close()
		connection.close()
		
		print(f"✓ Session {session_id} status updated to {status}")
		
		if status in ['COMPLETED', 'PARTIAL']:
			print(f"🔄 Auto-fetching data for session {session_id}...")
			try:
				access_token = get_token()
				fetch_and_store_data(access_token, session_id)
				print(f"✓ Auto-fetch completed for session {session_id}")
			except Exception as e:
				print(f"❌ Error auto-fetching data: {e}")
				import traceback
				traceback.print_exc()
				
	except Exception as e:
		print(f"Error handling session notification: {e}")

@app.route('/createConsent', methods=['POST'])
def createConsent():
	"""Create a new consent for a user"""
	if request.method == 'POST':
		try:
			user_email = request.json.get('email')
			consent_days = request.json.get('consentDays', 365)
			data_range_from = request.json.get('dataRangeFrom')
			data_range_to = request.json.get('dataRangeTo')
			
			if not user_email:
				return jsonify({'error': 'Email is required'}), 400
			
			connection = get_db_connection()
			if not connection:
				return jsonify({'error': 'Database connection failed'}), 500
			
			cursor = connection.cursor(dictionary=True)
			cursor.execute('SELECT id, phone FROM users WHERE email = %s', (user_email,))
			user = cursor.fetchone()
			
			if not user:
				cursor.close()
				connection.close()
				return jsonify({'error': 'User not found'}), 404
			
			user_id = user['id']
			phone_number = user['phone']
			
			access_token = get_token()
			
			consent_id, consent_url = create_consent(
				access_token, 
				phone_number, 
				consent_days,
				data_range_from,
				data_range_to
			)
			
			from datetime import datetime
			
			def parse_iso_date(date_str, default):
				if not date_str:
					return datetime.strptime(default, '%Y-%m-%dT%H:%M:%SZ')
				try:
					return datetime.strptime(date_str.rstrip('Z'), '%Y-%m-%dT%H:%M:%S')
				except ValueError:
					return datetime.strptime(default, '%Y-%m-%dT%H:%M:%SZ')
			
			mysql_from_date = parse_iso_date(data_range_from, '2023-01-01T00:00:00Z')
			mysql_to_date = parse_iso_date(data_range_to, '2025-12-31T00:00:00Z')
			
			''', (user_email,))
			
			consent = cursor.fetchone()
			cursor.close()
			connection.close()
			
			if consent:
				return jsonify({
					'hasConsent': True,
					'consentId': consent['consent_id'],
					'status': consent['status']
				}), 200
			else:
				return jsonify({
					'hasConsent': False
				}), 200
				
		except Exception as e:
			print(f"Error checking user consent: {e}")
			return jsonify({'error': str(e)}), 500
	else:
		return jsonify({'error': 'Method not allowed'}), 400

@app.route('/consentCheck', methods=['POST'])
def consentCheck():
	"""Check consent status by consent ID"""
	if request.method == 'POST':
		try:
			consent_id = request.json.get('consentId')
			
			if not consent_id:
				return jsonify({'error': 'Consent ID is required'}), 400
			
			access_token = get_token()
			response = get_consent_status(access_token, consent_id)
			
			if 'status' in response:
				connection = get_db_connection()
				if connection:
					cursor = connection.cursor()
					cursor.execute(
						'UPDATE consents SET status = %s WHERE consent_id = %s',
						(response['status'], consent_id)
					)
					connection.commit()
					cursor.close()
					connection.close()
			
			return jsonify({'status': response.get('status', 'UNKNOWN')}), 200
			
		except Exception as e:
			print(f"Error checking consent: {e}")
			return jsonify({'error': str(e)}), 500
	else:
		return jsonify({'error': 'Method not allowed'}), 400

@app.route('/sessionCheck', methods=['POST'])
def sessionCheck():
	"""Create or check data session status"""
	print("🚀 SessionCheck called - VERSION 2.2 WITH RETRY LOGIC")
	if request.method == 'POST':
		try:
			consent_id = request.json.get('consentId')
			
			if not consent_id:
				return jsonify({'error': 'Consent ID is required'}), 400
				
			connection = get_db_connection()
			if not connection:
				return jsonify({'error': 'Database connection failed'}), 500
				
			cursor = connection.cursor(dictionary=True)
			''', (consent_id,))
			
			consent_data = cursor.fetchone()
			
			if not consent_data:
				cursor.close()
				connection.close()
				return jsonify({'error': 'Consent not found'}), 404
			
			data_range_from = consent_data['data_range_from']
			data_range_to = consent_data['data_range_to']
			
			access_token = get_token()
			consent_details = get_consent_status(access_token, consent_id)
			
			if 'detail' not in consent_details:
				cursor.close()
				connection.close()
				return jsonify({'error': 'Unable to fetch consent details'}), 500
			
			consent_data_range = consent_details.get('detail', {}).get('dataRange', {})
			data_from_iso = consent_data_range.get('from', "2023-01-01T00:00:00Z")
			data_to_iso = consent_data_range.get('to', "2025-12-31T00:00:00Z")
			
			print(f"Using consent's exact date range: {data_from_iso} to {data_to_iso}")
			
			print(f"Creating session with date range: {data_from_iso} to {data_to_iso}")
			print(f"Consent details: {consent_details}")
			
			if consent_details.get('status') != 'ACTIVE':
				return jsonify({
					'success': False,
					'error': f"Consent is not active (status: {consent_details.get('status')})"
				}), 400
			
			max_retries = 3
			retry_count = 0
			while retry_count < max_retries:
				response = create_session(access_token, consent_id, data_from_iso, data_to_iso)
				
				print(f"Session creation attempt {retry_count + 1} response status: {response.status_code}")
				print(f"Session creation response: {response.text}")
				
				if response.status_code in [200, 201]:
					break
					
				error_data = response.json()
				error_msg = error_data.get('errorMsg', '')
				
				if 'Consent use exceeded' in error_msg:
					print(f"⚠️ Consent use exceeded, waiting 2 seconds before retry...")
					import time
					time.sleep(2)
				else:
					print(f"❌ Session creation failed with status {response.status_code}")
					print(f"❌ Error details: {error_data}")
					cursor.close()
					connection.close()
					return jsonify({
						'success': False,
						'error': error_msg or 'Failed to create session'
					}), 500
					
				retry_count += 1
				
			if retry_count == max_retries:
				print("❌ Max retries reached for session creation")
				cursor.close()
				connection.close()
				return jsonify({
					'success': False,
					'error': 'Failed to create session after multiple attempts'
				}), 500
			
			print(f"✓ Session creation successful with status {response.status_code}")
			
			response_data = response.json()
			session_id = response_data.get('id')
			status = response_data.get('status', 'PENDING')
			
			if not session_id:
				print(f"❌ No session ID in response: {response_data}")
				cursor.close()
				connection.close()
				return jsonify({
					'success': False,
					'error': 'Session creation failed'
				}), 500
			
			print(f"✓ Session created successfully: {session_id} with status: {status}")
			
			''', (user_email,))
			
			accounts = cursor.fetchall()
			cursor.close()
			connection.close()
			
			print(f"📊 getUserAccounts: Found {len(accounts)} accounts for {user_email}")
			
			for account in accounts:
				if account.get('current_balance'):
					account['current_balance'] = float(account['current_balance'])
				for key in ['created_at', 'updated_at']:
					if account.get(key) and hasattr(account[key], 'isoformat'):
						account[key] = account[key].isoformat()
			
			return jsonify({
				'success': True,
				'accounts': accounts
			}), 200
			
		except Exception as e:
			print(f"❌ ERROR getting user accounts: {e}")
			import traceback
			traceback.print_exc()
			return jsonify({'error': str(e)}), 500
	else:
		return jsonify({'error': 'Method not allowed'}), 400

@app.route('/getAccountTransactions', methods=['POST'])
def getAccountTransactions():
	"""Get transactions for a specific account"""
	if request.method == 'POST':
		try:
			account_id = request.json.get('accountId')
			
			if not account_id:
				return jsonify({'error': 'Account ID is required'}), 400
			
			connection = get_db_connection()
			if not connection:
				return jsonify({'error': 'Database connection failed'}), 500
			
			cursor = connection.cursor(dictionary=True)
			
		''', (session_id,))
		
		result = cursor.fetchone()
		if not result:
			cursor.close()
			connection.close()
			return
		
		consent_id, user_id = result
		
		for fip in data.get('fips', []):
			fip_id = fip.get('fipID')
			
			for account_data in fip.get('accounts', []):
				link_ref = account_data.get('linkRefNumber')
				masked_acc = account_data.get('maskedAccNumber')
				fi_status = account_data.get('status')
				
				account_info = account_data.get('data', {}).get('account', {})
				
				profile = account_info.get('profile', {})
				holders = profile.get('holders', {})
				holder_info = holders.get('holder', {}) if isinstance(holders.get('holder'), dict) else {}
				holder_name = holder_info.get('name', '')
				
				summary = account_info.get('summary', {})
				current_balance = 0
				if isinstance(summary, dict):
					current_balance = summary.get('currentBalance', 0)
					if isinstance(current_balance, str):
						try:
							current_balance = float(current_balance)
						except:
							current_balance = 0
				
				account_type = account_info.get('type', 'DEPOSIT')
				
						''', (
							bank_account_id, txn_id, txn_type, mode, amount,
							currency, balance, txn_timestamp, value_date,
							narration, reference
						))
		
		connection.commit()
		cursor.close()
		connection.close()
		
		print(f"✓ Data fetched and stored for session {session_id}")
		
	except Exception as e:
		print(f"Error fetching and storing data: {e}")
		import traceback
		traceback.print_exc()

if __name__ == '__main__':
	print("Initializing database...")
	init_db()
	print("Starting Flask server on port 5000...")
	print("Server accessible at:")
	print("  - Local: http://localhost:5000")
	print("  - Network: http://192.168.1.5:5000")
	print("Make sure ngrok is running: ngrok http 5000 --url=helpful-vastly-shark.ngrok-free.app")
	app.run(host='0.0.0.0', port=5000, debug=True)