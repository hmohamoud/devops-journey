#!/bin/bash
server=()
while IFS=, read -r name ip status port service; do
	server+=("$name")
done < bash-lab/data/servers.txt

echo "${server[0]}"
echo "Length: ${#server[0]}"
echo "Substring: ${server[@]:6}"
text="nginx-nginx-nginx"
echo "Replaces first nginx :${text/nginx/hamza}" 
