# Challenge — Bash Script Anatomy, Conditions & Debugging

## Rules

- Do NOT use `notes.md`
- Do NOT copy from `instructions.md`
- Do NOT look at previous scripts unless you are completely stuck
- Predict what each script should do before running it
- Verify every output file with `cat` or `ls`
- Test both success and failure paths
- If something fails, diagnose it before fixing
- No vague answers: every fix must include the corrected line or command
- Every script must use clear variable names
- Every variable used in paths must be quoted
- Every error message must say exactly what failed
- Every script must be explainable line by line

---

## Challenge 1 — Script Anatomy

Create:

```text
bash-lab/scripts/challenge_hello.sh
```

Requirements:

1. Add the correct shebang
2. Add one comment explaining the script purpose
3. Create a variable called `lab_name`
4. Print:

```text
Running Lab 05 Bash Challenge
```

5. Run it with:

```bash
bash bash-lab/scripts/challenge_hello.sh
```

6. Then run it with:

```bash
./bash-lab/scripts/challenge_hello.sh
```

7. If it fails, fix permissions properly

Answer:

- Why did `bash script.sh` work?
- Why did `./script.sh` need execute permission?
- What does the shebang do?

---

## Challenge 2 — Variables and Quoted Paths

Create:

```text
bash-lab/scripts/challenge_paths.sh
```

Requirements:

1. Create a variable:

```bash
report_directory="bash-lab/output reports"
```

2. Create a variable:

```bash
report_name="daily summary.txt"
```

3. Build a full path from both variables
4. Print the full path
5. Create the directory successfully
6. Write the text below into the report file:

```text
Path test successful
```

Expected report path:

```text
bash-lab/output reports/daily summary.txt
```

Answer:

- What broke when variables were unquoted?
- Why did quoting fix it?
- Why are paths with spaces dangerous in Bash?

---

## Challenge 3 — Command Substitution Test

Create:

```text
bash-lab/scripts/challenge_substitution.sh
```

Requirements:

1. Store the current timestamp in a variable
2. Store the number of lines in `bash-lab/input/app.log`
3. Store the number of users in `bash-lab/input/users.txt`
4. Store the number of WARNING lines in `bash-lab/input/app.log`
5. Print all four values clearly

Required output format:

```text
Timestamp: VALUE
App log lines: VALUE
User count: VALUE
Warning count: VALUE
```

Then test this bad pattern:

```bash
created_dir=$(mkdir -p bash-lab/temp/test-output)
```

Print:

```text
created_dir value: VALUE
```

Answer:

- Why did the directory still get created?
- Why was the variable empty?
- When is command substitution useful?
- When is command substitution the wrong tool?

---

## Challenge 4 — File and Directory Validator

Create:

```text
bash-lab/scripts/challenge_validator.sh
```

The script must check:

```text
bash-lab/input/app.log
bash-lab/input/users.txt
bash-lab/input/config.env
bash-lab/input/fake.log
bash-lab/output/
bash-lab/errors/
```

Required output:

```text
FOUND file: bash-lab/input/app.log
FOUND file: bash-lab/input/users.txt
FOUND file: bash-lab/input/config.env
MISSING file: bash-lab/input/fake.log
FOUND directory: bash-lab/output/
FOUND directory: bash-lab/errors/
```

Rules:

- Use `-f` for files
- Use `-d` for directories
- Use `!` for missing checks
- Do not use vague messages

Answer:

- What does `-f` check?
- What does `-d` check?
- What does `!` mean in a condition?
- Why is `Missing file: bash-lab/input/fake.log` better than `file missing`?

---

## Challenge 5 — Nested If Logic

Create:

```text
bash-lab/scripts/challenge_warning_check.sh
```

Requirements:

1. Check whether `bash-lab/input/app.log` exists
2. If the file exists, count WARNING lines
3. If the count is zero, print:

```text
No warnings found
```

4. If the count is greater than zero, print:

```text
Warnings found: NUMBER
```

5. If the file is missing, print:

```text
Missing file: bash-lab/input/app.log
```

Failure test:

1. Rename `app.log` to `app.log.bak`
2. Run the script
3. Confirm the missing-file message appears
4. Restore the file

Answer:

- Why does the warning-count check belong inside the file-exists check?
- What does this mean?

```text
Outer if = can the job run?
Inner if = what was the result?
```

---

## Challenge 6 — Numeric Comparisons

Create:

```text
bash-lab/scripts/challenge_numbers.sh
```

Create these variables:

```bash
error_count=5
warning_count=2
zero_count=0
```

The script must print correct messages using:

```text
-eq
-ne
-gt
-lt
-ge
-le
```

Required output must include:

```text
Errors are greater than warnings
Warnings are less than errors
Zero count equals zero
Error count is not equal to warning count
Error count is greater than or equal to 5
Warning count is less than or equal to 2
```

Answer:

- What is the difference between `=` and `-eq`?
- Why should numbers use numeric comparison operators?

---

## Challenge 7 — Script Arguments

Create:

