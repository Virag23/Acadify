from flask import Flask, request, jsonify
from flask_bcrypt import Bcrypt
from flask_cors import CORS
import mysql.connector
import re

app = Flask(__name__)
CORS(app)

bcrypt = Bcrypt(app)

def get_db_connection():
    return mysql.connector.connect(
        host="localhost",        
        user="root",             
        password="Virag$2310",   
        database="collegeapp"    
    )

def get_college_table_name(college, table_type):
    return f"{college}_{table_type}"

@app.route("/")
def home():
    return "Flask is running!"

@app.route('/api/register_college', methods=['POST'])
def register_college():
    data = request.get_json()
    college_full_name = data.get('college_full_name', '').strip()
    college_name = data.get('college_name', '').strip()
    password = data.get('password', '').strip()
    college_email = data.get('college_email', '').strip()
    college_number = data.get('college_number', '').strip()

    if not all([college_full_name, college_name, password, college_email, college_number]):
        return jsonify({"error": "All fields are required!"}), 400

    hashed_password = bcrypt.generate_password_hash(password).decode('utf-8')

    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("""
            INSERT INTO college_name (college_full_name, college_name, password, college_email, college_number) 
            VALUES (%s, %s, %s, %s,%s)
        """, (college_full_name, college_name, hashed_password, college_email, college_number))
        
        conn.commit()
        return jsonify({"message": f"College '{college_full_name}' Registered Successfully!"}), 201
    except mysql.connector.IntegrityError:
        return jsonify({"error": "College already exists!"}), 400
    finally:
        cursor.close()
        conn.close()

@app.route('/api/colleges', methods=['GET'])
def get_colleges():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT college_full_name FROM college_name")  
    colleges = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(colleges), 200

@app.route('/api/names', methods=['GET'])
def get_names():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT college_name FROM college_name")  
    names = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(names), 200

@app.route('/api/verify_college', methods=['POST']) 
def verify_college():
    data = request.get_json()
    college_full_name = data.get('college_full_name', '').strip()
    college_name = data.get('college_name', '').strip()
    password = data.get('password', '').strip()

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("SELECT password FROM college_name WHERE college_full_name = %s AND college_name = %s", (college_full_name, college_name))
        result = cursor.fetchone()

        if result and bcrypt.check_password_hash(result['password'], password):
            return jsonify({"message": f"'{college_full_name}' Verified!"}), 200
        else:
            return jsonify({"error": "Invalid Password"}), 400
    finally:
        cursor.close()
        conn.close()


