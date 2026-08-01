#!/bin/bash

while IFS=, read -r name ip status port service cpu uptime; do
	case "$status" in 
		running) echo "ok" ;;
		stopped) echo "down" ;;
	esac
done < bash-lab/data/fleet.txt
