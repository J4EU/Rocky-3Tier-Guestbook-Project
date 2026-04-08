from fastapi import FastAPI
from pydantic import BaseModel
from dotenv import load_dotenv
import mysql.connector
import os

app = FastAPI()

load_dotenv()

db_config = {
    "host": os.getenv("DB_HOST"),
    "user": os.getenv("DB_USER"),
    "password": os.getenv("DB_PASS"),
    "database": os.getenv("DB_NAME")
}

class Entry(BaseModel):
    content: str

@app.get("/")
def read_root():
    return {"message": "WAS Server is Running!"}

@app.get("/messages")
def get_messages():
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()
        cursor.execute("SELECT content FROM entries")
        result = cursor.fetchall()
        cursor.close()
        conn.close()
        return {"messages": [row[0] for row in result]}
    except Exception as e:
        return {"error": str(e)}

@app.post("/messages")
def add_message(entry: Entry):
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()
        cursor.execute("INSERT INTO entries (content) VALUES (%s)", (entry.content,))
        conn.commit()
        cursor.close()
        conn.close()
        return {"status": "success"}
    except Exception as e:
        return {"error": str(e)}