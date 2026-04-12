#!/data/data/com.termux/files/usr/bin/bash
# Constellation25 Agent Cleanup Script

LOG_DIR="$HOME/constellation25/logs"

echo "Cleaning up previous agent processes..."

# Kill any existing agent processes
pkill -f "-agent.sh" 2>/dev/null || true

# Clean up PID files
rm -f "$LOG_DIR"/*.pid 2>/dev/null || true

# Brief pause for system to release resources
sleep 2

echo "Cleanup complete"
