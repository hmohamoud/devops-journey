## Problem
Application logs in production environments can contain many lines, and it can be manually slow to find errors when something goes wrong. 

## Why This Matters
Saves time, Devops and SRE wont have to look manually and search for errors or warnings, instead it will be done automatically. They will need to look and extract important and useful logs only. They will need to understand quickly what failed. Automating log filtering saves time and helps engineers focus on useful and important incident information instead of manually searching through full logs. 

## User
A junior DevOps, SRE, cloud, platform engineer

## Incident Definition
An incident is when a log line contains error or warning in the message. The search should be case-insensitive so it can detect different formats such as ERROR, error, WARNING, or warning.

## Goal
Build a bash script that scans logs/ by only searching for errors and warning lines and not info. It should generate a clean readable report incident containing only ERROR and warnings. This saves time for juniors as they only have to run the script instead of having to type commands for searching through the logs or manually doing so. 

## Inputs
The script will read sample log files from the log/ directory:

- logs/app.log
- logs/auth.log
## Outputs
The tool should create a report file inside the reports/ directory.

The report should contain:
- the time the report was generated
- ERROR and WARNING log lines
- counts of errors and warnings
- repeated ERROR or WARNING messages where possible
- a message if no errors or warnings were found

Script errors, such as missing files or failed commands, should be written to the errors/ directory.

## Skills From Labs
Navigation, file permissions, file creation, grep, sort, uniq, wc, pipes, stdout, stderr, and redirection.

## Success Criteria
The project works if it creates a report file in the reports/ directory containing only errors and warnings, not INFO lines.
If the logs have no errors or warnings, the report should clearly say that no errors or warnings were found.
The report should include a timestamp so I know when the script was last run.
The report should include counts of ERROR and WARNING lines.
The script should handle basic script errors by sending them to the errors/ directory.