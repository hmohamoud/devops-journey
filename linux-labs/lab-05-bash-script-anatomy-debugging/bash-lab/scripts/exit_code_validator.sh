#!/bin/bash

if [ "$#" -eq 0 ]; then
	echo "Error: no file path provided"
	echo "Usage: ./exit_code_validator.sh FILE"
	exit 2
fi

if [ -f "$1" ]; then
	echo "File exists: $1"
	exit 0
else
	echo "Missing file: $1"
	exit 1
fi
