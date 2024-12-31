import azure.functions as func
from handlers.generate_questions import handle_generate_questions
from handlers.save_data import handle_save_data

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)

@app.route(route="generate_questions", auth_level=func.AuthLevel.ANONYMOUS)
def generate_questions(req: func.HttpRequest) -> func.HttpResponse:
    return handle_generate_questions(req)
    
@app.route(route="save_data", auth_level=func.AuthLevel.ANONYMOUS)
def save_data(req: func.HttpRequest) -> func.HttpResponse:
    return handle_save_data(req)