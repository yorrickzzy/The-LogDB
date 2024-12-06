from flask import Flask, request, jsonify, render_template
import mysql.connector

app = Flask(__name__)

def get_db_connection():
    return mysql.connector.connect(
        host='10.200.30.38',
        user='root',
        password='zT7Um8p9BGN2M1q',
        database='TheLogDB_Dev'
    )

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/get_users', methods=['GET'])
def get_users():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT u.User_ID, u.User_Name, u.Email, r.Role_Name
        FROM Users u
        JOIN Roles r ON u.Role_ID = r.Role_ID
    """)
    users = cursor.fetchall()
    conn.close()
    return jsonify({'users': users})

@app.route('/add_user', methods=['POST'])
def add_user():
    data = request.get_json()
    user_name = data['user_name']
    email = data['email']
    role = data['role']

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO Users (User_Name, Email, Role_ID, PasswordHash)
        VALUES (%s, %s, (SELECT Role_ID FROM Roles WHERE Role_Name = %s), %s)
    """, (user_name, email, role, ''))  
    conn.commit()
    conn.close()
    return jsonify({'message': 'User added successfully!'})

@app.route('/edit_user/<int:user_id>', methods=['PUT'])
def edit_user(user_id):
    data = request.get_json()
    user_name = data['user_name']
    email = data['email']
    role = data['role']

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("""
        UPDATE Users
        SET User_Name = %s, Email = %s, Role_ID = (SELECT Role_ID FROM Roles WHERE Role_Name = %s)
        WHERE User_ID = %s
    """, (user_name, email, role, user_id))
    conn.commit()
    conn.close()
    return jsonify({'message': 'User updated successfully!'})

@app.route('/delete_user/<int:user_id>', methods=['DELETE'])
def delete_user(user_id):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM Users WHERE User_ID = %s", (user_id,))
    conn.commit()
    conn.close()
    return jsonify({'message': 'User deleted successfully!'})

if __name__ == '__main__':
    app.run(debug=True)

