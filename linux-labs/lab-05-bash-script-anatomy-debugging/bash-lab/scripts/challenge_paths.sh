#!/bin/bash
report_directory="bash-lab/output reports"
report_name="daily summary.txt"
report_file="$report_directory/$report_name"
echo "$report_file"
mkdir -p "$report_directory"
echo "Path test successful" > "$report_file"

