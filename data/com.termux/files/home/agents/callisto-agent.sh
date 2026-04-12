#!/data/data/com.termux/files/usr/bin/bash
PROMPT="${C25_PROMPT:-ready}"
echo "[callisto] ACTIVE: $PROMPT"
case "${PROMPT,,}" in
  *build*) find ~/github-repos -maxdepth 3 -name ".git" 2>/dev/null | wc -l | xargs echo "[callisto] repos:" ;;
  *push*)  echo "[callisto] pushing..." ;;
  *scan*)  echo "[callisto] scanning..." ;;
  *)       echo "[callisto] standing by" ;;
esac
