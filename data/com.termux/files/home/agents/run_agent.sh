#!/data/data/com.termux/files/usr/bin/bash
C25="$HOME/constellation25"
LOGS="$C25/logs"
AGENT="${1:-all}"
TS=$(date "+%Y-%m-%d %H:%M:%S")

AGENTS=(earth mercury venus mars jupiter saturn uranus neptune pluto luna
        sol sirius vega rigel pleiades orion hydra lyra cygnus andromeda
        perseus cassiopeia aquila draco fomalhaut)

start_agent(){
  local NAME="$1"
  local SCRIPT="$C25/agents/$NAME.sh"
  if [ -f "$SCRIPT" ]; then
    bash "$SCRIPT" &
    echo "  🟢 $NAME started (PID $!)"
    echo "$!" > "$C25/agents/$NAME.pid"
    echo "[$TS] [RUN_AGENT] [$NAME] PID:$! STARTED" >> "$LOGS/constellation25.log"
  else
    echo "  ⚡ $NAME — no script, running heartbeat"
    (while true; do
      echo "[$( date '+%Y-%m-%d %H:%M:%S')] [$NAME] HEARTBEAT" >> "$LOGS/constellation25.log"
      sleep 60
    done) &
    echo "$!" > "$C25/agents/$NAME.pid"
    echo "[$TS] [RUN_AGENT] [$NAME] PID:$! HEARTBEAT" >> "$LOGS/constellation25.log"
  fi
}

echo "╔══════════════════════════════════════════════╗"
echo "║   CONSTELLATION25 — AGENT RUNNER            ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "  Target: $AGENT"
echo "  Time  : $TS"
echo ""

if [ "$AGENT" = "all" ]; then
  for A in "${AGENTS[@]}"; do
    start_agent "$A"
  done
  echo ""
  echo "  ✅ All 25 agents started"
else
  start_agent "$AGENT"
fi

echo ""
echo "  Log: $LOGS/constellation25.log"
echo "  PIDs: $C25/agents/*.pid"
