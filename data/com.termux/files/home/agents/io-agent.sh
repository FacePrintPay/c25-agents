#!/data/data/com.termux/files/usr/bin/bash
PROMPT="${C25_PROMPT:-ready}"
echo "[io] ACTIVE: $PROMPT"
case "${PROMPT,,}" in
  *build*) find ~/github-repos -maxdepth 3 -name ".git" 2>/dev/null | wc -l | xargs echo "[io] repos:" ;;
  *push*)  echo "[io] pushing..." ;;
  *scan*)  echo "[io] scanning..." ;;
  *)       echo "[io] standing by" ;;
esac
