import os
from langchain.prompts import PromptTemplate
from langchain_openai import AzureChatOpenAI
from config.settings import get_env_variable
import logging

# Initialize GPT chain
def initialize_gpt_chain():
    prompt_template = """
This application is designed to help automate the work of healthcare providers by generating follow-up questions based on the symptoms reported by the patient. The goal is for the LLM to ask relevant questions about the patient's condition, which will then help the healthcare provider review the patient's situation and contact them directly.

Based on the following medical scenario provided by the patient, generate 4 relevant follow-up questions. Do not include any numbers, and simply list the questions, each on a new line.

Scenario: "{input}"

Questions:
"""
    prompt = PromptTemplate(input_variables=["input"], template=prompt_template)

    try:
        llm = AzureChatOpenAI(
            openai_api_key=get_env_variable("AZURE_OPENAI_API_KEY"),
            azure_endpoint=get_env_variable("AZURE_OPENAI_ENDPOINT"),
            api_version="2024-05-01-preview", 
            azure_deployment="gpt-4"
        )
    except Exception as e:
        logging.error(f"Error initializing GPT chain: {str(e)}")
        raise e
    
    return prompt | llm

# Generate questions
def generate_questions(message):
    chain = initialize_gpt_chain()
    response = chain.invoke({"input": message})
    logging.info(f"modwl response: {str(response)}")
    return [q.strip() for q in response.content.strip().split("\n") if q.strip()]
