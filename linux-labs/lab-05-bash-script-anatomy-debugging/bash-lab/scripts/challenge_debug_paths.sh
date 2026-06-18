#!/bin/bash

set -x
report_directory="bash-lab/output"
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
report_filename="$report_directory/report-incident-$timestamp.txt"

mkdir -p "$report_directory"
echo "report content" > "$report_filename"
echo "Report written to: $report_filename"
set +x
