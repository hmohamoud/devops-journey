#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/../config/toolkit.conf"
source "$(dirname "$0")/../lib/common.sh"

trap 'echo "Toolkit run complete."' EXIT
trap 'log_error "toolkit.sh failed at line $LINENO"' ERR

if [ "$#" -gt 1 ]; then
    echo "Usage: ./toolkit.sh {audit|logs|health}"
    exit 2
fi

subcommand="${1:-}"

case "$subcommand" in
    audit)
        exec "$(dirname "$0")/system-audit.sh"
        ;;
    logs)
        exec "$(dirname "$0")/log-scanner.sh"
        ;;
    health)
        exec "$(dirname "$0")/health-check.sh"
        ;;
    *)
        echo "Usage: ./toolkit.sh {audit|logs|health}"
        exit 2
        ;;
esac