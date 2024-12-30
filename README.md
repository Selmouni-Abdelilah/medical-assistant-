# Medical Assistant

The project is designed to automate the process of generating follow-up questions for medical scenarios using GPT and save the conversation data to a PostgreSQL database. The application is built using Azure Functions, Langchain, and PostgreSQL.

## Project Structure

```
my_ai_assistant/
│
├── function_app.py                 # Entry point for defining routes
├── handlers/
│   ├── __init__.py                 # Marks this directory as a module
│   ├── generate_questions.py       # Logic for generating questions
│   ├── save_data.py                # Logic for saving data to the database
│
├── services/
│   ├── __init__.py                 # Marks this directory as a module
│   ├── gpt_service.py              # GPT-related logic (question generation)
│   ├── db_service.py               # Database-related logic
│
├── config/
│   ├── __init__.py                 # Marks this directory as a module
│   ├── settings.py                 # Configuration loader (environment variables)
│
├── requirements.txt                # Dependencies

```

---

## `function_app.py`

This file defines the Azure Function application, including the routes for generating questions and saving data.

- **`generate_questions` route**:
    - **Purpose**: Accepts a `GET` request with a medical scenario and returns relevant follow-up questions generated by GPT.
    - **Handler**: `handle_generate_questions` from the `handlers.generate_questions` module.
    - **Authentication**: (To be handled).
    
    **Example Request** (POST JSON Body):
    
    ```json
    {
      "message": "I've been feeling fatigued and I have a mild fever for the last two days.",
    }
    
    ```
    
    **Example Response**:
    
    ```json
    {
      "questions": [
        "How long have you been feeling fatigued?",
        "Have you experienced any shortness of breath?",
        "Do you have any other symptoms such as a cough or headache?",
        "Have you recently traveled or been in contact with someone sick?"
      ]
    }
    
    ```
    
- **`save_data` route**:
    - **Purpose**: Accepts a `POST` request to save the conversation data (initial symptoms and generated questions with answers) to the database.
    - **Handler**: `handle_save_data` from the `handlers.save_data` module.
    - **Authentication**: (To be handled).
    
    **Example Request** (POST JSON Body):
    
    ```json
    {
      "message": "I've been feeling fatigued and I have a mild fever for the last two days.",
      "questions_and_answers": [
        ["How long have you been feeling fatigued?", "2 days"],
        ["Have you experienced any shortness of breath?", "No"],
        ["Do you have any other symptoms such as a cough or headache?", "No cough, mild headache"],
        ["Have you recently traveled or been in contact with someone sick?", "No"]
      ]
    }
    
    ```
    
    **Example Response**:
    
    ```json
    {
      "message": "Data saved successfully!"
    }
    
    ```
    

---

## `handlers/generate_questions.py`

This handler processes requests to generate follow-up questions based on a given medical scenario.

- **`handle_generate_questions` function**:
    - **Input**: The request body should contain a `"message"` key with the patient's symptoms or scenario.
    - **Output**: Returns a JSON response with a list of 4 follow-up questions generated by GPT.
    - **Error Handling**: Returns a `400` status if the `"message"` is missing, or a `500` status for other errors.

---

## `handlers/save_data.py`

This handler processes requests to save conversation data (initial symptoms and questions/answers) to the database.

- **`handle_save_data` function**:
    - **Input**: The request body should contain a `"message"` (initial symptoms) and `"questions_and_answers"` (list of questions and answers).
    - **Output**: Saves the data to the PostgreSQL database and returns a success message.
    - **Error Handling**: Returns a `400` status if required fields are missing, or a `500` status for other errors.

---

## `services/gpt_service.py`

This service contains the logic for generating questions using GPT (via Azure OpenAI).

- **`initialize_gpt_chain` function**:
    - **Purpose**: Sets up the prompt template and the GPT model using Azure OpenAI.
    - **Functionality**: Uses the Langchain library to create a prompt that asks for 4 relevant follow-up questions based on the given medical scenario.
- **`generate_questions` function**:
    - **Input**: The message (medical scenario).
    - **Output**: Returns a list of generated questions.
    - **Notes**: Uses the `initialize_gpt_chain` function to call the GPT model and generate the questions.

---

## `services/db_service.py`

This service handles the database connection and saving of conversation data to PostgreSQL.

- **`connect_to_db` function**:
    - **Purpose**: Establishes a connection to the PostgreSQL database using credentials from the environment.
    - **Error Handling**: Raises a `ConnectionError` if the database connection fails.
- **`save_conversation_to_db` function**:
    - **Input**: `initial_symptoms` (patient's symptoms) and `questions_and_answers` (list of follow-up questions and answers).
    - **Output**: Saves the data to the `MedicalConversations` table in PostgreSQL.
    - **Notes**: If the table does not exist, it will be created automatically. The data includes the initial symptoms and up to 4 follow-up questions with their corresponding answers.

---

## `config/settings.py`

This module provides functions to retrieve environment variables, such as database connection parameters and API keys.

- **`get_env_variable(key)` function**:
    - **Purpose**: Fetches an environment variable, raising an exception if the variable is not found.
    - **Usage**: Used throughout the project to retrieve configuration settings like API keys and database connection details.
- **`get_db_config()` function**:
    - **Purpose**: Retrieves the database connection parameters from the environment variables.
    - **Returns**: A dictionary containing the database name, user, password, host, and port.

---

## `requirements.txt`

This file lists the required dependencies for the project, such as:

- `azure-functions` - for working with Azure Functions.
- `langchain` and `langchain-openai` - for integrating with GPT-4.
- `psycopg2` - for connecting to PostgreSQL.

---

### Environment Configuration

Ensure that the following environment variables are set:

1. **Azure OpenAI**:
    - `ConnectionStrings:AZURE_OPENAI_API_KEY`
    - `ConnectionStrings:AZURE_OPENAI_ENDPOINT`
2. **PostgreSQL**:
    - `ConnectionStrings:DB_NAME`
    - `ConnectionStrings:DB_USER`
    - `ConnectionStrings:DB_PASSWORD`
    - `ConnectionStrings:DB_HOST`
    - `ConnectionStrings:DB_PORT`