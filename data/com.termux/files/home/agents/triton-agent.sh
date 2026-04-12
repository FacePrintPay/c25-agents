#!/data/data/com.termux/files/usr/bin/bash
PROMPT="${C25_PROMPT:-ready}"
echo "[triton] ACTIVE: $PROMPT"
case "${PROMPT,,}" in
  *build*) find ~/github-repos -maxdepth 3 -name ".git" 2>/dev/null | wc -l | xargs echo "[triton] repos:" ;;
  *push*)  echo "[triton] pushing..." ;;
  *scan*)  echo "[triton] scanning..." ;;
  *)       echo "[triton] standing by" ;;
esac
