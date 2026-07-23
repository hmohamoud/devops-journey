#!/bin/bash

echo "Script name: $0"   
echo "First argument: $1"                                       
echo "Second argument: $2"
echo "Argument count: $#" 
for arguments in "$@"; do
	echo "$arguments"
done

for breakapart in $@; do
	echo "$breakapart"
done


echo "--- looping with \"\$@\" ---"
for arg in "$@"; do
  echo "$arg"
done

echo "--- looping with \"\$*\" ---"
for arg in "$*"; do
  echo "$arg"
done
echo "Exit Status: $?"   
echo "Process ID: $$"
echo "Last Background PID: $!"


