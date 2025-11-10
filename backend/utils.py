# utils.py
import re

def parse_questions_keys(text: str):
    """
    Extracts question numbers and text from a scanned document text.
    Example: "1. What is AI? 2. Define ML."
    """
    pattern = r'(\d+[\).]\s*)([A-Z].*?)(?=\d+[\).]|$)'
    matches = re.findall(pattern, text, re.DOTALL)
    questions = {f"Q{num.strip(').')}": q.strip() for num, q in matches}
    return questions

def parse_answers(text: str):
    """
    Extracts answers if separated by numbers or question indicators.
    Example: "1. AI is artificial intelligence. 2. ML is machine learning."
    """
    pattern = r'(\d+[\).]\s*)(.*?)(?=\d+[\).]|$)'
    matches = re.findall(pattern, text, re.DOTALL)
    answers = [a.strip() for _, a in matches]
    return answers
