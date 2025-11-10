import json
from fastapi import FastAPI, HTTPException, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from langchain_community.llms import Ollama
import pytesseract
from PIL import Image
import io

app = FastAPI(
    title="Answer Assessment API",
    description="Extract text from images and evaluate answers using an LLM via Ollama + LangChain.",
    version="1.0.1"
)

# ✅ Allow frontend access
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # or specify your Flutter web origin if you want
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ✅ Connect to Ollama with a lightweight model
llm = Ollama(model="gemma:2b", base_url="http://localhost:11434")



@app.get("/")
def read_root():
    return {"message": "Answer Assessment Backend is Running 🚀"}


# 🧾 Extract text from uploaded image
@app.post("/extract-text")
async def extract_text(file: UploadFile = File(...)):
    try:
        image_bytes = await file.read()
        image = Image.open(io.BytesIO(image_bytes))
        extracted_text = pytesseract.image_to_string(image)
        return {"extracted_text": extracted_text.strip()}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error extracting text: {str(e)}")


# 🧠 Evaluate student's answer
@app.post("/evaluate-answer/")
async def evaluate_answer(data: dict):
    question = data.get("question")
    student_answer = data.get("student_answer")

    try:
        # Call the LLM via Ollama
        import requests
        response = requests.post(
            "http://localhost:11434/api/generate",
            json={
                "model": "phi3:latest",
                "prompt": f"Evaluate the student's answer for the question.\n\nQuestion: {question}\n\nAnswer: {student_answer}\n\nGive a JSON output with 'score' (out of 10) and 'feedback'.",
                "stream": False
            }
        )
        response.raise_for_status()
        llm_output = response.json().get("response", "").strip()

        # Try to extract actual JSON from model output
        import json, re
        json_text_match = re.search(r'\{.*\}', llm_output, re.DOTALL)
        if json_text_match:
            json_text = json_text_match.group(0)
            feedback_data = json.loads(json_text)
        else:
            feedback_data = {"score": "N/A", "feedback": llm_output}

        return {"evaluation": feedback_data}

    except Exception as e:
        return {"detail": f"Error during evaluation: {e}"}
