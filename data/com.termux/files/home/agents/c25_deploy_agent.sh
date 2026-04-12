#!/data/data/com.termux/files/usr/bin/bash
# c25_deploy_agent.sh -- Universal Deployment Agent
# Architect: Cygel White (TotalRecall)
# (c) 2026 Kre8tive Holdings -- Commercial License -- Not Open Source
# Usage: bash ~/c25_deploy_agent.sh <action> [domain] [source_dir]

ACTION="${1:-status}"
DOMAIN="${2:-}"
SOURCE="${3:-$HOME/c25-live/Constellation25-v3.0-DEPLOY/constellation}"

case "$ACTION" in
    deploy)
        if [[ -z "$DOMAIN" ]]; then
            printf "Usage: c25_deploy_agent.sh deploy <domain> [source_dir]\n"
            exit 1
        fi
        printf "Packaging %s from %s\n" "$DOMAIN" "$SOURCE"
        PKG="$HOME/C25_${DOMAIN}_$(date +%Y%m%d_%H%M).tar.gz"
        tar -czf "$PKG" -C "$(dirname "$SOURCE")" "$(basename "$SOURCE")"
        printf "Package ready: %s\n\n" "$PKG"
        printf "Upload options:\n"
        printf "  scp -r %s/* user@%s:/public_html/\n" "$SOURCE" "$DOMAIN"
        printf "  rsync -avz %s/ user@%s:/public_html/\n" "$SOURCE" "$DOMAIN"
        ;;
    status)
        printf "C25 Deploy Agent -- Status\n"
        printf "  Source : %s\n" "$SOURCE"
        COUNT=$(find "$SOURCE" -type f 2>/dev/null | wc -l || printf "?")
        printf "  Files  : %s\n" "$COUNT"
        ;;
    package)
        PKG="$HOME/C25_Package_$(date +%Y%m%d).tar.gz"
        tar -czf "$PKG" -C "$(dirname "$SOURCE")" "$(basename "$SOURCE")"
        printf "Package: %s\n" "$PKG"
        ;;
    *)
        printf "Usage: c25_deploy_agent.sh [deploy|status|package] [domain] [source]\n"
        ;;
esac
