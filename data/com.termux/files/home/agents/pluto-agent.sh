#!/data/data/com.termux/files/usr/bin/bash
PROMPT="${C25_PROMPT:-ready}"
echo "[pluto] ACTIVE: $PROMPT"
case "${PROMPT,,}" in
  *build*) find ~/github-repos -maxdepth 3 -name ".git" 2>/dev/null | wc -l | xargs echo "[pluto] repos:" ;;
  *push*)  echo "[pluto] pushing..." ;;
  *scan*)  echo "[pluto] scanning..." ;;
  *)       echo "[pluto] standing by" ;;
esac
