#!/bin/bash
set -euo pipefail
fleet_file="${1:-data/servers.txt}"
timestamp=$(date +%Y-%m-%d_%H-%M-%S)
error_file="errors/health-check-error-$timestamp.log"
report_file="reports/health-check-report-$timestamp.log"

trap 'echo "Health check complete. Healthy: $count_healthy, Warning: $count_warning, Down: $count_down"' EXIT 
trap 'echo "Error on line $LINENO"' ERR 
count_healthy=0
count_warning=0
count_down=0

validate_args(){
	local actual="$1"
	local required="$2"
	if [ "$actual" -gt "$required" ]; then
		echo "Usage: ./health-check.sh [FILE]" >> "$error_file"
		exit 2	
	fi
}


validate_args "$#" 1


if [ "$#" -ge 1 ] && [ "$fleet_file" == "-h" ] || [ "$fleet_file" == "--help" ]; then
	echo "Usage: ./health-check.sh [FILE]" >> "$error_file"
	exit 2
fi

if [ ! -f "$fleet_file" ]; then
	echo "$fleet_file - doesn't exist" >> "$error_file"
	exit 1
fi

zero_lines=$(wc -l < "$fleet_file")
if [ "$zero_lines" -eq 0 ]; then
	echo "File was empty - No servers found" >> "$error_file"
	exit 1
fi

is_healthy() {
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

echo "Server Health Check Report $timestamp" >> "$report_file"


while IFS=, read -r name ip status port service cpu uptime; do
	if [ -z "$name" ] || [ -z "$ip" ] || [ -z "$status" ] || [ -z "$port" ] || [ -z "$service" ] || [ -z "$cpu" ] || [ -z "$uptime" ]; then
		 echo "Malformed line skipped: $name,$ip,$status,$port,$service,$cpu,$uptime" >> "$error_file"
		 continue
	fi
	health=$(is_healthy "$status" "$cpu")
	if [ "$health" == "HEALTHY" ]; then
		count_healthy=$((count_healthy + 1))
	elif [ "$health" == "DOWN" ]; then	
		count_down=$((count_down + 1))
	elif [ "$health" == "WARNING" ]; then
		count_warning=$((count_warning + 1))
	fi	
	echo "$name | $status | $cpu | $health" >> "$report_file"
done < "$fleet_file"


echo "Healthy: $count_healthy" >> "$report_file"
echo "Warning: $count_warning" >> "$report_file"
echo "DOWN: $count_down" >> "$report_file"


if [ "$count_down" -gt 0 ]; then
	exit 1
else 
	exit 0
fi




