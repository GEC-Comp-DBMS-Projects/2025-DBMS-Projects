import os
import re
import json
import fitz
import traceback
from flask import Flask, request, jsonify
from werkzeug.utils import secure_filename
import mysql.connector

UPLOAD_FOLDER = 'uploads'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

DB_CONFIG = {
    'host': '127.0.0.1',
    'user': 'root',
    'password': '',
    'database': 'dbms'
}

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

def extract_form16_details(pdf_path):
    doc = fitz.open(pdf_path)
    text = ""
    for page in doc:
        text += page.get_text("text")

    def find(pattern):
        match = re.search(pattern, text, re.IGNORECASE)
        return match.group(1).strip() if match else ''

    details = {
        "name": find(r'Name\s+([A-Za-z\s]+)'),
        "pan": find(r'PAN\s+([A-Z]{5}[0-9]{4}[A-Z])'),
        "email": find(r'Email\s+([\w\.-]+@[\w\.-]+)'),
        "mobile": find(r'Mobile\s+(\+?\d[\d\s-]+)'),
        "address": find(r'Address\s+(.*?)\n2\. Employer'),
        "employer_name": find(r'Employer Name\s+(.+)'),
        "employer_tan": find(r'TAN\s+([A-Z0-9]+)'),
        "employer_pan": find(r'PAN\s+([A-Z0-9]+)'),
        "gross_salary": find(r'Gross Salary\s*■?([\d,]+)'),
        "hra": find(r'HRA\s*■?([\d,]+)'),
        "lta": find(r'LTA\s*■?([\d,]+)'),
        "gratuity": find(r'Gratuity\s*■?([\d,]+)'),
        "other_exemptions": find(r'Other Exemptions\s*■?([\d,]+)'),
        "net_salary": find(r'Net Salary\s*■?([\d,]+)'),
        "income_chargeable": find(r'Income Chargeable\s*■?([\d,]+)'),
        "sec_80c": find(r'Section 80C\s*■?([\d,]+)'),
        "sec_80d": find(r'Section 80D\s*■?([\d,]+)'),
        "sec_80ccd": find(r'Section 80CCD\(1B\)\s*■?([\d,]+)'),
        "sec_80tta": find(r'Section 80TTA\s*■?([\d,]+)'),
        "sec_80g": find(r'Section 80G\s*■?([\d,]+)'),
        "total_deductions": find(r'Total Deductions\s*■?([\d,]+)'),
        "total_income": find(r'Total Income\s*■?([\d,]+)'),
        "tax_before_cess": find(r'Tax Before Cess\s*■?([\d,]+)'),
        "cess": find(r'Cess.*■?([\d,]+)'),
        "total_tax_liability": find(r'Total Tax Liability\s*■?([\d,]+)'),
        "tds_deducted": find(r'TDS Deducted\s*■?([\d,]+)'),
        "tax_refund": find(r'Tax Payable / Refundable\s*■?([\d,]+\s*\(.*\))')
    }

    return details

def get_db_connection():
    return mysql.connector.connect(**DB_CONFIG)

@app.route('/upload_form16', methods=['POST'])
def upload_form16():
    try:
        file = request.files.get('file')
        if not file:
            return jsonify({'error': 'No file uploaded'}), 400

        filename = secure_filename(file.filename)
        path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(path)

        extracted = extract_form16_details(path)

        conn = get_db_connection()
        cursor = conn.cursor()