@app.route('/api/register', methods=['POST'])
def register_student():
    data = request.get_json()
    college = data.get('college', '').strip()
    print(f"Received college_name: '{college}'")

    if not college:
        return jsonify({"error": "College name is required!"}), 400

    table_name = get_college_table_name(college, "students")
    print(f"Trying to access table: {table_name}")

    name = data.get('name')
    email = data.get('email')
    number = data.get('number')
    prn = data.get('prn')
    department = data.get('department')
    year = data.get('year')
    semester = data.get('semester')
    division = data.get('division')
    roll_no = data.get('roll_no')
    password = data.get('password')

    if not all([name, email, number, prn, department, year, semester, division, roll_no, password]):
        return jsonify({"error": "All fields are required!"}), 400

    hashed_password = bcrypt.generate_password_hash(password).decode('utf-8')

    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        cursor.execute(f"""
            INSERT INTO {table_name} (name, email, number, prn, department, year, semester, division, roll_no, password)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (name, email, number, prn, department, year, division, semester, roll_no, hashed_password))
        
        conn.commit()
        return jsonify({"message": "Student registration successful!"}), 201
    except mysql.connector.Error as e:
        return jsonify({"error": f"Database error: {str(e)}"}), 400
    finally:
        cursor.close()
        conn.close()
        
@app.route('/api/login', methods=['POST'])
def api_login():
    data = request.get_json()
    college = data.get('college', '').strip()
    print(f"Received college_name: '{college}'")
    
    if not college:
        return jsonify({"error": "College name is required!"}), 400

    table_name = get_college_table_name(college, "students")
    print(f"Trying to access table: {table_name}")
    
    email = data.get('email')
    password = data.get('password')

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute(f"SELECT * FROM {table_name} WHERE email = %s", (email,))
    user = cursor.fetchone()

    cursor.close()
    conn.close()

    if user and bcrypt.check_password_hash(user['password'], password):
        return jsonify({
            "message": "Login successful!",
            "name": user['name'],
            "email": user['email'],
            "number": user['number'],
            "prn": user['prn'],
            "department": user['department'],
            "year": user['year'],
            "semester": user['semester'],
            "division": user['division'],
            "roll_no": user['roll_no']
        }), 200
    else:
        return jsonify({"error": "Invalid credentials"}), 401

# API for Faculty Registration
@app.route('/api/facultyregister', methods=['POST'])
def register_faculty():
    data = request.get_json()
    college = data.get('college', '').strip()
    print(f"Received college_name: '{college}'")
    
    if not college:
        return jsonify({"error": "College name is required!"}), 400

    table_name = get_college_table_name(college, "faculty")
    print(f"Trying to access table: {table_name}")

    name = data.get('name')
    email = data.get('email')
    number = data.get('number')
    department = data.get('department')
    password = data.get('password')

    if not all([name, email, number, department, password]):
        return jsonify({"error": "All fields are required!"}), 400

    hashed_password = bcrypt.generate_password_hash(password).decode('utf-8')

    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        cursor.execute(f"""
            INSERT INTO {table_name} (name, email, number, department, password)
            VALUES (%s, %s, %s, %s, %s)
        """, (name, email, number, department, hashed_password))
        
        conn.commit()
        return jsonify({"message": "Faculty registration successful!"}), 201
    except mysql.connector.Error as e:
        return jsonify({"error": f"Database error: {str(e)}"}), 400
    finally:
        cursor.close()
        conn.close()

@app.route('/api/facultylogin', methods=['POST'])
def api_facultylogin():
    data = request.get_json()
    college = data.get('college', '').strip()
    print(f"Received college_name: '{college}'")
    
    if not college:
        return jsonify({"error": "College name is required!"}), 400

    table_name = get_college_table_name(college, "faculty")
    print(f"Trying to access table: {table_name}")
    
    email = data.get('email')
    password = data.get('password')

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute(f"SELECT * FROM {table_name} WHERE email = %s", (email,))
    user = cursor.fetchone()

    cursor.close()
    conn.close()

    if user and bcrypt.check_password_hash(user['password'], password):
        return jsonify({
            "message": "Login successful!",
            "name": user['name'],
            "email": user['email'],
            "number": user['number'],
            "department": user['department']
        }), 200
    else:
        return jsonify({"error": "Invalid credentials"}), 401

# API for Admin Registration
@app.route('/api/adminRegister', methods=['POST'])
def register_admin():
    data = request.get_json()
    college= data.get('college', '').strip()
    print(f"Received college_name: '{college}'")
    
    if not college:
        return jsonify({"error": "College name is required!"}), 400

    table_name = get_college_table_name(college, "admin")
    print(f"Trying to access table: {table_name}")

    name = data.get('name')
    email = data.get('email')
    number = data.get('number')
    department = data.get('department')
    year = data.get('year')
    semester = data.get('semester')
    division = data.get('division')
    password = data.get('password')

    if not all([name, email, number, department, year, semester, division, password]):
        return jsonify({"error": "All fields are required!"}), 400

    hashed_password = bcrypt.generate_password_hash(password).decode('utf-8')

    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        cursor.execute(f"""
            INSERT INTO {table_name} (name, email, number, department, year, semester, division, password)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """, (name, email, number, department, year, semester, division, hashed_password))
        
        conn.commit()
        return jsonify({"message": "Admin registration successful!"}), 201
    except mysql.connector.Error as e:
        return jsonify({"error": f"Database error: {str(e)}"}), 400
    finally:
        cursor.close()
        conn.close()
        
@app.route('/api/adminLogin', methods=['POST'])
def api_adminLogin():
    data = request.get_json()
    college = data.get('college', '').strip()
    print(f"Received college_name: '{college}'")
    
    if not college:
        return jsonify({"error": "College name is required!"}), 400

    table_name = get_college_table_name(college, "admin")
    print(f"Trying to access table: {table_name}")
    
    email = data.get('email')
    password = data.get('password')

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute(f"SELECT * FROM {table_name} WHERE email = %s", (email,))
    user = cursor.fetchone()

    cursor.close()
    conn.close()

    if user and bcrypt.check_password_hash(user['password'], password):
        return jsonify({
            "message": "Login successful!",
            "name": user['name'],
            "email": user['email'],
            "number": user['number'],
            "department": user['department'],
            "year": user['year'],
            "semester": user['semester'],
            "division": user['division']
        }), 200
    else:
        return jsonify({"error": "Invalid credentials"}), 401
    
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)