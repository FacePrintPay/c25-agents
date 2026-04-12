#!/data/data/com.termux/files/usr/bin/bash
PROMPT="${C25_PROMPT:-ready}"
echo "[neptune] ACTIVE: $PROMPT"
case "${PROMPT,,}" in
  *build*) find ~/github-repos -maxdepth 3 -name ".git" 2>/dev/null | wc -l | xargs echo "[neptune] repos:" ;;
  *push*)  echo "[neptune] pushing..." ;;
  *scan*)  echo "[neptune] scanning..." ;;
  *)       echo "[neptune] standing by" ;;
esac
