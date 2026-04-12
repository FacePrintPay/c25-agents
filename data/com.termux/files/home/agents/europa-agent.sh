#!/data/data/com.termux/files/usr/bin/bash
PROMPT="${C25_PROMPT:-ready}"
echo "[europa] ACTIVE: $PROMPT"
case "${PROMPT,,}" in
  *build*) find ~/github-repos -maxdepth 3 -name ".git" 2>/dev/null | wc -l | xargs echo "[europa] repos:" ;;
  *push*)  echo "[europa] pushing..." ;;
  *scan*)  echo "[europa] scanning..." ;;
  *)       echo "[europa] standing by" ;;
esac
