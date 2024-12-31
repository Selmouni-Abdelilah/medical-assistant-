import pyodbc
from config.settings import get_db_connection_string

def connect_to_db():
    """
    Establish a connection to the Azure SQL database.
    """
    try:
        connection_string = get_db_connection_string()
        return pyodbc.connect(connection_string)
    except pyodbc.Error as e:
        raise ConnectionError(f"Error connecting to Azure SQL: {e}")

def save_conversation_to_db(initial_symptoms, questions_and_answers):
    """
    Save conversation data to the Azure SQL database.
    """
    conn = connect_to_db()
    cursor = conn.cursor()

    try:
        # Create table if it doesn't exist
        create_table_query = '''
        IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='MedicalConversations' AND xtype='U')
        CREATE TABLE MedicalConversations (
            id INT IDENTITY(1,1) PRIMARY KEY,
            initial_symptoms NVARCHAR(MAX) NOT NULL,
            follow_up_question_1 NVARCHAR(MAX),
            answer_1 NVARCHAR(MAX),
            follow_up_question_2 NVARCHAR(MAX),
            answer_2 NVARCHAR(MAX),
            follow_up_question_3 NVARCHAR(MAX),
            answer_3 NVARCHAR(MAX),
            follow_up_question_4 NVARCHAR(MAX),
            answer_4 NVARCHAR(MAX)
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
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        '''
        cursor.execute(insert_query, (initial_symptoms, *placeholders))
        conn.commit()

    finally:
        cursor.close()
        conn.close()
