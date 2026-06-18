#!/bin/bash
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
app_log=$(wc -l < bash-lab/input/app.log)
users_count=$(wc -l < bash-lab/input/users.txt)
warning_count=$(grep -i "warning" bash-lab/input/app.log)
created_dir=$(mkdir -p bash-lab/temp/test-output)

echo "Timestamp: $timestamp"
echo "App log lines: $app_log"
echo "User count: $users_count"
echo "Warning count:" 
echo "$warning_count"
echo "$created_dir"
