#!/usr/bin/env python
# coding: utf-8

# In[ ]:


from io import BytesIO
import fitz
import json
import os
import sys
from typing import Dict, List
from groq import Groq
from dotenv import load_dotenv

load_dotenv()


# In[ ]:

GROQ_API_KEY = os.getenv("GROQ_API_KEY")

try:
    client = Groq(api_key=GROQ_API_KEY)
except Exception as e:
    print(f"Error initializing Groq client: {e}")
    sys.exit(1)


# In[ ]:

def extract_from_pdf(pdf_path: str) -> str:
    try:
        doc = fitz.open(stream=BytesIO(pdf_path), filetype="pdf")
        text = "\n".join([page.get_text() for page in doc])
        return text
    except Exception as e:
        print(f"Error reading or parsing PDF file: {pdf_path}. Error: {e}")
        return None


# In[ ]:


def groq_llm(text: str) -> Dict:
    if not text:
        return {"error": "Input text is empty."}

    prompt = f"""
    You are an expert resume parser. Extract the following information from the provided resume text
    and return it as a clean JSON object.

    The JSON object must have these exact keys:
    - "name": string (full name of the candidate)
    - "email": string
    - "phone": string
    - "cgpa": float (extract the CGPA or GPA, return null if not found)
    - "skills": list of strings (extract all relevant technical skills)
    - "education": list of objects (each object representing a degree/certification with keys like "degree", "institution", "year", "gpa" if available)
    - "experience": list of objects (each object representing a work experience with keys like "title", "company", "years" or "duration", "description")

    If a piece of information is not found, the value should be `null`.

    Resume Text:
    ---
    {text}
    ---
    """

    try:
        chat_completion = client.chat.completions.create(
            messages=[
                {
                    "role": "user",
                    "content": prompt,
                }
            ],
            model="llama-3.1-8b-instant",
            temperature=0.1,
            response_format={"type": "json_object"},
        )

        content = chat_completion.choices[0].message.content
        return json.loads(content)

    except Exception as e:
        print(f"An error occurred during Groq API call: {e}")
        return {"error": "Failed to parse resume with Groq LLM."}


# In[ ]:


def parse_resume(pdf_bytes: bytes) -> Dict:
    print(f"Parsing resume.")
    raw_text = extract_from_pdf(pdf_bytes)
    if raw_text:
        return groq_llm(raw_text)
    else:
        return {"error": "Could not extract text from resume bytes."}


# In[ ]:


if __name__ == "__main__":    
    pdf_file = sys.argv[1]

    if not os.path.exists(pdf_file):
        print(f"Error: File not found at '{pdf_file}'")
        sys.exit(1)

    result = parse_resume(pdf_file)

    print("\n--- Extracted Details ---")
    print(json.dumps(result, indent=2))
    print("-------------------------\n")


# In[ ]:




