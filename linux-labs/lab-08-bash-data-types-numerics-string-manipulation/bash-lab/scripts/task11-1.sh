#!/bin/bash

server=()
while IFS=, read -r name ip status port service;do
	server+=("$status")
	server+=("$service")
done < bash-lab/data/servers.txt

for element in "${server[@]}";do
	if [ "$element" == "Hamza" ]; then
		echo "$element is Hamza"
	fi
	if [ "$element" != "Hamza" ]; then
		echo "$element is not Hamza"
	fi
	if [ -z "$element" ]; then
		echo "Element is empty"
	fi
	if [ -n "$element" ]; then
		echo "$element is not empty"
	fi
done 

