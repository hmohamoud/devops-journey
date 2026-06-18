#!/bin/bash

file=$1
count=$#

if [ "$count" -eq 0 ]; then
	echo "Error: no file path provided"
	echo "Usage: ./challenge_exit_codes.sh FILE"
	exit 2
fi

if [ -f "$file" ]; then
	echo "File exists: $file"
	exit 0
fi

if [ ! -f "$file" ]; then
	echo "Missing file: $file"
	exit 1
fi



