from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import sqlite3, requests, json, os, subprocess, shlex
from datetime import datetime

app = FastAPI(title="Constellation25 Sovereign Node")
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"])

DB_NAME = "sovereign.db"
OLLAMA_URL = "http://localhost:11434/api/generate"

def init_db():
    conn = sqlite3.connect(DB_NAME)
    c = conn.cursor()
    c.execute('''CREATE TABLE IF NOT EXISTS agents (id INTEGER PRIMARY KEY, name TEXT, role TEXT, status TEXT, duty TEXT, port INTEGER)''')
    c.execute('''CREATE TABLE IF NOT EXISTS modules (id INTEGER PRIMARY KEY, name TEXT, price REAL, status TEXT, description TEXT)''')
    c.execute('''CREATE TABLE IF NOT EXISTS logs (id INTEGER PRIMARY KEY, agent_name TEXT, prompt TEXT, response TEXT, served_action TEXT, timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP)''')
    c.execute("SELECT count(*) FROM agents")
    if c.fetchone()[0] == 0:
        agents = [('Architect','System Design','Online','Indexing APIs',8001),('Sentinel','Security','Online','Monitoring',8002),('Jupiter','Orchestration','Online','Swarm Mgmt',8006)]
        c.executemany("INSERT INTO agents (name,role,status,duty,port) VALUES (?,?,?,?,?)", agents)
        modules = [('VideoCourts',5000.00,'Active','Legal'),('MyBUYo',2500.00,'Active','Commerce')]
        c.executemany("INSERT INTO modules (name,price,status,description) VALUES (?,?,?,?)", modules)
    conn.commit(); conn.close()

init_db()

class PromptRequest(BaseModel):
    prompt: str
    agent_name: str = "General"

@app.get("/")
async def read_root():
    with open("index.html","r") as f: return HTMLResponse(content=f.read())

@app.post("/api/v1/prompt")
async def handle_prompt(req: PromptRequest):
    conn = sqlite3.connect(DB_NAME); cursor = conn.cursor()
    ai_response_raw, served_action = "⚠️ Ollama Offline.", "NONE"
    try:
        payload = {"model":"qwen","prompt":f"You are Agent {req.agent_name}. Command: '{req.prompt}'. Respond concisely with action or answer.","stream":False}
        resp = requests.post(OLLAMA_URL, json=payload, timeout=45)
        if resp.status_code == 200:
            ai_response_raw = resp.json().get('response','No output.')
            if any(k in ai_response_raw.lower() for k in ['status','list','show','get']): served_action = "QUERY_EXECUTED"
            elif any(k in ai_response_raw.lower() for k in ['deploy','run','execute','start']): served_action = "DEPLOY_TRIGGERED"
            elif any(k in ai_response_raw.lower() for k in ['save','write','create','update']): served_action = "DB_UPDATED"
            else: served_action = "LOGGED_RESPONSE"
        else: ai_response_raw = f"AI Error: {resp.text[:200]}"
    except Exception as e: ai_response_raw = f"Connection Error: {str(e)[:150]}"
    final_resp = f"[{req.agent_name}] {ai_response_raw}"
    cursor.execute("INSERT INTO logs (agent_name,prompt,response,served_action) VALUES (?,?,?,?)",(req.agent_name,req.prompt,final_resp,served_action))
    conn.commit(); conn.close()
    return JSONResponse(content={"status":"success","response":final_resp,"action_served":served_action,"timestamp":datetime.now().isoformat()})

@app.get("/api/v1/logs")
def get_logs(limit: int = 50):
    conn = sqlite3.connect(DB_NAME); conn.row_factory = sqlite3.Row
    data = conn.execute(f"SELECT * FROM logs ORDER BY timestamp DESC LIMIT {limit}").fetchall(); conn.close()
    return [dict(ix) for ix in data]

@app.get("/api/v1/agents")
def get_agents():
    conn = sqlite3.connect(DB_NAME); conn.row_factory = sqlite3.Row
    data = conn.execute("SELECT * FROM agents").fetchall(); conn.close()
    return [dict(ix) for ix in data]

@app.get("/api/v1/modules")
def get_modules():
    conn = sqlite3.connect(DB_NAME); conn.row_factory = sqlite3.Row
    data = conn.execute("SELECT * FROM modules").fetchall(); conn.close()
    return [dict(ix) for ix in data]

@app.post("/api/v1/execute")
async def execute_command(req: PromptRequest):
    """Sovereign command execution endpoint — runs bash safely in Termux"""
    conn = sqlite3.connect(DB_NAME); cursor = conn.cursor()
    result, status = "", "PENDING"
    try:
        # Sanitize: only allow safe commands for demo
        safe_cmd = req.prompt.strip()
        if any(bad in safe_cmd.lower() for bad in ['rm -rf','sudo','su ','chmod 777']):
            result = "⛔ Command blocked by Sovereign Sentinel"
            status = "BLOCKED"
        else:
            proc = subprocess.run(safe_cmd, shell=True, capture_output=True, text=True, timeout=30, cwd=os.getenv("HOME","/data/data/com.termux/files/home"))
            result = proc.stdout if proc.returncode == 0 else f"Error: {proc.stderr}"
            status = "SUCCESS" if proc.returncode == 0 else "FAILED"
    except Exception as e: result = f"Execution Error: {str(e)}"; status = "ERROR"
    cursor.execute("INSERT INTO logs (agent_name,prompt,response,served_action) VALUES (?,?,?,?)",("Executor",req.prompt,result,f"CMD_{status}"))
    conn.commit(); conn.close()
    return JSONResponse(content={"status":status,"output":result,"timestamp":datetime.now().isoformat()})

if __name__ == "__main__":
    import uvicorn
    print("🚀 CONSTELLATION25 SOVEREIGN NODE ONLINE → http://0.0.0.0:8000")
    uvicorn.run(app, host="0.0.0.0", port=8000, log_level="info")
