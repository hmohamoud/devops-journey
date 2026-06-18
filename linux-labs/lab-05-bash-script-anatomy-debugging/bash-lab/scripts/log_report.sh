#!/bin/bash

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
#This is wrong, this shouldnt be counted before checking if the file exists, count_errors=$(grep -i "ERROR" bash-lab/input/app.log | wc -l)
#count_warnings=$(grep -i "WARNING" bash-lab/input/app.log | wc -l)
report_filename="bash-lab/output/log-report-$timestamp.txt"
error_filename="bash-lab/errors/log-report-error-$timestamp.log"
#matching=$(grep -iE "warning|error" bash-lab/input/app.log)
if [ ! -d bash-lab/output/ ]; then
	mkdir -p bash-lab/output
fi

if [ ! -d bash-lab/errors/ ]; then
	mkdir -p bash-lab/errors
fi

if [ -f bash-lab/input/app.log ]; then
	count_errors=$(grep -i "ERROR" bash-lab/input/app.log | wc -l)
	count_warnings=$(grep -i "WARNING" bash-lab/input/app.log | wc -l)
	matching=$(grep -iE "warning|error" bash-lab/input/app.log)
	echo "Report Generated: $timestamp" > "$report_filename"
	echo ""  >> "$report_filename"
	echo "File scanned: bash-lab/input/app.log" >> "$report_filename"
	echo ""  >> "$report_filename"
	echo "Error count:" >> "$report_filename"
	echo ""	 >> "$report_filename"
	echo "$count_errors" >> "$report_filename"
	echo ""  >> "$report_filename"
	echo "Warning count:" >> "$report_filename"
	echo ""  >> "$report_filename"
	echo "$count_warnings" >> "$report_filename"
	echo ""  >> "$report_filename"
	echo "Matching errors and warning lines:" >> "$report_filename"
	echo ""  >> "$report_filename"
	echo "$matching" >> "$report_filename"
	echo "Report written to: $report_filename"
	exit 0		
else
	echo "Missing file: bash-lab/input/app.log" > "$error_filename"
	echo "bash-lab/errors/error-incident-$timestamp.txt"
	echo "Error written to: $error_filename"
	exit 1
fi
