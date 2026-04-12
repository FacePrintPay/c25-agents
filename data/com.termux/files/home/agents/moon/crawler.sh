#!/bin/bash
AGENT_NAME=$(basename $(dirname $0))
SYNC_DB=~/.constellation25/sync.db

crawl_and_fix() {
  # Find all scripts in agent directory
  find ~/agents/$AGENT_NAME -name "*.sh" -type f | while read script; do
    # Syntax check
    if ! bash -n "$script" 2>/dev/null; then
      # Auto-fix
      sed -i 's/\r$//;1{/^#!/!s/^/#!/bin\/bash\n/}' "$script"
      sed -i '2{/^set -/!s/^/set -euo pipefail\n/}' "$script"
      echo "$(date -Iseconds) FIXED: $script" >> ~/logs/${AGENT_NAME}-fixes.log
    fi
    
    # Make executable
    chmod +x "$script"
  done
  
  # Check dependencies
  for cmd in jq rsync find; do
    command -v $cmd >/dev/null || pkg install -y $cmd 2>&1 | tee -a ~/logs/${AGENT_NAME}-deps.log
  done
  
  # Update sync status
  jq --arg agent "$AGENT_NAME" --arg time "$(date -Iseconds)" \
    '.agents[$agent] = {last_check: $time, status: "healthy"}' \
    $SYNC_DB > $SYNC_DB.tmp && mv -f $SYNC_DB.tmp $SYNC_DB 2>/dev/null || true
}

# Run continuously
while true; do
  crawl_and_fix
  sleep 600  # Every 10 minutes
done
