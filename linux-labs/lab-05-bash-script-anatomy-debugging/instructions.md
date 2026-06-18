cat > instructions.md <<'EOF'
# Lab 05 — Bash Script Anatomy, Conditions & Debugging

## Objective

Develop the ability to write, run, debug, and explain Bash scripts that behave predictably.

This lab exists to turn you from someone who can run Linux commands into someone who can build reliable operational scripts.

By the end of this lab, you must be able to:

- write Bash scripts from scratch
- structure scripts clearly
- use variables safely
- quote variables correctly
- use command substitution only when it makes sense
- write file and directory checks
- use `if`, `else`, and nested `if` statements correctly
- compare numbers properly
- pass arguments into scripts
- understand exit codes
- debug scripts without guessing
- handle missing files clearly
- create useful reports
- explain every line of your script

---

## Scenario

You are a junior DevOps engineer responsible for writing small operational scripts.

These scripts are used to:

- validate files before processing them
- generate reports
- handle missing inputs
- write errors to an error folder
- print useful messages to the terminal
- fail clearly when something is wrong

In production, weak scripts create confusion.

A bad script might:

- silently fail
- write output to the wrong place
- hide errors
- overwrite useful files
- continue running when required inputs are missing
- produce vague messages like `something went wrong`

A good script:

- checks inputs before using them
- creates required output folders
- uses clear variable names
- quotes variables
- exits with a meaningful status code
- tells the user exactly what happened
- can be debugged quickly

This lab trains that standard.

---

## Production Framing

Real DevOps, cloud, platform, and infrastructure work depends heavily on automation.

Before using tools like Docker, Terraform, AWS, GitHub Actions, or Kubernetes, you must understand how small scripts behave.

This lab prepares you for future projects such as:

- server health check reporters
- deployment readiness checkers
- backup verification scripts
- incident response automation
- CI/CD validation scripts
- cloud operations tooling

The goal is not to memorise Bash syntax.

The goal is to build scripts that reduce manual work, reduce mistakes, and produce clear evidence.

---

## Mandatory Rules

- Do not copy commands blindly.
- Before running a script, write what you expect it to do.
- After running a script, verify what actually happened.
- Every script must be tested in both success and failure conditions.
- Every script must write useful output.
- Every script must have clear variable names.
- Every script must quote variables when used.
- Every file path must be intentional.
- Every `if` statement must be explainable in plain English.
- Every error message must say exactly what failed.
- Do not move on if you cannot explain the script without looking at notes.
- Record all mistakes and fixes in `evidence.md`.

---

## Environment Setup

Create this structure inside the lab folder:

```text
bash-lab/
├── scripts/
├── input/
├── output/
├── errors/
└── temp/
```

Create these files:

```text
input/app.log
input/users.txt
input/config.env
```

Populate `input/app.log` with at least 10 lines.

It must include:

- INFO lines
- WARNING lines
- ERROR lines
- repeated WARNING lines
- repeated ERROR lines

Example format:

```text
2026-06-06 10:00:01 INFO Application started
2026-06-06 10:01:10 WARNING High memory usage
2026-06-06 10:02:22 ERROR Database connection failed
```

Populate `input/users.txt` with at least 10 names.

It must include:

- duplicate names
- unique names

Populate `input/config.env` with:

```text
APP_ENV=dev
PORT=8080
DEBUG=true
```

Verify setup with:

```bash
pwd
ls
ls -R bash-lab
```

Pass condition:

- `bash-lab/` exists
- all folders exist
- all three input files exist
- files contain realistic test data

---

## Task 1 — Script Anatomy

Create:

```text
bash-lab/scripts/hello_script.sh
```

The script must:

- start with the correct shebang
- contain a comment explaining the script purpose
- create one variable
- print a message using that variable

Required behaviour:

When run, the script must print:

```text
Hello from Lab 05
```

Run it two ways:

```bash
bash bash-lab/scripts/hello_script.sh
./bash-lab/scripts/hello_script.sh
```

You must intentionally run it once before adding execute permission.

Then fix it using `chmod`.

Pass condition:

- You can explain why `bash script.sh` works without execute permission
- You can explain why `./script.sh` needs execute permission
- You can explain what the shebang does

---

## Task 2 — Variables and Quoting

Create:

```text
bash-lab/scripts/path_builder.sh
```

The script must define:

```bash
report_directory="output"
report_name="daily report.txt"
```

It must build a full path using those variables.

Required output:

```text
Report path: output/daily report.txt
```

