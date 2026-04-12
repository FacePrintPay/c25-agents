#!/data/data/com.termux/files/usr/bin/bash
PROMPT="${C25_PROMPT:-ready}"
echo "[venus] ACTIVE: $PROMPT"
case "${PROMPT,,}" in
  *build*) find ~/github-repos -maxdepth 3 -name ".git" 2>/dev/null | wc -l | xargs echo "[venus] repos:" ;;
  *push*)  echo "[venus] pushing..." ;;
  *scan*)  echo "[venus] scanning..." ;;
  *)       echo "[venus] standing by" ;;
esac
