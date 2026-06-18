#!/bin/bash
count_warning=$(grep -i "Warning" bash-lab/input/app.log| wc -l)
if [ -f bash-lab/input/app.log ]; then
	echo "$count_warning"
	if [ "$count_warning" -eq 0 ]; then
		echo "No warnings found"
	fi
	if [ "$count_warning" -gt 0 ]; then
		echo "Warnings found: "$count_warning" "
	fi
else
	echo "Missing file: bash-lab/input/app.log"
fi
