#!/bin/bash
report_directory="reports" #to store the report directory file path
timestamp=$(date +"%Y-%m-%d_%H-%M-%S") #used as a unique identifier for the report name to know when it was last run 
errors="errors" #to store the error directory file path
report_filename="$report_directory"/incident-report-$timestamp.txt 
mkdir -p "$report_directory" #this happens when it hasnt been created 
mkdir -p "$errors" 
if [ -f logs/app.log ] && [ -f logs/auth.log ]; then  
    #this checks if these files exist if we want to check if directory exist it would be -d. f the file doesnt exist, we say these files aren't found. 
    scan=$(grep -iEh "error|warning" logs/app.log logs/auth.log) 
    count_error=$(grep -ih "error" logs/app.log logs/auth.log | wc -l)
    count_warning=$(grep -ih "warning" logs/app.log logs/auth.log | wc -l)
    repeated_counts_error=$(grep -ih "error" logs/app.log logs/auth.log | sort | uniq -c | sort -nr)
    repeated_counts_warning=$(grep -ih "warning" logs/app.log logs/auth.log | sort | uniq -c | sort -nr)
    echo "Incident Report"  >> "$report_filename"
    echo "" >> "$report_filename"
    echo "Generated: $timestamp"  >> "$report_filename"
    echo "" >> "$report_filename"
    echo "files scanned: logs/app.log logs/auth.log" >> "$report_filename"
    echo "" >> "$report_filename"
    echo "Log lines:" >> "$report_filename"
    echo "$scan" >> "$report_filename"
    echo "" >> "$report_filename"
    echo "Count error: $count_error" >> "$report_filename"
    echo "" >> "$report_filename"
    echo "Count warnings: $count_warning" >> "$report_filename"
    echo "" >> "$report_filename"
    echo "Repeated incidents: $repeated_counts_error" >> "$report_filename"
    echo "" >> "$report_filename"
    echo "Repeated incidents: $repeated_counts_warning" >> "$report_filename"

    if [ "$count_error" -eq 0 ] && [ "$count_warning" -eq 0 ]; then #to see if the number of errors are warnings equate to zero it means there is none
        echo "No errors or warnings found" >> "$report_filename"
    fi

else
    mkdir -p "$errors"
    echo ""
    echo "log files not found" >> "$errors/script-log-$timestamp.log"

fi


