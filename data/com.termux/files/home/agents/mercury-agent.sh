#!/data/data/com.termux/files/usr/bin/bash
PROMPT="${C25_PROMPT:-ready}"
echo "[mercury] ACTIVE: $PROMPT"
case "${PROMPT,,}" in
  *build*) find ~/github-repos -maxdepth 3 -name ".git" 2>/dev/null | wc -l | xargs echo "[mercury] repos:" ;;
  *push*)  echo "[mercury] pushing..." ;;
  *scan*)  echo "[mercury] scanning..." ;;
  *)       echo "[mercury] standing by" ;;
esac
