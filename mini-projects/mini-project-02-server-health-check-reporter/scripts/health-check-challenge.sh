#!/bin/bash
set -euo pipefail

fleet_file="${1:-data/servers.txt}"
timestamp=$(date +%Y-%m-%d_%H-%M-%S)
report_file="reports/report-$timestamp.txt"
error_file="errors/error-$timestamp.log"

mkdir -p reports errors

if [ "$#" -gt 1 ]; then
    echo "Usage: $0 [server-file]" >> "$error_file"
    exit 2
fi

count_h=0
count_w=0
count_d=0
trap 'echo "Health check complete. Healthy: $count_h, Warning: $count_w, Down: $count_d" ' EXIT
trap 'echo "Error on line $LINENO" >> "$error_file"' ERR
if [ ! -f "$fleet_file" ]; then
	echo "File doesn't exist" >> "$error_file"
	exit 1
fi

zero_lines=$(wc -l < "$fleet_file")
if [ "$zero_lines" -eq 0 ]; then
    echo "Input file missing or empty" >> "$error_file"
    exit 1
fi

classify_health() {
	local result
	if [ "$1" == "stopped" ] || [ "$1" == "failed" ]; then
		result="DOWN"
	elif [ "$1" == "running" ] && [ "$2" -ge 80 ]; then
		result="WARNING"
	elif [ "$1" == "running" ] && [ "$2" -lt 80 ]; then
		result="HEALTHY" 
	fi
	echo "$result"
}

echo "REPORT - $timestamp" > "$report_file"

while IFS=, read -r name ip status port service cpu uptime; do
	if [ -z "$name" ] || [ -z "$ip" ] || [ -z "$status" ] || [ -z "$port" ] || [ -z "$service" ] || [ -z "$cpu" ] || [ -z "$uptime" ]; then
		echo "Malformed line: $name,$ip,$status,$port,$service,$cpu,$uptime" >> "$error_file"
		continue
	fi
	health=$(classify_health "$status" "$cpu")
	echo "$name | $status | $cpu | $health" >> "$report_file"	
	if [ "$health" == "HEALTHY" ]; then
		count_h=$((count_h + 1))
	elif [ "$health" == "WARNING" ]; then
		count_w=$((count_w + 1))
	elif [ "$health" == "DOWN" ]; then
		count_d=$((count_d + 1))
	fi
done < "$fleet_file"

if [ "$count_d" -gt 0 ]; then
    exit 1
fi

exit 0


	
