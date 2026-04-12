#!/data/data/com.termux/files/usr/bin/bash
PROMPT="${C25_PROMPT:-ready}"
echo "[uranus] ACTIVE: $PROMPT"
case "${PROMPT,,}" in
  *build*) find ~/github-repos -maxdepth 3 -name ".git" 2>/dev/null | wc -l | xargs echo "[uranus] repos:" ;;
  *push*)  echo "[uranus] pushing..." ;;
  *scan*)  echo "[uranus] scanning..." ;;
  *)       echo "[uranus] standing by" ;;
esac
