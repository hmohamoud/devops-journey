#!/bin/bash 

while IFS=, read -r name ip status port service cpu uptime; do
	echo "$name"
	echo "$status"
done < bash-lab/data/fleet.txt

 
