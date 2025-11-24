from flask import Flask, request, jsonify
from flask_cors import CORS
import requests
from models.resume import parse_resume
from pymongo import MongoClient
from bson import ObjectId
from datetime import datetime
import os
import io
from models.resume_score import analyze_resume_ats

app = Flask(__name__)
CORS(app)

MONGO_URI = os.getenv("MONGO_URI")
DB_NAME = "campusNestDB"

try:
    client = MongoClient(MONGO_URI)
    # The ismaster command is cheap and does not require auth. It forces a connection check.
    client.admin.command('ismaster')
    print("✅ MongoDB connection successful.")
except Exception as e:
    print(f"❌ MongoDB connection failed. Please check your MONGO_URI. Error: {e}")
    client = None

if client:
    db = client[DB_NAME]
    try:
        collections = db.list_collection_names()
        print(f"🔍 Connected to database '{DB_NAME}'.")
        print(f"   Visible collections: {collections}")
        if "users" not in collections:
            print("   ⚠️ CRITICAL WARNING: The 'Users' collection was not found in this database!")
    except Exception as e:
        print(f"❌ Could not list collections. Check DB name and user permissions. Error: {e}")
    
    users_collection = db["users"]
    resumes_collection = db["resumes"]
else:
    users_collection = None
    resumes_collection = None


@app.route("/", methods=["GET"])
def health_check():
    return jsonify({"status": "ok", "message": "ML API is running"}), 200


@app.route("/resume", methods=["POST"])
def parse_and_store_resume():
    data = request.get_json()
    if not data or "resume" not in data or "userId" not in data:
        return jsonify({"error": "Missing 'resume' URL or 'userId' in request body"}), 400

    resume_url = data["resume"]
    user_id_str = data["userId"]
    resume_name = data["resume_name"] if "resume_name" in data else ""

    try:
        user_oid = ObjectId(user_id_str)
        user = users_collection.find_one({"_id": user_oid})
        if not user:
            return jsonify({"error": f"User with ID {user_oid} not found"}), 404

        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36'
        }
        response = requests.get(resume_url, headers=headers)
        response.raise_for_status() 

        parsed_data = parse_resume(response.content)

        new_resume_document = {
            "student_id": user_oid,
            "file_url": resume_url,
            "parsed_data": parsed_data,
            "resume_name": resume_name,
            "uploaded_at": datetime.utcnow(),
        }
        result_insert = resumes_collection.insert_one(new_resume_document)
        print(f"Successfully inserted resume with ID: {result_insert.inserted_id}")

        result_update = users_collection.update_one(
            {"_id": user_oid},
            {
                "$push": {
                    "activeResumeId": result_insert.inserted_id,
                    # "qualifications": { "$each": parsed_data.get("education", []) }
                },
                "$addToSet": {
                    "skills": { "$each": parsed_data.get("skills", []) }
                }
        }
        )
        
        if result_update.matched_count == 0:
            return jsonify({"error": "Failed to find user to update resume link array"}), 404

        return jsonify({
            "message": "Resume parsed, stored in Resumes collection, and user profile updated.",
            "newResumeId": str(result_insert.inserted_id),
            "parsedData": parsed_data,
        }), 200

    except Exception as e:
        print(f"An error occurred: {e}")
        return jsonify({"error": str(e)}), 500
    
@app.route('/api/v1/student/resume/analyze', methods=['POST'])
def analyze_resume():
    auth_header = request.headers.get('Authorization')
    if not auth_header or not auth_header.startswith('Bearer '):
        return jsonify({"message": "Authorization header missing or invalid"}), 401
    
    data = request.get_json()
    if not data or 'fileUrl' not in data:
        return jsonify({"message": "Missing 'fileUrl' in request body"}), 400

    file_url = data['fileUrl']

    try:
        print(f"Fetching resume from: {file_url}")
        response = requests.get(file_url)
        response.raise_for_status()
        
        pdf_bytes = response.content
        
        print("--- Sending raw PDF bytes to analyzer ---")

        analysis_result = analyze_resume_ats(pdf_bytes)
        
        if "error" in analysis_result:
            return jsonify(analysis_result), 500
            
        return jsonify(analysis_result), 200

    except requests.exceptions.RequestException as e:
        print(f"Error downloading file: {e}")
        return jsonify({"message": "Could not fetch resume from URL"}), 500
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        return jsonify({"message": str(e)}), 500
    
if __name__ == "__main__":
    app.run(debug=True, port=5000)
