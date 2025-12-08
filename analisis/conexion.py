import mysql.connector

def get_connection():
    return mysql.connector.connect(
        host="10.0.2.28",      
        user="clinica_user",
        password="ClinicaPass.123",
        database="clinica_db"
    )
