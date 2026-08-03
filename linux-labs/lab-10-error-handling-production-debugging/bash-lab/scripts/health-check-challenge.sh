#!/bin/bash
set -euo pipefail

servers_checked=0
down_count=0
tempfile=$(mktemp)

logfile="bash-lab/logs/health-check-challenge.log"

# EXIT trap: always runs
cleanup() {
    rm -f "$tempfile"
    echo "Summary: $servers_checked servers checked, $down_count servers down"
}

trap cleanup EXIT

# ERR trap: logs failure line
trap 'echo "Error on line $LINENO" >> "$logfile"' ERR


# Argument validation
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <server_file>"
    exit 2
fi

if [ ! -f "$1" ]; then
    echo "Error: file does not exist: $1"
    exit 1
fi


# Create log file
mkdir -p bash-lab/logs

touch "$logfile" 2>/dev/null && echo "Log ready: $logfile" || {
    echo "Cannot write log file"
    exit 1
}


# Function to classify server status
is_running() {
    local status="$1"

    if [ "$status" = "running" ]; then
        return 0
    else
        return 1
    fi
}


# Count stopped/failed servers
down_count=$(grep -c ",stopped\|,failed" "$1") || down_count=0


# Process servers
while IFS=, read -r name ip status port service cpu uptime
do
    servers_checked=$((servers_checked + 1))

    if is_running "$status"; then
        echo "$name ($ip) is UP" >> "$logfile"
    else
        echo "$name ($ip) is DOWN" >> "$logfile"
    fi

done < "$1"


# Force failure test (remove this after testing)
# false


# Final result
if [ "$down_count" -gt 0 ]; then
    exit 3
fi

exit 0
