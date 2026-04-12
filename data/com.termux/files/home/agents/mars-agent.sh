#!/data/data/com.termux/files/usr/bin/bash
PROMPT="${C25_PROMPT:-ready}"
echo "[mars] ACTIVE: $PROMPT"
case "${PROMPT,,}" in
  *build*) find ~/github-repos -maxdepth 3 -name ".git" 2>/dev/null | wc -l | xargs echo "[mars] repos:" ;;
  *push*)  echo "[mars] pushing..." ;;
  *scan*)  echo "[mars] scanning..." ;;
  *)       echo "[mars] standing by" ;;
esac
