#!/data/data/com.termux/files/usr/bin/bash
PROMPT="${C25_PROMPT:-ready}"
echo "[enceladus] ACTIVE: $PROMPT"
case "${PROMPT,,}" in
  *build*) find ~/github-repos -maxdepth 3 -name ".git" 2>/dev/null | wc -l | xargs echo "[enceladus] repos:" ;;
  *push*)  echo "[enceladus] pushing..." ;;
  *scan*)  echo "[enceladus] scanning..." ;;
  *)       echo "[enceladus] standing by" ;;
esac
