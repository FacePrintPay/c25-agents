#!/data/data/com.termux/files/usr/bin/bash
PROMPT="${C25_PROMPT:-ready}"
echo "[deimos] ACTIVE: $PROMPT"
case "${PROMPT,,}" in
  *build*) find ~/github-repos -maxdepth 3 -name ".git" 2>/dev/null | wc -l | xargs echo "[deimos] repos:" ;;
  *push*)  echo "[deimos] pushing..." ;;
  *scan*)  echo "[deimos] scanning..." ;;
  *)       echo "[deimos] standing by" ;;
esac
