#!/bin/bash

echo "Alternative 1"
while IFS=, read -r name ip status port service cpu uptime; do
	echo "$name"
	
done < bash-lab/data/fleet.txt


while IFS=, read -r name ip status port service cpu uptime; do
	echo "$status"
done < bash-lab/data/fleet.txt

echo "Alternative 2"

server=()
status=()
while IFS=, read -r name ip status port service cpu uptime; do
	server=("$name")
	status=("$status")
done < bash-lab/data/fleet.txt


for n in "${server[@]}";do
	echo "$n"
done

for s in "${status[@]}"; do 
	echo "$s"
done

