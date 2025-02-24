import mysql.connector
from mysql.connector import Error

def get_admindb_connection():
    return mysql.connector.connect(
            host="localhost",        # Your database host
            user="root",             # Your database username
            password="Virag$2310",   # Your database password
            database="collegeapp"    # Database name
        )
    
