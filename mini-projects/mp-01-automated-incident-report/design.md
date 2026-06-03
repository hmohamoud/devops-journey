# Design

## Input
The script will read log files from the logs/ directory.

The input files are:
- logs/app.log
- logs/auth.log

These files will contain sample application and authentication log lines.


## Process
1. Start by preparing the report's location
2. Read logs files from the logs/ directory.
3. Search/Scan for log lines that contain error and warning, not info.
4. Make the search case-insensitive so it can detect error, ERROR, warning, and WARNING.
5. Count how many error lines exist
6. Count how many warning lines exist
7. Redirects the log lines that contain ERROR and WARNING into my report file in reports/?
8. Write the error and warning counts into the report
9. Write repeated messages into the report
10. If zero errors and zero warnings, write "No errors or warnings found" into the report instead
11. If the script hits any failures, write them to the errors/ directory
12. Save the completed report to reports/ with a timestamp in the filename

## Output
The script creates a report file in reports/ directory
The report should include:
1. Report title
2. timestamp
3. Which log file was scanned
4. The error and warning lines that are found
5. Total error count
6. Total warning count
7. Repeated messages
8. A message if no errors or warnings were found



## Error Handling
File doesn't exist → say so
Reports directory doesn't exist → create it and continue
Log file is empty → say no logs found

## Testing Plan
1. Run the script and check a report file was created in reports/
2. Open the report and check it only contains ERROR and WARNING lines, not INFO
3. Count the ERROR lines in app.log manually and check the report count matches
4. Count the WARNING lines in app.log manually and check the report count matches
5. Check the report lists which log files were scanned
6. Remove all ERROR and WARNING lines from the log, run the script again, and check the report says "No errors or warnings found"