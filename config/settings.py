import os

def get_env_variable(key):
    """
    Get an environment variable or raise an exception.
    """
    value = os.environ.get(f'CUSTOMCONNSTR_:{key}')
    if not value:
        raise ValueError(f"Environment variable {key} is not set.")
    return value

def get_db_connection_string():
    """
    Get Azure SQL database connection string from environment variables.
    """
    return get_env_variable("AZURE_SQL_CONNECTIONSTRING")