```text
bash-lab/scripts/challenge_args.sh
```

The script must accept:

```text
FILE
PATTERN
```

Run example:

```bash
./bash-lab/scripts/challenge_args.sh bash-lab/input/app.log ERROR
```

Expected output:

```text
File: bash-lab/input/app.log
Pattern: ERROR
All arguments: bash-lab/input/app.log ERROR
Argument count: 2
```

If no arguments are passed, expected output:

```text
Error: missing arguments
Usage: ./challenge_args.sh FILE PATTERN
```

Rules:

- Use `$1`
- Use `$2`
- Use `$@`
- Use `$#`
- If fewer than 2 arguments are provided, show usage and stop

Answer:

- What does `$1` mean?
- What does `$2` mean?
- What does `$@` mean?
- What does `$#` mean?
- Why do arguments make scripts reusable?

---

## Challenge 8 — Exit Code Validator

Create:

```text
bash-lab/scripts/challenge_exit_codes.sh
```

The script must accept one file path argument.

Behaviour:

### Case 1 — No argument

Run:

```bash
./bash-lab/scripts/challenge_exit_codes.sh
echo $?
```

Expected output:

```text
Error: no file path provided
Usage: ./challenge_exit_codes.sh FILE
```

Expected exit code:

```text
2
```

### Case 2 — Existing file

Run:

```bash
./bash-lab/scripts/challenge_exit_codes.sh bash-lab/input/app.log
echo $?
```

Expected output:

```text
File exists: bash-lab/input/app.log
```

Expected exit code:

```text
0
```

### Case 3 — Missing file

Run:

```bash
./bash-lab/scripts/challenge_exit_codes.sh bash-lab/input/missing.log
echo $?
```

Expected output:

```text
Missing file: bash-lab/input/missing.log
```

Expected exit code:

```text
1
```

Answer:

- What does exit code `0` mean?
- What does exit code `1` mean?
- Why might missing arguments use exit code `2`?
- Why do exit codes matter in CI/CD?

---

## Challenge 9 — Debug a Broken Script

Create:

```text
bash-lab/scripts/challenge_debug_paths.sh
```

The first version must intentionally include a broken path variable.

The script must print debug lines:

```text
DEBUG report_directory=VALUE
DEBUG timestamp=VALUE
DEBUG report_filename=VALUE
```

Then fix the script so it:

1. Creates `bash-lab/output/`
2. Writes a report file into `bash-lab/output/`
3. Prints:

```text
Report written to: PATH
```

Answer:

- Which variable was wrong?
- How did `echo` help you find the problem?
- What should you print when debugging path issues?

---

## Challenge 10 — Bash Trace

Use the script from Challenge 9.

Run:

```bash
bash -x bash-lab/scripts/challenge_debug_paths.sh
```

Then temporarily add:

```bash
set -x
```

and later:

```bash
set +x
```

Answer:

- What does `bash -x` show?
- What does `set -x` do?
- Why should debugging output be removed or turned off after fixing the issue?

---

## Challenge 11 — Working Directory Trap

Create:

```text
bash-lab/scripts/challenge_location.sh
```

The script must print:

```text
Current working directory: VALUE
Script path: VALUE
```

Then it must try to read:

```text
bash-lab/input/app.log
```

Tasks:

1. Run the script from the lab root
2. Run the script from inside `bash-lab/scripts/`
3. Observe what changes
4. Diagnose any path failure

Answer:

- What is the current working directory?
- What is the script path?
- Why can a script fail when run from a different directory?
- How did this connect to the rebuild challenge?

---

## Challenge 12 — Specific Error Messages

Create:

```text
bash-lab/scripts/challenge_required_files.sh
```

The script must check:

```text
bash-lab/input/app.log
bash-lab/input/users.txt
bash-lab/input/config.env
```

Behaviour:

### If all files exist

Print:

```text
All required input files found
```

Exit code:

```text
0
```

### If any file is missing

Print every missing file individually.

Example:

```text
Missing file: bash-lab/input/config.env
```

Exit code:

```text
1
```

Failure test:

1. Temporarily rename `config.env`
2. Run the script
3. Confirm it names the missing file
4. Confirm exit code is `1`
5. Restore `config.env`

Answer:

- Why should the script keep checking after it finds one missing file?
- Why are specific error messages high quality?
- Why is a correct exit code part of good scripting?

---

## Challenge 13 — Final Script Build: Pattern Report Tool

Create:

```text
bash-lab/scripts/pattern_report.sh
```

This is the main challenge.

The script must accept two arguments:

```text
FILE
PATTERN
```

Example:

```bash
./bash-lab/scripts/pattern_report.sh bash-lab/input/app.log ERROR
```

The script must:

1. Check that exactly two arguments were provided
2. If not, print:

```text
Error: expected 2 arguments
Usage: ./pattern_report.sh FILE PATTERN
```

and exit with code `2`

3. Check that the file exists
4. If missing, print:

```text
Missing file: FILE
```

and exit with code `1`

5. Create:

```text
bash-lab/output/
bash-lab/errors/
```

