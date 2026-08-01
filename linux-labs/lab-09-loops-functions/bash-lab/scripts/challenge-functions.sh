#!/bin/bash 


while IFS=, read -r name ip status port service cpu uptime; do
        if is_healthy "$status" "$cpu"
		echo "PASS"
	else
		echo "FAIL"
	result=$(service_tier "$service")
	echo "$result"

done < bash-lab/data/fleet.txt

is_healthy() {
	if [ "$1" == "running" ] && [ "$2" -lt 80 ]; then
		return 0
	else
		return 1


service_tier() {
	local tier
        case "$1" in 
		nginx|proxy*) tier="web" ;;
		postgres|redis) tier="data" ;;
		auth-service|job-worker|prometheus) tier="support" ;;
		*) tier="other"
	esac
	echo "$tier"
	
}


require_arg() {
	if [ "$1" -eq 0 ] 
		echo "Usage: $actual is the correct amount of arguments"
		return 2
	fi
}


require_arg "$#"
	
