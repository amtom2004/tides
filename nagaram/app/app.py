import os
import json
import boto3
import psycopg2
from flask import Flask, jsonify, request

app = Flask(__name__)

def get_db():
    return psycopg2.connect(
        host=os.environ.get("DB_HOST", "localhost"),
        port=5432,
        database=os.environ.get("DB_NAME", "nagaramdb"),
        user=os.environ.get("DB_USER", "admin"),
        password=os.environ.get("DB_PASSWORD", "nagaram123")
    )

def get_sqs():
    return boto3.client(
        "sqs",
        region_name="us-east-1",
        endpoint_url=os.environ.get("SQS_ENDPOINT", "http://localhost:4566"),
        aws_access_key_id="test",
        aws_secret_access_key="test"
    )

def get_s3():
    return boto3.client(
        "s3",
        region_name="us-east-1",
        endpoint_url=os.environ.get("S3_ENDPOINT", "http://localhost:4566"),
        aws_access_key_id="test",
        aws_secret_access_key="test"
    )

def init_db():
    conn = get_db()
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS messages (
            id SERIAL PRIMARY KEY,
            content TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    conn.commit()
    cur.close()
    conn.close()

@app.route("/")
def home():
    return jsonify({
        "app": "Nagaram",
        "status": "Running",
        "environment": os.environ.get("ENVIRONMENT", "dev")
    })

@app.route("/health")
def health():
    return jsonify({
        "status": "Healthy"
    })

@app.route("/messages", methods=["GET"])
def get_messages():
    conn = get_db()
    cur = conn.cursor()
    cur.execute("""
        SELECT id, content, created_at
        FROM messages
        ORDER BY created_at DESC
    """)
    rows = cur.fetchall()
    cur.close()
    conn.close()

    messages = [
        {"id": r[0], "content":r[1], "created_at": str(r[2])}
        for r in rows
    ]
    return jsonify(messages)

@app.route("/messages", methods=["POST"])
def create_message():
    data = request.get_json()
    content = data.get("content")

    conn = get_db()
    cur = conn.cursor()
    cur.execute("""
        INSERT INTO messages
        (content) VALUES (%s) RETURNING id
    """, (content,))
    message_id = cur.fetchone()[0]
    conn.commit()
    cur.close()
    conn.close()

    sqs = get_sqs()
    sqs.send_message(
        QueueUrl = os.environ.get("QUEUE_URL"),
        MessageBody = json.dumps({
            "id": message_id,
            "content": content
        })
    )

    s3 = get_s3()
    s3.put_object(
        Bucket = os.environ.get("S3_BUCKET"),
        Key = f"messages/{message_id}.json",
        Body = json.dumps({
            "id": message_id,
            "content": content
        })
    )

    return jsonify({
        "id": message_id,
        "content": content,
        "saved_to": ["postgres", "sqs", "s3"]
    }), 201


if __name__ == "__main__":
    init_db()
    app.run(host="0.0.0.0", port=5000, debug=True)