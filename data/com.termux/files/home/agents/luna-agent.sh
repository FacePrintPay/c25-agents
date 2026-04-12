#!/data/data/com.termux/files/usr/bin/bash
PROMPT="${C25_PROMPT:-ready}"
echo "[luna] ACTIVE: $PROMPT"
case "${PROMPT,,}" in
  *build*) find ~/github-repos -maxdepth 3 -name ".git" 2>/dev/null | wc -l | xargs echo "[luna] repos:" ;;
  *push*)  echo "[luna] pushing..." ;;
  *scan*)  echo "[luna] scanning..." ;;
  *)       echo "[luna] standing by" ;;
esac
