#!/bin/bash
set -euo pipefail

VAULT="/sdcard/Obsidian/C25-Database-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$VAULT"/{termux,sdcard,repos,logs}

# Scan entire database
find ~ -type f 2>/dev/null | while read file; do
  sha256sum "$file" >> "$VAULT/database.manifest"
  cp --parents "$file" "$VAULT/termux/" 2>/dev/null || true
done

find /sdcard -type f 2>/dev/null | while read file; do
  sha256sum "$file" >> "$VAULT/database.manifest"
  cp --parents "$file" "$VAULT/sdcard/" 2>/dev/null || true
done

# Find all repos
find ~ /sdcard -name ".git" -type d 2>/dev/null | while read git; do
  repo="${git%/.git}"
  tar -czf "$VAULT/repos/$(basename $repo).tar.gz" -C "$(dirname $repo)" "$(basename $repo)"
done

# Generate report
cat > "$VAULT/REPORT.json" << EOF
{
  "agent": "cygnus",
  "timestamp": "$(date -Iseconds)",
  "files_scanned": $(wc -l < "$VAULT/database.manifest"),
  "repos_archived": $(ls -1 "$VAULT/repos" | wc -l),
  "vault_location": "$VAULT"
}
EOF

echo "Cygnus complete: $VAULT"
