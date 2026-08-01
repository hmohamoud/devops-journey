#!/bin/bash

while IFS=, read -r name ip status port service cpu uptime; do
	if [ "$status" == "running" ]; then
		echo "$name is running"
	elif [ "$status" == "stopped" ]; then
		echo "$name is stopped"
	elif [ "$status" == "failed" ]; then
		echo "$name is failed"
	else
		echo "$name is unknown"
	fi
	
	case "$service" in
		nginx|proxy*) tier="web" ;;
		postgres|redis) tier="data" ;;
        	auth-service|job-worker|prometheus) tier="support" ;;
        	*) tier="other" ;;
	esac
	echo "$name : $tier"	

	if [[ "$ip" =~ ^192\.168\.1\.[0-6][0-9]$ ]]' ]]; then
		echo "$name ($ip) is in range"
	fi

done < bash-lab/data/fleet.txt
