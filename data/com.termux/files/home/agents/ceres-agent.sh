#!/data/data/com.termux/files/usr/bin/bash
PROMPT="${C25_PROMPT:-ready}"
echo "[ceres] ACTIVE: $PROMPT"
case "${PROMPT,,}" in
  *build*) find ~/github-repos -maxdepth 3 -name ".git" 2>/dev/null | wc -l | xargs echo "[ceres] repos:" ;;
  *push*)  echo "[ceres] pushing..." ;;
  *scan*)  echo "[ceres] scanning..." ;;
  *)       echo "[ceres] standing by" ;;
esac
