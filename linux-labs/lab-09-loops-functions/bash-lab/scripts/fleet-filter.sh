#!/bin/bash

while IFS=, read -r name ip status port service cpu uptime; do
	if [ "$status" == "stopped" ] || [ "$status" == "failed" ]; then
		continue
	elif [ "$cpu" -gt 90 ]; then
		echo "ALERT: $name has a critical cpu load ($cpu%)"
		break
	else
		echo "$name"
	fi
done < bash-lab/data/fleet.txt


for service in nginx,posgres,redis; do
	for resource in disk, memory, cpu; do
		echo "running $resource check"
		if [ "$resource" == "memory" ]; then
			break 2
		fi
	done
done
