# Automated Incident Report System

## Overview
This mini-project is a Bash-based incident report system built as part 
of my DevOps learning journey. It scans application and authentication 
log files, detects ERROR and WARNING events, and generates a clean 
timestamped report automatically.

---

## Problem
Production log files can contain thousands of lines. During an incident, 
manually searching through logs for errors wastes critical time. Engineers 
need a faster way to see only what matters.

---

## Solution
A single Bash script scans two log files, filters ERROR and WARNING lines 
case-insensitively, counts them, identifies repeated incidents, and saves 
a timestamped report. If log files are missing, the error is logged 
separately. If no issues are found, the report says so clearly.

---

## What This Project Does
- Reads log files from the logs/ directory
- Detects ERROR and WARNING lines case-insensitively
- Counts ERROR and WARNING events separately
- Identifies repeated incidents ranked by frequency
- Generates a timestamped report in reports/
- Handles missing log files gracefully
- Sends script errors to errors/

---

## Project Structure
```text
mp-01-automated-incident-report/
├── instructions.md
├── project-brief.md
├── design.md
├── notes.md
├── evidence.md
├── challenge.md
├── README.md
├── incident_report.sh
├── logs/
│   ├── app.log
│   └── auth.log
├── reports/
└── errors/
```

---

## Inputs
```text
logs/app.log
logs/auth.log
```

---

## Outputs
```text
reports/incident-report-2026-06-03_20-40-14.txt
errors/script-log-2026-06-03_20-40-14.log
```

---

## How to Run
```bash
chmod +x incident_report.sh
./incident_report.sh
```

Check the report:
```bash
cat reports/incident-report-*.txt
```

---

## Example Output
```text
Incident Report

Generated: 2026-06-03_20-40-14

Files scanned: logs/app.log logs/auth.log

Count error: 10
Count warnings: 9

Repeated incidents:
   3 2026-06-02 19:16:03 ERROR Database connection failed
   2 2026-04-19 09:06:20 ERROR Timeout while calling payment-service
```

---

## Skills Practised
Bash scripting, grep, wc, sort, uniq, pipes, redirection, 
if statements, command substitution, file and directory checks.

---

## Testing
- Valid log files present — report generated correctly
- Missing log file — error logged to errors/
- Empty log files — report says no errors or warnings found
- Repeated runs — new timestamped report created each time

Full details in evidence.md

---

## Current Limitation
The script only scans two hardcoded log files. If there are more 
log files in the logs/ directory they will not be scanned.

---

## Future Improvements
- Scan all files in logs/ directory automatically
- Add cron job to run the script every hour
- Add separate sections for app and auth log results

---

## What I Learned
Bash scripts always start with a shebang and variables are assigned 
with no spaces around =. When using variables they must be wrapped 
in double quotes to prevent bash breaking on spaces or special characters.

Log files are organised into three parts — date/time, level, and message. 
They are crucial because they record when something fails or an event 
occurs. Knowing this made it easier to design the filtering logic.

This project taught me what automation actually means. Instead of running 
commands manually one at a time, a Bash script holds all the commands 
and runs them in one go. Unlike running commands manually, a script can 
use conditions, variables, and flow — without having to retype everything 
each time.

---

## Documentation
- instructions.md — project task sheet
- project-brief.md — why the project exists
- design.md — how the script works
- notes.md — what I learned
- evidence.md — mistakes, tests, and fixes
- challenge.md — self-test questions

---

## Next Step

[Lab 05 — Bash Script Anatomy, Conditions & Debugging](../../linux-labs/lab-05-bash-script-anatomy-debugging/)