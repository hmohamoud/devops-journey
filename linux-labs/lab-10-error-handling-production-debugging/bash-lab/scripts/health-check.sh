#!/bin/bash

set -euo pipefail

temp=$(mktemp)
timestamp=$(date +%Y%m%d-%H%M%S)

mkdir -p bash-lab/logs && logfile="bash-lab/logs/error-$timestamp.log" || {
    echo "Cannot create log directory"
    exit 1
}

trap 'echo "run complete" && rm -f "$temp"' EXIT


validate_args() {
	local actual="$1"
	local expected="$2"
	if [ "$actual" -ne "$expected" ]; then
		echo "Usage: expected $expected argument(s), got $actual"
		return 2
	fi

}

if ! validate_args "$#" 1; then
	exit 2
fi

if [ ! -f "$1" ]; then
	exit 3
fi



is_running() {
          
        if [ "$1" == "running" ]; then
                return 0
        else
                return 1
        fi
}


while IFS=, read -r name status; do 
	if is_running "$status"; then
		echo "$name is UP" >> "$logfile"
	else
		echo "$name is DOWN" >> "$logfile"
	fi
done < bash-lab/data/servers.txt


