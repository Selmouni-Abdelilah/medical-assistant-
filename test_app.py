import requests
import json

# Endpoint URLs
generate_questions_url = "https://medical-form-function-app.azurewebsites.net/api/generate_questions"
save_data_url = "https://medical-form-function-app.azurewebsites.net/api/save_data"

def interact_with_azure_function():
    try:
        # Step 1: Get user input
        user_message = input("How are you feeling? Describe your symptoms: ")
        request_payload = {"message": user_message}

        # Step 2: Call the generate_questions endpoint
        print("Sending your message to generate questions...")
        response = requests.get(generate_questions_url, json=request_payload)
        if response.status_code == 200:
            questions = response.json().get("questions", [])
            print("Questions received:")
        else:
            print(f"Failed to generate questions. Status code: {response.status_code}")
            print("Response:", response.text)
            return

        # Display the questions to the user and collect answers
        questions_and_answers = []
        for question in questions:
            print(f"Question: {question}")
            answer = input("Your answer: ")
            questions_and_answers.append([question, answer])

        # Step 3: Call the save_data endpoint
        save_payload = {
            "message": user_message,
            "questions_and_answers": questions_and_answers
        }
        print("Saving your data...")
        save_response = requests.get(save_data_url, json=save_payload)
        if save_response.status_code == 200:
            print("Data saved successfully!")
        else:
            print(f"Failed to save data. Status code: {save_response.status_code}")
            print("Response:", save_response.text)

    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    interact_with_azure_function()
