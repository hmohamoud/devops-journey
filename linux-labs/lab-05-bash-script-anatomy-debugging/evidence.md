# Evidence — Lab 05: Bash Script Anatomy, Conditions & Debugging

---

## Completed Tasks

### Environment Setup
- Created structured lab environment:
  - `bash-lab/`
    - `scripts/`
    - `input/`
    - `output/`
    - `errors/`
    - `temp/`

- Created input files:
  - `input/app.log`
  - `input/users.txt`
  - `input/config.env`

- Populated `input/app.log` with 12 lines including INFO, WARNING, and ERROR events with repeats

- Verified structure using:
  - `ls`
  - `ls -R bash-lab`

---

### Task 1 — Script Anatomy
- Created `bash-lab/scripts/hello_script.sh`
- Added shebang, comment, variable, and echo
- Ran with `bash` — worked without execute permission
- Ran with `./` — failed until `chmod +x` was added
- Fixed with `chmod +x bash-lab/scripts/hello_script.sh`

---

### Task 2 — Variables and Quoting
- Created `bash-lab/scripts/path_builder.sh`
- Built file path from two variables
- First run printed `/daily report.txt` — missing the directory prefix
- Fixed variable assignment and quoting
- Tested with spaces in `report_directory` — worked correctly with quotes

---

### Task 3 — Command Substitution
- Created `bash-lab/scripts/command_substitution_test.sh`
- Stored timestamp, app log line count, user count, and warning count
- Tested `created_output=$(mkdir -p bash-lab/output)` — directory was created but variable was empty
- Confirmed command substitution is only useful for commands that produce output

---

### Task 4 — File and Directory Checks
- Created `bash-lab/scripts/check_inputs.sh`
- Checked three real files, one missing file, and two directories
- First run failed with `too many arguments` error — fixed bracket syntax
- Final output correctly printed FOUND and MISSING for each path

---

### Task 5 — Warning Detector
- Created `bash-lab/scripts/warning_detector.sh`
- Nested warning count check inside file existence check
- Confirmed warnings found message when file existed
- Renamed app.log to test missing file path — missing file message appeared
- Restored file and confirmed script returned to normal

---

### Task 6 — Numeric Comparisons
- Created `bash-lab/scripts/number_compare.sh`
- Tested all six numeric operators: -eq -ne -gt -lt -ge -le
- All six comparisons printed correct messages

---

### Task 7 — Script Arguments
- Created `bash-lab/scripts/argument_checker.sh`
- Passed two arguments and confirmed $1 $2 $@ $# all printed correctly
- Ran with no arguments — usage message appeared

---

### Task 8 — Exit Codes
- Created `bash-lab/scripts/exit_code_validator.sh`
- Tested existing file — exit 0 confirmed with `echo $?`
- Tested missing file — exit 1 confirmed with `echo $?`
- Tested no argument — exit 2 confirmed with `echo $?`

---

### Task 9 — Debugging with echo
- Created `bash-lab/scripts/debug_paths.sh`
- Intentionally set broken path: `bash-lab/ouput` (missing t)
- Printed DEBUG lines for all three variables
- Found typo in report_directory using echo DEBUG

---

### Task 10 — bash -x Trace
- Ran `bash -x bash-lab/scripts/debug_paths.sh`
- Saw every line execute with variable values expanded
- Added `set -x` and `set +x` inside the script
- Confirmed trace shows exactly which line and variable caused the failure

---

### Task 11 — Working Directory
- Created `bash-lab/scripts/challenge_location.sh`
- Ran from lab root — app.log was read correctly
- Ran from inside `bash-lab/scripts/` — path failed with no such file or directory
- Confirmed relative paths depend on where the script is run from

---

### Task 12 — Input Validator
- Created `bash-lab/scripts/input_validator.sh`
- All files found — printed all required input files found, exit 0
- Renamed config.env — printed missing file with exact name, exit 1
- Restored file and confirmed exit 0 returned

---

### Task 13 — Log Report Drill
- Created `bash-lab/scripts/log_report.sh`
- Script created output and errors directories, scanned app.log, and wrote timestamped report
- Confirmed report written message printed correctly

---

### Challenge 13 — Final Pattern Report
- Created `bash-lab/scripts/pattern_report.sh`
- Tested ERROR — report created with matching lines
- Tested WARNING — report created with matching lines
- Tested CRITICAL — report created with no matches found message
- Tested missing file — exit 1 confirmed
- Tested no arguments — exit 2 confirmed

---

## Break/Fix Logs

### Issue 1 — Wrong shebang
**What I tried:** `!#/bin/bash`
**What happened:** Bash could not identify the interpreter
**Why it happened:** The shebang must be `#!` not `!#` — order matters
**How I fixed it:** Changed to `#!/bin/bash`
**Prevention:** Always write the shebang first before anything else