Then change:

```bash
report_directory="output reports"
```

Run the script again.

Pass condition:

- The script still prints the correct full path
- It does not break because of spaces
- You can explain why `"$variable"` is safer than `$variable`

You must document one failed unquoted example in `evidence.md`.

---

## Task 3 — Command Substitution: Useful vs Useless

Create:

```text
bash-lab/scripts/command_substitution_test.sh
```

The script must use command substitution to store:

- current timestamp
- total lines in `input/app.log`
- total users in `input/users.txt`
- total WARNING lines in `input/app.log`

The script must print:

```text
Timestamp: VALUE
App log lines: VALUE
User count: VALUE
Warning count: VALUE
```

Then intentionally test this bad pattern inside the script:

```bash
created_output=$(mkdir -p bash-lab/output)
```

You must print:

```text
created_output value: VALUE
```

Pass condition:

- You can explain why `date`, `grep`, and `wc -l` are useful with command substitution
- You can explain why `mkdir -p` is not useful with command substitution
- You can explain the difference between a command that produces output and a command that performs an action

Rule to remember:

```text
Use command substitution when you need the command output.
Do not use command substitution just to run an action.
```

---

## Task 4 — File and Directory Checks

Create:

```text
bash-lab/scripts/check_inputs.sh
```

The script must check:

```text
bash-lab/input/app.log
bash-lab/input/users.txt
bash-lab/input/config.env
bash-lab/input/missing.log
bash-lab/output/
bash-lab/errors/
```

Required output format:

```text
FOUND file: bash-lab/input/app.log
FOUND file: bash-lab/input/users.txt
FOUND file: bash-lab/input/config.env
MISSING file: bash-lab/input/missing.log
FOUND directory: bash-lab/output/
FOUND directory: bash-lab/errors/
```

Pass condition:

- Uses `-f` for files
- Uses `-d` for directories
- Uses `!` to check missing paths
- Gives specific messages
- Does not say vague things like `file missing`

You must explain:

```text
-f
-d
!
```

---

## Task 5 — If / Else and Nested Conditions

Create:

```text
bash-lab/scripts/warning_detector.sh
```

The script must:

1. Check whether `bash-lab/input/app.log` exists.
2. If the file exists, count WARNING lines.
3. If warning count is 0, print:

```text
No warnings found
```

4. If warning count is greater than 0, print:

```text
Warnings found: NUMBER
```

5. If the file is missing, print:

```text
Missing file: bash-lab/input/app.log
```

Pass condition:

- The file-exists check is the outer `if`
- The zero-warning check is inside the file-exists block
- You can explain:

```text
Outer if = can the job run?
Inner if = what was the result?
```

Failure test:

- Temporarily rename `app.log`
- Run the script
- Confirm the missing-file message appears
- Restore the file

---

## Task 6 — Numeric Comparisons

Create:

```text
bash-lab/scripts/number_compare.sh
```

The script must define:

```bash
low_number=3
high_number=10
same_number=10
```

The script must correctly test and print examples for:

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
10 is greater than 3
3 is less than 10
10 is equal to 10
10 is greater than or equal to 10
3 is not equal to 10
3 is less than or equal to 10
```

Pass condition:

- You use numeric comparison operators
- You can explain why `-eq` is not the same as `=`
- You can explain when to compare strings vs numbers

---

## Task 7 — Script Arguments

Create:

```text
bash-lab/scripts/argument_checker.sh
```

The script must use:

```text
$1
$2
$@
$#
```

Run:

```bash
./bash-lab/scripts/argument_checker.sh app.log warning
```

Expected output:

```text
First argument: app.log
Second argument: warning
All arguments: app.log warning
Argument count: 2
```

Run:

```bash
./bash-lab/scripts/argument_checker.sh
```

Expected output:

```text
No arguments provided
Usage: ./argument_checker.sh FILE PATTERN
```

Pass condition:

- Handles missing arguments
- Prints usage instructions
- You can explain `$1`, `$2`, `$@`, and `$#`

---

## Task 8 — Exit Codes

Create:

```text
bash-lab/scripts/exit_code_validator.sh
```

The script must accept one argument: a file path.

If no argument is provided, it must print:

```text
Error: no file path provided
Usage: ./exit_code_validator.sh FILE
```

and exit with code `2`.

If the file exists, it must print:

```text
File exists: FILE
```

and exit with code `0`.

If the file does not exist, it must print:

```text
Missing file: FILE
```

and exit with code `1`.

Test with:

