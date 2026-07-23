#!/bin/bash
fleet_check() {
	local server_name="${1:-}"
	if [ -n "$server_name" ];then
		server=()
		while IFS=, read -r name ip status port service; do
			server+=("$name")
		done < bash-lab/data/servers.txt
	
		for element in "${server[@]}"; do
			if [ "$element" == "$server_name" ]; then
				while IFS=, read -r name ip status port service; do
					if [ "$name" == "$server_name" ]; then
						echo "$status"
						if [ "$port" -gt 8000 ]; then
							echo "$port"
						fi
						echo "${status^^}"
					fi
				done < bash-lab/data/servers.txt
				exit 0
			fi
		done
		echo "Not found"
		exit 1
	else
		echo "Usage: ./script.sh <server-name>"
       		exit 2
	fi
}

fleet_check "$1"

