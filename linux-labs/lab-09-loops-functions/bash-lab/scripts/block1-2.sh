#!/bin/bash

while IFS=, read -r name ip status port service cpu uptime; do
	if [ "$status" == "running" ]; then
		echo "$name"
	fi
done < bash-lab/data/fleet.txt
