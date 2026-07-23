#!/bin/bash

server=()
while IFS=, read -r name ip status port service;do
	server+=("$port")
done < bash-lab/data/servers.txt

for element in "${server[@]}";do
	if [ $((element % 2)) -eq 0 ]; then
		echo "Element is even: $element"
	else
		echo "Element is odd: $element"
	fi
done