```bash
./bash-lab/scripts/exit_code_validator.sh bash-lab/input/app.log
echo $?
```

```bash
./bash-lab/scripts/exit_code_validator.sh bash-lab/input/fake.log
echo $?
```

```bash
./bash-lab/scripts/exit_code_validator.sh
echo $?
```

Pass condition:

- Existing file returns `0`
- Missing file returns `1`
- Missing argument returns `2`
- You can explain why exit codes matter in automation and CI/CD

---

## Task 9 — Debugging with Echo

Create:

```text
bash-lab/scripts/debug_paths.sh
```

The script must intentionally build a broken report path first.

It must print debug values:

```text
DEBUG report_directory=VALUE
DEBUG timestamp=VALUE
DEBUG report_filename=VALUE
```

Then fix the path.

Required final behaviour:

- creates `bash-lab/output/`
- writes a report file into `bash-lab/output/`
- prints the final report path

Pass condition:

- You can use `echo` to inspect variable values
- You can find a broken path by printing variables
- You can explain which variable caused the issue

---

## Task 10 — Debugging with Bash Trace

Run:

```bash
bash -x bash-lab/scripts/debug_paths.sh
```

Then temporarily add this inside the script:

```bash
set -x
```

and later turn it off:

```bash
set +x
```

Pass condition:

- You can explain what `bash -x` shows
- You can explain when tracing is useful
- You can explain why you should not leave noisy debug tracing on forever

---

## Task 11 — Working Directory vs Script Location

Create:

```text
bash-lab/scripts/location_test.sh
```

The script must print:

```text
Current working directory: VALUE
Script path: VALUE
```

It must then try to read:

```text
bash-lab/input/app.log
```

Run it from the lab root.

Then run it from inside:

```text
bash-lab/scripts/
```

Pass condition:

- You can explain why relative paths depend on where the command is run from
- You can explain the difference between the current working directory and the script file location
- You can explain why your rebuild script failed when run from the wrong folder

---

## Task 12 — Specific Error Messages

Create:

```text
bash-lab/scripts/input_validator.sh
```

The script must check these files:

```text
bash-lab/input/app.log
bash-lab/input/users.txt
bash-lab/input/config.env
```

If all exist, it must print:

```text
All required input files found
```

If one or more are missing, it must print exactly which ones are missing.

Example:

```text
Missing file: bash-lab/input/config.env
```

Pass condition:

- Does not use vague errors
- Identifies every missing file
- Still checks the remaining files even if one is missing
- Exits with code `1` if any file is missing
- Exits with code `0` if all files exist

---

## Task 13 — Report Generator Drill

Create:

```text
bash-lab/scripts/log_report.sh
```

This is the final drill for the lab.

The script must:

1. Create `bash-lab/output/` if missing.
2. Create `bash-lab/errors/` if missing.
3. Create a timestamp.
4. Check if `bash-lab/input/app.log` exists.
5. If missing:
   - write `Missing file: bash-lab/input/app.log` into an error file inside `bash-lab/errors/`
   - print where the error file was written
   - exit with code `1`
6. If present:
   - count ERROR lines
   - count WARNING lines
   - create a timestamped report inside `bash-lab/output/`
   - include report title
   - include timestamp
   - include file scanned
   - include ERROR count
   - include WARNING count
   - include matching ERROR and WARNING lines
   - print where the report was written
   - exit with code `0`

Report filename format:

```text
bash-lab/output/log-report-YYYY-MM-DD_HH-MM-SS.txt
```

Error filename format:

```text
bash-lab/errors/log-report-error-YYYY-MM-DD_HH-MM-SS.log
```

Pass condition:

- Report is created when input exists
- Error log is created when input is missing
- Exit code is correct
- Output paths are clear
- You can explain every line

This drill is not a mini-project. It is a controlled script-building test.

---

## Break/Fix Tasks

You must intentionally break and fix these.

### Break/Fix 1 — Wrong Shebang

Break:

```bash
!#/bin/bash
```

Expected failure:

- script does not run correctly

Fix:

```bash
#!/bin/bash
```

Record in `evidence.md`.

---

### Break/Fix 2 — Bad Variable Assignment

Break:

```bash
name = "value"
```

Expected failure:

- Bash does not treat it as variable assignment

Fix:

```bash
name="value"
```

Record in `evidence.md`.

---

### Break/Fix 3 — Unquoted Variable

Break a script by using an unquoted path with spaces.

Fix it using:

```bash
"$variable"
```

