#!/bin/bash

while IFS=, read -r name ip status port service cpu uptime; do
	if [ "$status" == "stopped" ] || [ "$status == "running" ]; then
		continue
	else
		echo "$name"
	fi

	if [ "$cup" -gt 90 ]; then
		echo "CPU usage is critically high"
		break
	else
		echo "@$name"
	fi
done < bash-lab/data/fleet.txt
	
for s in nginx postgres redis; do
	for i in disk memory cpu; do
		if [ "$i" == memory" ]; then
			echo "$s - "$i"
			break
		fi
	done

			
