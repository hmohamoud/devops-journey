#!/bin/bash
set -euo pipefail
timestamp=$(date +%Y-%m-%d_%H-%M-%S)
validate_args(){
	if [ "$#" -ne 1 ]; then
		exit 2
	fi

	if [ -d "ops-lab/app/releases/$1" ]; then
		current_release=$(readlink -f ops-lab/app/current)
		if [ ! -d "$current_release" ]; then
    		echo "ERROR: Current release does not exist"
    		exit 4
		fi
		tar -zcvf ops-lab/backups/deploytarget-"$timestamp".tar.gz "$current_release"
		echo "Backup saved to: ops-lab/backups/deploytarget-$timestamp.tar.gz"
		find ops-lab/app/releases/"$1" -type d -exec chmod 755 {} +
		find ops-lab/app/releases/"$1" -type f -exec chmod 644 {} +
		ln -sfn ops-lab/app/releases/"$1" ops-lab/app/current
		new_release=$(readlink -f ops-lab/app/current)
		look=$(find ops-lab/app/releases/"$1" -perm 777)
		if [ -n "$look" ]; then
			echo "WARNING: Found files with 777 permissions:"
			echo "$look"
		fi
		echo "New release now live: $new_release"
		 
	else
		exit 1
	fi
}

validate_args "$@"