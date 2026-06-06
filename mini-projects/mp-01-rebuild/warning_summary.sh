#!/bin/bash
report_directory="reports"
errors_directory="errors"
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
report_filename="$report_directory"/incident-report-$timestamp.txt"
errors_filename="$errors_directory"/errors-report-$timestamp.txt"
mkdir -p "$report_directory"
mkdir -p "$errors_directory"
if [ -f logs/app.log ] && [ -f logs/auth.log ]; then #This mean it checks if logs/app exists and logs/app.log exists
    scan_warning=$(grep -ih "warning" logs/app.log logs/auth.log)
    count_warning=$(grep -ih "warning" logs/app.log logs/auth.log | wc -l)

    #echo "Warning Summary Report" >> "$report_filename"
    #echo "" >> "$report_filename"
    #echo "Generated: $timestamp" >> "$report_filename"
    #echo "" >> "$report_filename"
    #echo "Files scanned: logs/app.log logs/auth.log" >> "$report_filename"
    #echo "" >> "$report_filename"
    #echo "Warning count: $count_warning" >> "$report_filename"
    #echo "" >> "$report_filename"  this is just the content of what goes in the most important is everything around the uncommented script. 

    if [ "$count_warning" -eq 0 ]; then
        echo "Warnings not found" >> "$report_filename"
    else
        echo "Warnings found:" >>  "$report_filename"
        echo "" >> "$report_filename"
        echo "$scan_warning" >> "$report_filename"
    fi
else
    if [ ! -f logs/app.log ]; then
        echo "logs/app.log is missing" >> "$errors_filename"
    fi
    if [ ! -f logs/auth.log ]; then
        echo "logs/auth.log is missing" >> "$errors_filename"
    fi
fi


echo "Script processed and complete" 