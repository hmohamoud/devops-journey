#!/bin/bash
set -x
report_directory="bash-lab/ouput"
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
report_filename="$report_directory/report-output-$timestamp.txt"
echo "Report Generated: $report_filename" > "$report_filename"
set +x
echo "DEBUG report_directory=$report_directory"
echo "DEBUG timestamp=$timestamp"
echo "DEBUG report_filename=$report_filename"
















