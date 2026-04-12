#!/data/data/com.termux/files/usr/bin/bash
PROMPT="${C25_PROMPT:-ready}"
echo "[earth] ACTIVE: $PROMPT"
case "${PROMPT,,}" in
  *build*) find ~/github-repos -maxdepth 3 -name ".git" 2>/dev/null | wc -l | xargs echo "[earth] repos:" ;;
  *push*)  echo "[earth] pushing..." ;;
  *scan*)  echo "[earth] scanning..." ;;
  *)       echo "[earth] standing by" ;;
esac
