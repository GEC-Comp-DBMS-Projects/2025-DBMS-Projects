import fitz
import json
import os
import sys
from io import BytesIO
from typing import Dict
from groq import Groq
from dotenv import load_dotenv

load_dotenv()

try:
    client = Groq(api_key=os.getenv("GROQ_API_KEY"))
except Exception as e:
    print(f"Error initializing Groq client: {e}")
    client = None

def _extract_text_from_pdf(pdf_bytes: bytes) -> str:
    """Extracts all text from a PDF given as bytes."""
    try:
        doc = fitz.open(stream=BytesIO(pdf_bytes), filetype="pdf")
        text = "\n".join([page.get_text() for page in doc])
        return text
    except Exception as e:
        print(f"Error reading or parsing PDF bytes: {e}")
        return None

def analyze_resume_ats(pdf_bytes: bytes) -> Dict:
    if client is None:
        return {"error": "Groq client not initialized."}
        
    print("Analyzing resume for ATS score...")
    raw_text = _extract_text_from_pdf(pdf_bytes)

    if not raw_text:
        return {"error": "Could not extract text from resume bytes."}

    prompt = """
    You are an expert ATS (Applicant Tracking System) resume analyzer.
    Your task is to review the provided resume text and return a JSON object.
    Do not add ANY introductory text, concluding text, or markdown formatting (like ```json).
    The JSON object must have exactly three keys:
    1. "atsScore": An integer between 0 and 100, representing the resume's quality and ATS friendliness.
    2. "suggestions": A list of strings (3-5 items) with actionable advice for improvement.
    3. "missingKeywords": A list of strings (3-5 items) of important keywords for a tech/engineering role that are missing.
    
    Only output the raw JSON object.
    """

    try:
        chat_completion = client.chat.completions.create(
            messages=[
                {"role": "system", "content": prompt},
                {
                    "role": "user",
                    "content": f"Here is the resume text:\n\n{raw_text}\n\nPlease provide the analysis."
                }
            ],
            model="llama-3.1-8b-instant",
            temperature=0.2,
            max_tokens=1024,
            response_format={"type": "json_object"},
        )
        content = chat_completion.choices[0].message.content
        return json.loads(content)

    except Exception as e:
        print(f"An error occurred during Groq API call: {e}")
        return {"error": "Failed to analyze resume with Groq LLM."}

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python resume_analyzer.py <path_to_pdf>")
        sys.exit(1)
        
    pdf_file_path = sys.argv[1]

    if not os.path.exists(pdf_file_path):
        print(f"Error: File not found at '{pdf_file_path}'")
        sys.exit(1)

    with open(pdf_file_path, "rb") as f:
        pdf_bytes_content = f.read()

    result = analyze_resume_ats(pdf_bytes_content)

    print("\n--- Analysis Result ---")
    print(json.dumps(result, indent=2))
    print("-----------------------\n")