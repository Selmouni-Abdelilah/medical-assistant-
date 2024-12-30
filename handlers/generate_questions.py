import azure.functions as func
from services.gpt_service import generate_questions
import logging
import json

def handle_generate_questions(req: func.HttpRequest) -> func.HttpResponse:
    try:
        # Parse the request body
        req_body = req.get_json()
        message = req_body.get("message")

        if not message:
            return func.HttpResponse(
                "Missing 'message' in the request body.",
                status_code=400
            )

        # Generate questions using GPT service
        questions = generate_questions(message)

        return func.HttpResponse(
            json.dumps({"questions": questions}),
            status_code=200,
            mimetype="application/json"
        )

    except Exception as e:
        logging.error(f"Error in generate_questions: {str(e)}")
        return func.HttpResponse(
            f"An error occurred: {str(e)}",
            status_code=500
        )
