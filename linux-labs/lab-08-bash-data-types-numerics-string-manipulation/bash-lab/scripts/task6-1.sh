#!/bin/bash

server=()

while IFS=, read -r name ip status port service; do
        server+=("$name")
done < bash-lab/data/servers.txt

echo "Number of servers: ${#server[@]}"
echo "${server[-1]}"
