from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import sqlite3
import requests
import json
import os
from datetime import datetime

app = FastAPI(title="Constellation25 Sovereign Node")

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

DB_NAME = "sovereign.db"
OLLAMA_URL = "http://localhost:11434/api/generate"

def init_db():
    conn = sqlite3.connect(DB_NAME)
    c = conn.cursor()
    c.execute('''CREATE TABLE IF NOT EXISTS agents (id INTEGER PRIMARY KEY, name TEXT, role TEXT, status TEXT, duty TEXT, port INTEGER)''')
    c.execute('''CREATE TABLE IF NOT EXISTS modules (id INTEGER PRIMARY KEY, name TEXT, price REAL, status TEXT, description TEXT)''')
    c.execute('''CREATE TABLE IF NOT EXISTS logs (id INTEGER PRIMARY KEY, agent_name TEXT, prompt TEXT, response TEXT, served_action TEXT, timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP)''')
    
    # Seed Data
    c.execute("SELECT count(*) FROM agents")
    if c.fetchone()[0] == 0:
        agents = [
            ('Architect', 'System Design', 'Online', 'Indexing APIs', 8001), 
            ('Sentinel', 'Security', 'Online', 'Monitoring', 8002), 
            ('Jupiter', 'Orchestration', 'Online', 'Swarm Mgmt', 8006)
        ]
        c.executemany("INSERT INTO agents (name, role, status, duty, port) VALUES (?,?,?,?,?)", agents)
        
        modules = [
            ('VideoCourts', 5000.00, 'Active', 'Legal'), 
            ('MyBUYo', 2500.00, 'Active', 'Commerce')
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

@app.post("/api/v1/prompt")
async def handle_prompt(req: PromptRequest):
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()
    
    ai_response_raw = "Ollama Offline."
    served_action = "None"
    
    # 1. CALL LOCAL QWEN (OLLAMA)
    try:
        payload = {
            "model": "qwen", 
            "prompt": f"You are Agent {req.agent_name}. User Command: '{req.prompt}'. Respond with a concise action plan or answer.", 
            "stream": False
        }
        resp = requests.post(OLLAMA_URL, json=payload, timeout=30)
        if resp.status_code == 200:
            ai_response_raw = resp.json().get('response', 'No output.')
            # 2. DETERMINE SERVED ACTION
            if "status" in ai_response_raw.lower() or "list" in ai_response_raw.lower():
                served_action = "QUERY_EXECUTED"
            elif "deploy" in ai_response_raw.lower():
                served_action = "DEPLOY_TRIGGERED"
            else:
                served_action = "LOGGED_RESPONSE"
        else:
            ai_response_raw = f"AI Error: {resp.text}"
    except Exception as e:
        ai_response_raw = f"Connection Error: {str(e)}"

    # 3. SERVE & LOG THE RESULT
    final_resp = f"[{req.agent_name}] {ai_response_raw}"
    cursor.execute("INSERT INTO logs (agent_name, prompt, response, served_action) VALUES (?, ?, ?, ?)", 
                   (req.agent_name, req.prompt, final_resp, served_action))
    conn.commit()
    conn.close()
    
    # 4. RETURN STRUCTURED DATA
    return JSONResponse(content={
        "status": "success", 
        "response": final_resp, 
        "action_served": served_action,
        "timestamp": datetime.now().isoformat()
    })

@app.get("/api/v1/logs")
def get_logs():
    conn = sqlite3.connect(DB_NAME)
    conn.row_factory = sqlite3.Row
    data = conn.execute("SELECT * FROM logs ORDER BY timestamp DESC LIMIT 50").fetchall()
    conn.close()
    return [dict(ix) for ix in data]

@app.get("/api/v1/agents")
def get_agents():
    conn = sqlite3.connect(DB_NAME)
    conn.row_factory = sqlite3.Row
    data = conn.execute("SELECT * FROM agents").fetchall()
    conn.close()
    return [dict(ix) for ix in data]

if __name__ == "__main__":
    import uvicorn
    print("STARTING SOVEREIGN NODE WITH SERVE LOGIC ON http://0.0.0.0:8000")
    uvicorn.run(app, host="0.0.0.0", port=8000)
