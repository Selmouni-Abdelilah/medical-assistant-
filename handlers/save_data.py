import azure.functions as func
from services.db_service import save_conversation_to_db
import logging

def handle_save_data(req: func.HttpRequest) -> func.HttpResponse:
    try:
        # Parse the request body
        req_body = req.get_json()
        message = req_body.get("message")
        questions_and_answers = req_body.get("questions_and_answers")

        if not message or not questions_and_answers:
            return func.HttpResponse(
                "Missing 'message' or 'questions_and_answers' in the request body.",
                status_code=400
            )

        # Save the conversation to the database
        save_conversation_to_db(message, questions_and_answers)

        return func.HttpResponse(
            "Data saved successfully!",
            status_code=200
        )

    except Exception as e:
        logging.error(f"Error in save_data: {str(e)}")
        return func.HttpResponse(
            f"An error occurred: {str(e)}",
            status_code=500
        )
