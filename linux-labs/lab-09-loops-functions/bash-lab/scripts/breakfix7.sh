#!/bin/bash

check_status() {
  if [ "$1" == "running" ]; then 
	echo "ok"
fi
}
result=$(check_status "running")
echo "$result"
