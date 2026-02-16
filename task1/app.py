from flask import Flask, jsonify, request
import psycopg2
import os
import time

app = Flask(__name__)

DB_HOST = os.getenv('DB_HOST', 'localhost')
DB_PORT = os.getenv('DB_PORT', '5432')
DB_NAME = os.getenv('DB_NAME', 'appdb')
DB_USER = os.getenv('DB_USER', 'appuser')
DB_PASSWORD = os.getenv('DB_PASSWORD', 'apppassword')

def get_db_connection():
    conn = psycopg2.connect(
        host = DB_HOST,
        port = DB_PORT,
        database = DB_NAME,
        user = DB_USER,
        password = DB_PASSWORD
    )
    return conn

def init_db():
    max_retries = 5
    retry_count = 0

    while retry_count < max_retries:
        try:
            conn = get_db_connection()
            cur = conn.cursor()
            cur.execute('''
                CREATE TABLE IF NOT EXISTS messages (
                    id SERIAL PRIMARY KEY,
                    content TEXT NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            ''')
            conn.commit()
            cur.close()
            conn.close()
            print("Database Initialised Successfully")
            return
        except Exception as e:
            retry_count += 1
            print(f"Database Connection Attempt {retry_count} failed: {e}")
            time.sleep(5)
    print("Failed to initialize the db after many tries")

init_db()

@app.route('/')
def home():
    return jsonify({
        "message": "Welcome to Monitor",
        "endpoints": {
            "/": "Monitor",
            "/health/live": "Liveness Probe",
            "/health/ready": "Readiness Probe",
            "/messages": "GET: List all messages, POST: Create message",
            "/messages/<id>": "GET: Get specific message"
        }
    })

@app.route('/health/live')
def liveness():
    return jsonify({"status": "alive"}), 200

@app.route('/health/ready')
def readiness():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('SELECT 1')
        cur.close()
        conn.close()
        return jsonify({
            "status": "ready",
            "database": "connected"
            }), 200
    except Exception as e:
        return jsonify({"status": "not ready", "error": str(e)}), 503

@app.route('/messages', methods = ['GET', 'POST'])
def messages():
    if request.method == 'POST':
        data = request.get_json()
        content = data.get('content', '')
        if not content:
            return jsonify({"error": "Content is required"}), 400
        try:
            conn = get_db_connection()
            cur = conn.cursor()
            cur.execute('INSERT INTO messages (content) VALUES (%s) RETURNING id', (content,))
            message_id = cur.fetchone()[0]
            conn.commit()
            cur.close()
            conn.close()
            return jsonify({"id": message_id, "content": content, "status": "created"}), 201
        except Exception as e:
            return jsonify({"error": str(e)}), 500
    
    else:
        try:
            conn = get_db_connection()
            cur = conn.cursor()
            cur.execute('SELECT id, content, created_at FROM messages ORDER BY created_at DESC')
            rows = cur.fetchall()
            cur.close()
            conn.close()
            message_list = [
                {"id": row[0], "content": row[1], "created_at": str(row[2])}
                for row in rows
            ]
            return jsonify({"messages": message_list, "count": len(message_list)}), 200
        except Exception as e:
            return jsonify({"error": str(e)}), 500

@app.route('/messages/<int:message_id>')
def get_message(message_id):
    try:
         conn = get_db_connection()
         cur = conn.cursor()
         cur.execute('SELECT id, content, created_at FROM messages WHERE id = %s', (message_id,))
         row = cur.fetchone()
         cur.close()
         conn.close()

         if row:
            return jsonify({
                "id": row[0],
                "content": row[1],
                "created_at": str(row[2])
            }), 200
         else:
            return jsonify({"error": "Message not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)


# kubectl port-forward -n webapp service/webapp-service 8080:5000