#!/bin/bash

server=()
while IFS=, read -r name ip status port service cpu uptime; do
	server=("$name")
done < bash-lab/data/fleet.txt


for element in "$server[@]"; do
	echo "$element"
done

