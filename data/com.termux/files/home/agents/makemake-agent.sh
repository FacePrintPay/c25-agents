#!/data/data/com.termux/files/usr/bin/bash
PROMPT="${C25_PROMPT:-ready}"
echo "[makemake] ACTIVE: $PROMPT"
case "${PROMPT,,}" in
  *build*) find ~/github-repos -maxdepth 3 -name ".git" 2>/dev/null | wc -l | xargs echo "[makemake] repos:" ;;
  *push*)  echo "[makemake] pushing..." ;;
  *scan*)  echo "[makemake] scanning..." ;;
  *)       echo "[makemake] standing by" ;;
esac
