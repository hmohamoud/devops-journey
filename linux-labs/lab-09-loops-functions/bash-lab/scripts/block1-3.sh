#!/bin/bash


while IFS=, read -r name ip status port service cpu uptime; do
	echo "$name : ${cpu}%"
done < bash-lab/data/fleet.txt

echo "Alternative 2"


while IFS=, read -r name ip status port service cpu uptime; do
        printf "%s: %s%%\n" "$name" "$cpu"
done < bash-lab/data/fleet.txt
