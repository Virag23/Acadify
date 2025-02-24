import mysql.connector
from mysql.connector import Error

def get_dbs_connection():
    return mysql.connector.connect(
            host="localhost",
            user="root",
            password="Virag$2310",  # Replace with your password
            database="collegeapp"
        )
  