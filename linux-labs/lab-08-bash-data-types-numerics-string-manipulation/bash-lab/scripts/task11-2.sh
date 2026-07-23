#!/bin/bash

server=()
while IFS=, read -r name ip status port service;do
	if [ "$status" == "running" ] && [ "$service" == "nginx" ];then
		echo "$status $service: AND condition"
	fi
	if [ "$status" == "running" ] || [ "$service" == "nginx" ]; then
		echo "$status $service: OR condition"
	fi
	if ! [ "$status" == "running" ]; then
		echo "Not running"
	fi

done < bash-lab/data/servers.txt

 