6. Create a timestamp
7. Count matching lines case-insensitively
8. Create a timestamped report inside `bash-lab/output/`

Report filename format:

```text
pattern-report-YYYY-MM-DD_HH-MM-SS.txt
```

Report must include:

```text
Pattern Report
Generated: TIMESTAMP
File scanned: FILE
Pattern searched: PATTERN
Match count: NUMBER
```

9. If matches exist, include matching lines
10. If no matches exist, include:

```text
No matches found
```

11. Print:

```text
Report written to: PATH
```

12. Exit with code `0`

Required tests:

```bash
./bash-lab/scripts/pattern_report.sh bash-lab/input/app.log ERROR
echo $?

./bash-lab/scripts/pattern_report.sh bash-lab/input/app.log WARNING
echo $?

./bash-lab/scripts/pattern_report.sh bash-lab/input/app.log CRITICAL
echo $?

./bash-lab/scripts/pattern_report.sh bash-lab/input/fake.log ERROR
echo $?

./bash-lab/scripts/pattern_report.sh
echo $?
```

Pass condition:

- ERROR report works
- WARNING report works
- zero-match report works
- missing-file path works
- missing-argument path works
- exit codes are correct
- reports are readable
- variables are quoted
- no vague errors are used
- you can explain every line

---

## Challenge 14 — Break/Fix Gauntlet

For each broken line, diagnose the issue and write the corrected version.

### Broken A — Wrong shebang

```bash
!#/bin/bash
```

Explain:

- why it is wrong
- corrected version

---

### Broken B — Bad variable assignment

```bash
report_directory = "bash-lab/output"
```

Explain:

- why it is wrong
- corrected version

---

### Broken C — Unquoted path

```bash
echo "hello" >> $report_filename
```

Explain:

- why it can break
- corrected version

---

### Broken D — Useless command substitution

```bash
created_dir=$(mkdir -p bash-lab/output)
```

Explain:

- why the directory is created
- why the variable is empty
- corrected version

---

### Broken E — Bad file check

```bash
if [ -f bash-lab/input/app.log bash-lab/input/users.txt ]; then
```

Explain:

- why it is wrong
- corrected version

---

### Broken F — Bad bracket spacing

```bash
if [! -f bash-lab/input/app.log ]; then
```

Explain:

- why it is wrong
- corrected version

---

### Broken G — Wrong numeric comparison

```bash
if [ "$count" = 0 ]; then
```

Explain:

- why this is not the right numeric comparison
- corrected version

---

### Broken H — Result check before file check

```bash
count=$(grep -i "ERROR" bash-lab/input/app.log | wc -l)

if [ "$count" -eq 0 ]; then
    echo "No errors found"
fi

if [ ! -f bash-lab/input/app.log ]; then
    echo "Missing file"
fi
```

Explain:

- why this order is logically wrong
- corrected structure

---

### Broken I — Wrong exit code

```bash
echo "Missing file"
exit 0
```

Explain:

- why this is wrong
- corrected version

---

### Broken J — Wrong run location

A script uses:

```bash
grep -i "ERROR" input/app.log
```

It works inside `bash-lab/`, but fails from the lab root.

Explain:

- why it fails
- how to run it correctly
- how to think about relative paths

---

## Challenge 15 — Final No-Hints Check

Answer instantly, without notes:

- What does the shebang do?
- Why does `./script.sh` need execute permission?
- What is the difference between `bash script.sh` and `./script.sh`?
- Why are there no spaces around `=` in Bash variables?
- Why should variables be quoted?
- When should command substitution be used?
- When should command substitution not be used?
- What does `-f` check?
- What does `-d` check?
- What does `!` mean in a condition?
- Why do nested `if` statements matter?
- What is the difference between `=` and `-eq`?
- What does `$1` mean?
- What does `$2` mean?
- What does `$@` mean?
- What does `$#` mean?
- What does `$?` mean?
- What does `exit 0` mean?
- What does `exit 1` mean?
- What does `exit 2` usually mean in this lab?
- How does `bash -x` help?
- What does `set -x` do?
- Why does current working directory matter?
- What makes an error message useful?
- Why should success and failure paths both be tested?

---

## Pass Criteria

You pass this lab only if you can:

- write Bash scripts from scratch
- run scripts with `bash script.sh`
- run scripts with `./script.sh`
- fix execute permission problems
- assign variables correctly
- quote variables safely
- use command substitution correctly
- explain when command substitution is the wrong tool
- check files with `-f`
- check directories with `-d`
- check missing paths with `!`
- write nested `if` logic correctly
- compare numbers with numeric operators
- use `$1`, `$2`, `$@`, and `$#`
- return correct exit codes
- inspect `$?`
- debug with `echo`
- debug with `bash -x`
- understand working directory vs script location
- write specific error messages
- build the final `pattern_report.sh` without copying
- pass success, missing-file, missing-argument, and zero-match tests
- explain every line of your final script

If you cannot complete Challenge 13 and explain every line, repeat the lab before moving to process management.