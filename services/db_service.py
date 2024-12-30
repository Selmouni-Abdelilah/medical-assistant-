import psycopg2
from config.settings import get_db_config

def connect_to_db():
    """
    Establish a connection to the PostgreSQL database.
    """
    try:
        db_params = get_db_config()
        return psycopg2.connect(**db_params)
    except psycopg2.Error as e:
        raise ConnectionError(f"Error connecting to PostgreSQL: {e}")

def save_conversation_to_db(initial_symptoms, questions_and_answers):
    """
    Save conversation data to the database.
    """
    conn = connect_to_db()
    cursor = conn.cursor()

    try:
        # Create table if it doesn't exist
        create_table_query = '''
        CREATE TABLE IF NOT EXISTS MedicalConversations (
            id SERIAL PRIMARY KEY,
            initial_symptoms TEXT NOT NULL,
            follow_up_question_1 TEXT,
            answer_1 TEXT,
            follow_up_question_2 TEXT,
            answer_2 TEXT,
            follow_up_question_3 TEXT,
            answer_3 TEXT,
            follow_up_question_4 TEXT,
            answer_4 TEXT
        )
        '''
        cursor.execute(create_table_query)

        # Insert data
        placeholders = [None] * 8
        for i, (question, answer) in enumerate(questions_and_answers[:4]):
            placeholders[i * 2] = question
            placeholders[i * 2 + 1] = answer

        insert_query = '''
        INSERT INTO MedicalConversations (
            initial_symptoms, 
            follow_up_question_1, answer_1, 
            follow_up_question_2, answer_2, 
            follow_up_question_3, answer_3, 
            follow_up_question_4, answer_4
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        '''
        cursor.execute(insert_query, (initial_symptoms, *placeholders))
        conn.commit()

    finally:
        cursor.close()
        conn.close()
