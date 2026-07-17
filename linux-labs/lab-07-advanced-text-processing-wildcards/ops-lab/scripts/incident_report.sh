#!/bin/bash

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 LOG_FILE"
    exit 2
fi

log_file="$1"

if [ ! -f "$log_file" ]; then
    echo "Error: file not found: $log_file"
    exit 1
fi

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
report="ops-lab/output/incident-report-$timestamp.txt"

error_count=$(grep -ic "error" "$log_file")
warning_count=$(grep -ic "warning" "$log_file")
most_common=$(grep -i "error" "$log_file" | sort | uniq -c | sort -rn | head -1)
first_error=$(grep -i "error" "$log_file" | head -1 | awk '{print $1, $2}')
last_error=$(grep -i "error" "$log_file" | tail -1 | awk '{print $1, $2}')
after_10=$(grep -i "error" "$log_file" | grep "10:0[4-9]\|10:1" | wc -l)

{
    echo "Incident Report"
    echo "Generated: $timestamp"
    echo "Log file: $log_file"
    echo "Total errors: $error_count"
    echo "Total warnings: $warning_count"
    echo "Most common error: $most_common"
    echo "First error: $first_error"
    echo "Last error: $last_error"
    echo "Errors after 10:04: $after_10"
} > "$report"

echo "Report saved to: $report"
exit 0