---

### Issue 2 — Spaces around =
**What I tried:** `report_directory = "bash-lab/output"`
**What happened:** Bash did not treat it as a valid variable assignment
**Why it happened:** Bash does not allow spaces around = in variable assignment
**How I fixed it:** Changed to `report_directory="bash-lab/output"`
**Prevention:** Never put spaces around = when assigning variables

---

### Issue 3 — Unquoted path with spaces
**What I tried:** Used `$report_filename` without quotes when the value contained spaces
**What happened:** Bash split the value on spaces and broke the path
**Why it happened:** Unquoted variables are word-split by Bash
**How I fixed it:** Changed to `"$report_filename"` with double quotes
**Prevention:** Always quote variables used in paths

---

### Issue 4 — Useless command substitution
**What I tried:** `created_output=$(mkdir -p bash-lab/output)`
**What happened:** Directory was created but variable was empty
**Why it happened:** mkdir performs an action and produces no output — command substitution captures output not actions
**How I fixed it:** Removed substitution and ran `mkdir -p bash-lab/output` directly
**Prevention:** Only use command substitution for commands that produce output

---

### Issue 5 — Bad file check with two files
**What I tried:** `if [ -f bash-lab/input/app.log bash-lab/input/users.txt ]; then`
**What happened:** Too many arguments error
**Why it happened:** -f only checks one file at a time
**How I fixed it:** `if [ -f bash-lab/input/app.log ] && [ -f bash-lab/input/users.txt ]; then`
**Prevention:** Each file needs its own -f check joined with &&

---

### Issue 6 — Missing space inside brackets
**What I tried:** `if [! -f bash-lab/input/app.log ]; then`
**What happened:** Bash did not parse the condition correctly
**Why it happened:** Bash requires a space after [ and before ]
**How I fixed it:** `if [ ! -f bash-lab/input/app.log ]; then`
**Prevention:** Always put spaces inside brackets

---

### Issue 7 — Typo in directory name
**What I tried:** `report_directory="bash-lab/ouput"`
**What happened:** Script failed with no such file or directory
**Why it happened:** Typo — missing t in output
**How I fixed it:** Found the typo using echo DEBUG and bash -x. Fixed to `bash-lab/output`
**Prevention:** Use echo DEBUG and bash -x to inspect variable values before using them

---

### Issue 8 — Result check outside file check block
**What I tried:** Placed zero-count check after fi instead of inside the file-exists block
**What happened:** Script ran the count check even when the file did not exist
**Why it happened:** Variables defined inside an if block may not exist outside it
**How I fixed it:** Moved the zero-count check inside the file-exists block
**Prevention:** Outer if checks if the job can run. Inner if checks the result

---

### Issue 9 — Wrong exit code on failure
**What I tried:** Printed error message but exited with 0
**What happened:** System treated failure as success
**Why it happened:** exit 0 always means success regardless of the message printed
**How I fixed it:** Changed to exit 1 for missing file and exit 2 for missing arguments
**Prevention:** Always match exit code to actual outcome

---

### Issue 10 — Wrong working directory
**What I tried:** Ran script from inside bash-lab/scripts/
**What happened:** Script failed — no such file or directory for app.log
**Why it happened:** The relative path bash-lab/input/app.log only resolves from the lab root
**How I fixed it:** Navigated back to lab root before running the script
**Prevention:** Always know which directory you are running from

---

### Issue 11 — set-x instead of set -x
**What I tried:** `set-x` inside the script
**What happened:** Bash said command not found
**Why it happened:** Missing space between set and -x — Bash read it as one word
**How I fixed it:** Changed to `set -x`
**Prevention:** set -x and set +x always need a space

---

### Issue 12 — Wrong flag for directory check
**What I tried:** Used -f to check if a directory existed
**What happened:** Check gave wrong result
**Why it happened:** -f checks files, not directories
**How I fixed it:** Changed to -d for directory checks
**Prevention:** -f for files, -d for directories

---

## Key Patterns

- Most failures came from typos in paths, missing quotes, and wrong bracket spacing
- bash -x and echo DEBUG were the most useful debugging tools
- Outer if for can the job run, inner if for what was the result
- Exit codes matter as much as echo messages in real automation
- Relative paths always depend on where the script is run from, not where it lives
- Command substitution is only useful for commands that produce output

---

## Main Takeaways

- A script that silently fails is worse than one that errors clearly
- Every variable used in a path must be quoted
- Every if statement must be explainable in plain English
- echo tells the human what happened. exit tells the system what happened
- bash -x is the fastest way to find which line is breaking
- Working directory and script location are not the same thing
- Always test both the success path and the failure path