Record before/after output.

---

### Break/Fix 4 — Wrong Command Substitution

Use:

```bash
created_dir=$(mkdir -p bash-lab/output)
```

Explain why the directory is created but the variable is empty.

Replace with:

```bash
mkdir -p bash-lab/output
```

Record what changed.

---

### Break/Fix 5 — Bad File Check

Break:

```bash
if [ -f bash-lab/input/app.log bash-lab/input/users.txt ]; then
```

Fix:

```bash
if [ -f bash-lab/input/app.log ] && [ -f bash-lab/input/users.txt ]; then
```

Record why each file needs its own test.

---

### Break/Fix 6 — Bad Bracket Spacing

Break:

```bash
if [! -f bash-lab/input/app.log ]; then
```

Fix:

```bash
if [ ! -f bash-lab/input/app.log ]; then
```

Record why spaces matter.

---

### Break/Fix 7 — Wrong If Placement

Move a result-check outside the file-exists block.

Explain why this is logically wrong.

Fix it by nesting the result-check inside the file-exists block.

Record:

```text
Outer if = can the job run?
Inner if = what was the result?
```

---

### Break/Fix 8 — Wrong Working Directory

Run a script from a different directory so relative paths fail.

Record:

- where you ran it from
- what path the script expected
- why it failed
- how you fixed it

---

### Break/Fix 9 — Wrong Redirect Target

Redirect output into the wrong file.

Find where the output went.

Fix the target.

Record the exact before/after command.

---

### Break/Fix 10 — Wrong Exit Code

Make a script print an error but still exit `0`.

Fix it so failure exits `1`.

Record why exit codes matter.

---

## Evidence Requirements

Your `evidence.md` must include:

- at least 8 mistakes or break/fix cases
- the broken command or script line
- the error or wrong behaviour
- the cause
- the fix
- what you learned

Format:

```markdown
## Issue X — Title

**What I tried:**

**What happened:**

**Why it happened:**

**How I fixed it:**

**What I learned:**
```

---

## Notes Requirements

Your `notes.md` must explain in your own words:

- shebang
- variables
- quoting
- command substitution
- file checks
- directory checks
- `if`, `else`, `fi`
- nested conditions
- numeric comparisons
- script arguments
- exit codes
- debugging with `echo`
- debugging with `bash -x`
- working directory vs script location
- clear error messages

No copy-paste definitions.

You must explain them like you are teaching someone else.

---

## README Requirements

Your `README.md` must include:

- lab overview
- what this lab taught
- why Bash scripting matters for DevOps/cloud/platform work
- commands/concepts practised
- scripts created
- key debugging lessons
- how this lab prepares for process management and system monitoring

---

## Challenge Requirements

Your `challenge.md` must test whether you can build a script cold.

The challenge must require:

- variables
- command substitution
- file checks
- nested `if`
- output report
- error handling
- exit codes
- arguments

No hints in the challenge.

---

## Verification Checkpoints

You must be able to answer instantly:

- What does the shebang do?
- Why does `./script.sh` need execute permission?
- Difference between `bash script.sh` and `./script.sh`?
- Why no spaces around `=`?
- Why quote variables?
- When should command substitution be used?
- When should command substitution not be used?
- What does `-f` check?
- What does `-d` check?
- What does `!` mean?
- Why do nested `if` statements matter?
- Difference between `=` and `-eq`?
- What does `$1` mean?
- What does `$#` mean?
- What does `$@` mean?
- What does `$?` mean?
- What does `exit 0` mean?
- What does `exit 1` mean?
- How does `bash -x` help?
- Why does current working directory matter?
- What makes an error message useful?

---

## Final Pass Standard

You pass this lab only when you can build this from scratch without notes:

A script that:

- accepts a file path as argument
- accepts a search pattern as argument
- checks whether both arguments were provided
- checks whether the file exists
- creates output and error directories
- counts matching lines
- creates a timestamped report
- handles zero matches
- writes specific errors
- exits with correct exit codes
- can be debugged with `bash -x`

Required run examples:

```bash
./script.sh bash-lab/input/app.log ERROR
./script.sh bash-lab/input/app.log WARNING
./script.sh bash-lab/input/fake.log ERROR
./script.sh
```

You are ready to move on only when:

- the success path works
- the missing-file path works
- the missing-argument path works
- the zero-match path works
- you can explain every line
- you can fix at least 8 intentional mistakes
- you can run the script from the correct location without confusion

If you cannot do this yet, repeat the lab.