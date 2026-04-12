#!/data/data/com.termux/files/usr/bin/bash
PROMPT="${C25_PROMPT:-ready}"
echo "[sol] ACTIVE: $PROMPT"
case "${PROMPT,,}" in
  *build*) find ~/github-repos -maxdepth 3 -name ".git" 2>/dev/null | wc -l | xargs echo "[sol] repos:" ;;
  *push*)  echo "[sol] pushing..." ;;
  *scan*)  echo "[sol] scanning..." ;;
  *)       echo "[sol] standing by" ;;
esac
