#!/bin/bash

running=0
not_running=0

while IFS=, read -r name ip status port service cpu uptime; do
    if [ "$status" == "running" ]; then
        running=$((running + 1))
    else
        not_running=$((not_running + 1))
    fi
done < bash-lab/data/fleet.txt

echo "Servers running: $running"
echo "Servers not running: $not_running"
