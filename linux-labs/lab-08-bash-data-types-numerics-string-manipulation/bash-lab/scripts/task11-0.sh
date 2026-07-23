#!/bin/bash

server=()
while IFS=, read -r name ip status port service;do
	server+=("$port")
done < bash-lab/data/servers.txt

for element in "${server[@]}";do
	if [ "$element" -eq 1024 ]; then
		echo "$element is equal to 1024"
	fi
	if [ "$element" -gt 1024 ]; then
		echo "$element is greater than 1024"
	fi
	if [ "$element" -lt 1024 ]; then
		echo "$element is less than 1024"
	fi
	if [ "$element" -ge 1024 ]; then
		echo "$element is greater than or equal to 1024"
	fi
	if [ "$element" -le 1024 ]; then
		echo "$element is less than or equal to 1024"
	fi
	if [ "$element" -ne 1024 ]; then
		echo "$element is not equal to 1024"
	fi
done
