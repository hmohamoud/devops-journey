#!/bin/bash

while IFS=, read -r name ip status port service cpu uptime; do
	echo "$name : $port"
done < bash-lab/data/fleet.txt



                    
while IFS=, read -r name ip status port service cpu uptime; do
        if [ "$service" == "nginx" ]; then
                echo "$name : $port"
        fi
done < bash-lab/data/fleet.txt	
                    
while IFS=, read -r name ip status port service cpu uptime; do
        if [[ "$service" == *nginx* ]]; then
                echo "$name : $port"
        fi
done < bash-lab/data/fleet.txt


ips=()
while IFS=, read -r name ip status port service cpu uptime; do
	ips+=("$ip")
done < bash-lab/data/fleet.txt

for ip in "${ips[@]}"; do
	echo "$ip"
done

          
count=0
while IFS=, read -r name ip status port service cpu uptime; do
        if [ "$status" == "running" ]; then
		count=$((count + 1))
	fi
done < bash-lab/data/fleet.txt

echo "$count"


          
while IFS=, read -r name ip status port service cpu uptime; do
        if [ "$uptime" -gt 100 ]; then
                echo "$name"
        fi
done < bash-lab/data/fleet.txt


