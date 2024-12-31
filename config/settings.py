import os

def get_env_variable(key):
    """
    Get an environment variable or raise an exception.
    """
    value = os.environ[f'CUSTOMCONNSTR_{key}']
    if not value:
        raise ValueError(f"Environment variable {key} is not set.")
    return value

def get_db_connection_string():
    """
    Construct the Azure SQL database connection string from individual environment variables.
    """
    server = get_env_variable("AZURE_SQL_SERVER")
    database = get_env_variable("AZURE_SQL_DATABASE")
    username = get_env_variable("AZURE_SQL_USER")
    password = get_env_variable("AZURE_SQL_PASSWORD")
    return (
        f"Driver={{ODBC Driver 18 for SQL Server}};"
        f"Server=tcp:{server}.database.windows.net,1433;"
        f"Database={database};"
        f"UID={username};PWD={password};"
        "Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30"
    )
