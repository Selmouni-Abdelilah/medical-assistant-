import os

def get_env_variable(key):
    """
    Get an environment variable or raise an exception.
    """
    value = os.environ.get(f'ConnectionStrings:{key}')
    if not value:
        raise ValueError(f"Environment variable {key} is not set.")
    return value

def get_db_config():
    """
    Get database connection parameters.
    """
    return {
        "dbname": get_env_variable("DB_NAME"),
        "user": get_env_variable("DB_USER"),
        "password": get_env_variable("DB_PASSWORD"),
        "host": get_env_variable("DB_HOST"),
        "port": get_env_variable("DB_PORT")
    }