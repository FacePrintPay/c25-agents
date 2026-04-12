#!/data/data/com.termux/files/usr/bin/bash
PROMPT="${C25_PROMPT:-ready}"
echo "[phobos] ACTIVE: $PROMPT"
case "${PROMPT,,}" in
  *build*) find ~/github-repos -maxdepth 3 -name ".git" 2>/dev/null | wc -l | xargs echo "[phobos] repos:" ;;
  *push*)  echo "[phobos] pushing..." ;;
  *scan*)  echo "[phobos] scanning..." ;;
  *)       echo "[phobos] standing by" ;;
esac
