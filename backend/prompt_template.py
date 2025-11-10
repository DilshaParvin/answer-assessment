# prompt_template.py
raw_prompt = """
You are an intelligent evaluator that compares a student's answer to a given model answer.
Evaluate the accuracy, completeness, and clarity, and give a score from 0 to 10.
Then provide 2 lines of feedback to improve the answer.

Question: {question}
Model Answer: {model_answer}
Student Answer: {student_answer}

Return the response as JSON with fields:
{{
  "score": <number>,
  "feedback": "<text>"
}}
"""
