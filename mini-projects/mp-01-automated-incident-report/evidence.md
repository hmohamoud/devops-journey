# Evidence

## Test 1: Successful report generation
**What I tried:** ran bash incident_report.sh with both log files present
**What happened:** report file was created in reports/ with a timestamp 
in the filename, containing only ERROR and WARNING lines, counts, and 
repeated incidents
**What this proves:** the script correctly scans logs and generates a 
readable report

---

## Test 2: Missing log file

**What I tried:** ran bash incident_report.sh by editing one of log file's names that we present
**What happened:** error file was created in errors/ with timestamp in the file name, containing only log files not found
**How I fixed it:** Restored the file by renaming it back to app.log

---

## Test 3: No ERROR or WARNING lines

**What I tried:** ran bash incident_report.sh by removing the contents inside both log files that are present
**What happened:** report file was created in report/ with timestamp in the file name, report contained the message No errors or warnings found
**How i fixed it:** Restored the file by bringing back the log contents to the files that i deleted from. 

---
## Test 4: 

**What I tried:** ran bash incident_report.sh by removing the contents inside one log file that are present
**What happened:** report file was created in reports/ with timestamp in the file name, containing only the result of the contents of the file that existed 
**What this proves:** It proves that if one log doesnt exist then it will perform the main task on the other log file.


---

## Issue 2

**What I tried:** wrote `report_directory = "reports"` when creating a variable
**What happened:** bash did not treat it as a valid variable assignment
**Why it happened:** bash does not allow spaces around `=` when assigning variables
**How I fixed it:** changed it to `report_directory="reports"`

---

## Issue 3
**What I tried:** used single quotes like `'reports'` around values
**What happened:** variables inside single quotes did not expand
**Why it happened:** single quotes treat everything literally in bash, while double quotes allow variables to expand
**How I fixed it:** used double quotes when I needed variable expansion, like `"$report_filename"`

---

## Issue 4
**What I tried:** wrote variables without quotes, like `$report_filename`
**What happened:** the script could break if the variable contained spaces or special characters
**Why it happened:** unquoted variables can be split or interpreted incorrectly by the shell
**How I fixed it:** wrapped variables in double quotes, like `"$report_filename"`

---

## Issue 5

**What I tried:** used `[ -f $report_directory ]` to check if the `reports/` directory existed
**What happened:** the check was wrong because `-f` checks for files, not directories
**Why it happened:** I confused file checks and directory checks
**How I fixed it:** learned that `-f` checks files and `-d` checks directories. For this project, I used `mkdir -p "$report_directory"` to create the directory if it does not exist

---

## Issue 6

**What I tried:** wrote `[ -f logs/app.log logs/auth.log ]` to check two files at once
**What happened:** the condition did not work properly
**Why it happened:** `-f` only checks one file at a time
**How I fixed it:** checked each file separately and joined the checks with `&&`: `if [ -f logs/app.log ] && [ -f logs/auth.log ]; then`

---

## Issue 7

**What I tried:** wrote a condition without spaces, like `[condition]`
**What happened:** bash did not read the condition properly
**Why it happened:** bash requires spaces after `[` and before `]`
**How I fixed it:** used the correct format, like `[ condition ]`

---

## Issue 8

**What I tried:** tried to create a variable called something like `redirect_file` to handle redirection
**What happened:** the output was not being written to the report correctly
**Why it happened:** redirection is done directly with `>` or `>>`, not by storing the redirect symbol in a variable
**How I fixed it:** used `>> "$report_filename"` directly on the `echo` lines

---

## Issue 9

**What I tried:** wrote `>> "$repeated_counts"` instead of redirecting into the report file
**What happened:** bash tried to redirect output into the value stored inside the variable instead of the report file
**Why it happened:** I confused the variable holding repeated-count output with the variable holding the report file path
**How I fixed it:** redirected into `"$report_filename"` instead

---

## Issue 10

**What I tried:** placed the “no errors or warnings found” check after the closing `fi`
**What happened:** the logic was in the wrong place
**Why it happened:** the count variables were created inside the main `if` block, so the zero-check needed to happen inside that same block
**How I fixed it:** moved the zero-check inside the main `if` block

---

## Issue 11

**What I tried:** wrote blank lines using `echo ""` without redirecting them
**What happened:** the blank lines printed to the terminal instead of going into the report
**Why it happened:** every `echo` line that should appear in the report needs to be redirected
**How I fixed it:** added `>> "$report_filename"` to the blank `echo` lines

---

## Issue 12

**What I tried:** wrote the `files scanned` line without `>> "$report_filename"`
**What happened:** it printed to the terminal only and did not appear inside the report
**Why it happened:** I forgot to redirect that `echo` output into the report file
**How I fixed it:** added the report redirect: `echo "Files scanned: logs/app.log logs/auth.log" >> "$report_filename"`

---

## Issue 13

**What I tried:** only created a repeated-count variable for ERROR lines
**What happened:** WARNING repeats were not counted separately
**Why it happened:** I forgot that ERROR and WARNING needed separate repeated incident summaries
**How I fixed it:** created two separate variables: `repeated_counts_error` and `repeated_counts_warning`

---

## Issue 14

**What I tried:** wrote comments using `//`
**What happened:** bash did not treat them as comments
**Why it happened:** bash uses `#` for comments, not `//`
**How I fixed it:** changed the comments to use `#`

---
## Limitation
**Current limitation:** the script only scans two hardcoded log files. 
If there are more than 2 log files it will break.
**Why this happens:** the input is hardcoded as logs/app.log and 
logs/auth.log in the script logic.
**How I could improve it later:** scan all files in the logs/ directory 
instead of hardcoding filenames. Could also add a trigger to run 
automatically every hour using cron instead of running it manually.