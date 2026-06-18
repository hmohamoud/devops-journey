#!/bin/bash
total_lines=$(wc -l < bash-lab/input/app.log)
total_users=$(wc -l < bash-lab/input/users.txt)
total_warning_lines=$(grep -i "warning" bash-lab/input/app.log | wc -l)
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
created_output=$(mkdir -p bash-lab/output)
echo "Timestamp: "$timestamp" "
echo "App log lines: "$total_lines" "
echo "User count: "$total_users" "
echo "Warning count: "$total_warning_lines" "
echo "Created_output value : "created_output" "

