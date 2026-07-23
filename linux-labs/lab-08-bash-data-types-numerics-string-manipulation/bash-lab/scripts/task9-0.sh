#!/bin/bash

server=()
while IFS=, read -r name ip status port service; do
	server+=("$name")
done < bash-lab/data/servers.txt

if [ "$#" -eq 0 ]; then
	echo "Enter an argument:"
	read argument 
	while [ -z "$argument" ]; do
		echo "Enter an argument:"
		read argument
	done
else
	argument="$1"
fi
		
for element in "${server[@]}";do
	if [ "$argument" == "$element" ]; then
		echo "Element found: $element"
		exit 0
	fi
done
echo "Not found"
exit 2
