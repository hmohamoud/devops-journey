#!/bin/bash

set -u

if [ -z "${1:-}" ]; then
	echo "Usage: $0 <arg>"
	exit 2
fi 


if [ "$1" == "Hamza" ]; then
        echo "Theres a match"
else
        echo "there isnt a match"
fi
echo "$underfined_var"


