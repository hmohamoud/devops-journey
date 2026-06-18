#!/bin/bash
file=$1
pattern=$2
arguments=$@
count=$#

if [ "$count" -eq 0 ]; then
	echo "Error: missing arguments"
	echo "Usage: ./challenge_args.sh FILE PATTERN"
fi

echo "File: $file"
echo "Pattern: $pattern"
echo "All arguments: $arguments"
echo "Argument count: $count"

