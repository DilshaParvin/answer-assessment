# Intelligent Short Answer Assessment
A Flutter + FastAPI-based application that evaluates student answers using OCR and LLMs.

## Features
- Upload handwritten or typed answers
- AI-generated evaluation with feedback
- Local dashboard to view saved results

## Tech Stack
- **Backend:** FastAPI, LangChain, Pytesseract
- **Frontend:** Flutter (Web/Desktop UI)

## Run Locally
1. Clone this repo  
2. Install backend requirements  
   ```bash
   cd backend
   pip install -r requirements.txt
   uvicorn main:app --reload
3. Run frontend
    cd frontend/answer_assessment_ui
flutter run -d chrome
