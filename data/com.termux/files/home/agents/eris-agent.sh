#!/data/data/com.termux/files/usr/bin/bash
PROMPT="${C25_PROMPT:-ready}"
echo "[eris] ACTIVE: $PROMPT"
case "${PROMPT,,}" in
  *build*) find ~/github-repos -maxdepth 3 -name ".git" 2>/dev/null | wc -l | xargs echo "[eris] repos:" ;;
  *push*)  echo "[eris] pushing..." ;;
  *scan*)  echo "[eris] scanning..." ;;
  *)       echo "[eris] standing by" ;;
esac
