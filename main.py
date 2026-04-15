from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import sqlite3
import requests
import json
import os
from datetime import datetime

app = FastAPI(title="Constellation25 Local Sovereign Node")

# CORS for local access
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

DB_NAME = "sovereign.db"
OLLAMA_URL = "http://localhost:11434/api/generate" # Default Ollama port

def init_db():
    conn = sqlite3.connect(DB_NAME)
    c = conn.cursor()
    
    c.execute('''CREATE TABLE IF NOT EXISTS agents (
        id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, role TEXT, status TEXT, duty TEXT, port INTEGER
    )''')
    c.execute('''CREATE TABLE IF NOT EXISTS modules (
        id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, price REAL, status TEXT, description TEXT
    )''')
    c.execute('''CREATE TABLE IF NOT EXISTS logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT, agent_name TEXT, prompt TEXT, response TEXT, timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )''')
    
    # Seed if empty
    c.execute("SELECT count(*) FROM agents")
    if c.fetchone()[0] == 0:
        agents = [
            ('Architect', 'System Design', 'Online', 'Indexing APIs', 8001),
            ('Sentinel', 'Security Ops', 'Online', 'Monitoring Threats', 8002),
            ('Jupiter', 'Orchestration', 'Online', 'Swarm Management', 8006),
            ('Mercury', 'API Gateway', 'Error', 'Webhook Timeout', 8007)
        ]
        c.executemany("INSERT INTO agents (name, role, status, duty, port) VALUES (?,?,?,?,?)", agents)
        
        modules = [
            ('VideoCourts', 5000.00, 'Active', 'Decentralized Legal'),
            ('MyBUYo', 2500.00, 'Active', 'Biometric Commerce'),
            ('FacePrint Pay', 0.00, 'Core', 'Sovereign Identity')
        ]
        c.executemany("INSERT INTO modules (name, price, status, description) VALUES (?,?,?,?)", modules)
    
    conn.commit()
    conn.close()

init_db()

class PromptRequest(BaseModel):
    prompt: str
    agent_name: str = "General"

@app.get("/")
async def read_root():
    with open("index.html", "r") as f:
        return HTMLResponse(content=f.read())

@app.get("/api/v1/agents")
def get_agents():
    conn = sqlite3.connect(DB_NAME)
    conn.row_factory = sqlite3.Row
    data = conn.execute("SELECT * FROM agents").fetchall()
    conn.close()
    return [dict(ix) for ix in data]

@app.get("/api/v1/modules")
def get_modules():
    conn = sqlite3.connect(DB_NAME)
    conn.row_factory = sqlite3.Row
    data = conn.execute("SELECT * FROM modules").fetchall()
    conn.close()
    return [dict(ix) for ix in data]

@app.post("/api/v1/prompt")
async def handle_prompt(req: PromptRequest):
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()
    
    ai_response = "️ Ollama/Qwen not reachable. Ensure 'ollama serve' is running."
    
    # TRY TO CALL LOCAL OLLAMA/QWEN
    try:
        payload = {
            "model": "qwen", # Or whatever model you pulled in Ollama
            "prompt": f"You are Agent {req.agent_name}. User says: {req.prompt}. Respond concisely.",
            "stream": False
        }
        resp = requests.post(OLLAMA_URL, json=payload, timeout=30)
        if resp.status_code == 200:
            ai_response = resp.json().get('response', 'No response generated.')
        else:
            ai_response = f"AI Error: {resp.text}"
    except Exception as e:
        ai_response = f"Connection Error: {str(e)} (Is Ollama running?)"

    # Save to DB
    final_resp = f"[{req.agent_name}] {ai_response}"
    cursor.execute("INSERT INTO logs (agent_name, prompt, response) VALUES (?, ?, ?)", 
                   (req.agent_name, req.prompt, final_resp))
    conn.commit()
    conn.close()
    
    return {"status": "success", "response": final_resp}

@app.get("/api/v1/logs")
def get_logs():
    conn = sqlite3.connect(DB_NAME)
    conn.row_factory = sqlite3.Row
    data = conn.execute("SELECT * FROM logs ORDER BY timestamp DESC LIMIT 50").fetchall()
    conn.close()
    return [dict(ix) for ix in data]

if __name__ == "__main__":
    import uvicorn
    print("🚀 STARTING SOVEREIGN NODE ON http://0.0.0.0:8000")
    uvicorn.run(app, host="0.0.0.0", port=8000)
