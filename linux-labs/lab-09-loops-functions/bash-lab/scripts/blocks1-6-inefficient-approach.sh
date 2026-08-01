#!/bin/bash

server=()
while IFS=, read -r name ip status port service cpu uptime; do
	if [ "$status" == "running" ]; then
		server+=("$name")
	fi
done < bash-lab/data/fleet.txt

count=0

for s in "${server[@]}"; do
	count=$((count + 1))
done
echo "Servers running: $count"


servers=()
while IFS=, read -r name ip status port service cpu uptime; do
        if [ ! "$status" == "running" ]; then
                servers+=("$name")
        fi
done < bash-lab/data/fleet.txt

counts=0
for z in "${servers[@]}";do
	counts=$((counts + 1))
done
echo "Servers not running: $counts"