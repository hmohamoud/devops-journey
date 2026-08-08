#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/../config/toolkit.conf"
source "$(dirname "$0")/../lib/common.sh"
report_file="$REPORT_DIR/health-check-report-$(timestamp).log"
count_healthy=0
count_warning=0
count_down=0
trap 'echo "Health check complete. Healthy: $count_healthy, Warning: $count_warning, Down: $count_down"' EXIT
trap 'log_error "health-check.sh failed at line $LINENO"' ERR


if ! require_file "$FLEET_FILE"; then
	exit 1
fi

zero_lines=$(wc -l < "$FLEET_FILE")

if [ "$zero_lines" -eq 0 ]; then
	log_error "File was empty - No servers found" 
	exit 1
fi


classify_health() {
	local result
	if [ "$1" == "stopped" ] || [ "$1" == "failed" ]; then
		result="DOWN"
	elif [ "$1" == "running" ] && [ "$2" -ge "$CPU_WARNING_THRESHOLD" ]; then
		result="WARNING"
	elif [ "$1" == "running" ] && [ "$2" -lt "$CPU_WARNING_THRESHOLD" ]; then
		result="HEALTHY" 
	fi
	echo "$result"
} 

while IFS=, read -r name ip status port service cpu uptime; do
	if [ -z "$name" ] || [ -z "$ip" ] || [ -z "$status" ] || [ -z "$port" ] || [ -z "$service" ] || [ -z "$cpu" ] || [ -z "$uptime" ]; then
		 log_error "Malformed line skipped: $name,$ip,$status,$port,$service,$cpu,$uptime"
		 continue
	fi
	health=$(classify_health "$status" "$cpu")
	echo "$name | $status | $cpu | $health" >> "$report_file"	
	if [ "$health" == "HEALTHY" ]; then
		count_healthy=$((count_healthy + 1))
	elif [ "$health" == "WARNING" ]; then
		count_warning=$((count_warning + 1))
	elif [ "$health" == "DOWN" ]; then
		count_down=$((count_down + 1))
	fi
done < "$FLEET_FILE"

echo "Healthy: $count_healthy" >> "$report_file"
echo "Warning: $count_warning" >> "$report_file"
echo "Down: $count_down" >> "$report_file"

if [ "$count_down" -gt 0 ]; then
    exit 1
else
	exit 0
fi