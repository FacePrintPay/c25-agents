#!/data/data/com.termux/files/usr/bin/bash
PROMPT="${C25_PROMPT:-ready}"
echo "[ganymede] ACTIVE: $PROMPT"
case "${PROMPT,,}" in
  *build*) find ~/github-repos -maxdepth 3 -name ".git" 2>/dev/null | wc -l | xargs echo "[ganymede] repos:" ;;
  *push*)  echo "[ganymede] pushing..." ;;
  *scan*)  echo "[ganymede] scanning..." ;;
  *)       echo "[ganymede] standing by" ;;
esac
