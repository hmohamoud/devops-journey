#!/bin/bash

while IFS=, read -r name ip status port service cpu uptime; do
	if [ "$status" == "running" ]; then
		echo "$name is UP"
	elif [ "$status" == "failed" ]; then
		echo "$name is FAILED"
	else
		echo "$name is DOWN"
	fi
done < bash-lab/data/fleet.txt

while IFS=, read -r name ip status port service cpu uptime; do
	case "$service" in
		nginx|proxy*) tier="web" ;;
		postgres|redis) tier="data" ;;
		*) tier="other" ;;
	esac 
		
done < bash-lab/data/fleet.txt

while IFS=, read -r name ip status port service cpu uptime; do
    if [[ $ip =~ ^192\.168\.1\.(1|2)[0-9]$ ]]; then
        echo "$name ($ip) is in the .10-.29 range"
    fi
done < bash-lab/data/fleet.txt

while IFS=, read -r name ip status port service cpu uptime; do
	if [ "$status" == "running" ]  && [ "$cpu" -gt 50 ]; then
		echo "$name is running with high load ($cpu%)"
	fi
done < bash-lab/data/fleet.txt
