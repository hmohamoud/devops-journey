# Evidence

## Completed Tasks

### Environment Setup
- Created structured lab environment:
  - `shell-lab/`
    - `input/`
    - `output/`
    - `errors/`
    - `temp/`

- Created working files:
  - `input/users.txt`
  - `input/logs.txt`
  - `input/commands.txt`

- Verified structure using:
  - `ls`
  - `ls -R`

---

### Output Redirection (stdout)

- Redirected command output:
  - `ls input > redirect_output.txt`

- Appended output:
  - `echo "Hello World" >> redirect_output.txt`

- Moved file to output directory:
  - `mv redirect_output.txt output/`

- Verified using:
  - `cat`
  - `wc -l`

---

### Input Redirection (stdin)

- Used standard input:
  - `wc -l output/redirect_output.txt`

- Used redirected input:
  - `grep "Hello" < output/redirect_output.txt`

- Compared both methods

---

### Error Redirection (stderr)

- Captured errors:
  - `ls fakefolder 2> output/redirect_error_output.txt`

- Appended errors:
  - `cd fakefolder 2>> output/redirect_error_output.txt`

- Generated errors using:
  - invalid paths
  - missing files

---

### Separating stdout and stderr

- Redirected output and errors to different files:
  - `ls input > output/redirect_output.txt 2> output/redirect_error_output.txt`

---

### Combining stdout and stderr

- Combined both streams:
  - `ls input fakefolder > output/combined_output_errors.txt 2>&1`

- Verified combined logs contained:
  - valid output
  - error messages

---

### Pipes and Command Chaining

- Counted error logs:
  - `grep -i "ERROR" input/logs.txt | wc -l`

- Found duplicates:
  - `grep -i "ERROR" input/logs.txt | sort | uniq -c`

- Ranked frequency:
  - `sort -nr`

- Extracted top result:
  - `head -1`

---

### Command Substitution

- Embedded command results:
  - `echo "Count Errors: $(grep -c "ERROR" input/logs.txt)"`

- Used input redirection inside substitution:
  - `echo "Count Number of users: $(wc -l < input/users.txt)"`

---

### Command Discovery

- Used:
  - `man ls`
  - `grep --help`
  - `which ls`

- Observed differences:
  - some commands don’t support `--help` (macOS behaviour)

---

### Environment Variables

- Inspected PATH:
  - `echo $PATH`

- Viewed environment:
  - `env`

- Created variables:
  - `name="Hamza"`

- Exported variable:
  - `export project="Devops"`

- Verified persistence in subshell

---

### Permissions & Superuser

- Modified permissions:
  - `chmod 044 input/commands.txt`

- Encountered permission denial:
  - `cat: Permission denied`

- Used elevated access:
  - `sudo cat input/commands.txt`

---

### Shell Workflow Control

- Used:
  - `Ctrl+C` (interrupt)
  - `alias list="ls -l"`

- Executed alias successfully

---

## Break/Fix Logs

### Issue 1 — Wrong redirect filename

Problem:
`cat input/commands.txt >> redirect_output.txxt`

Cause:
Typo in filename

Diagnosis:
File not found when attempting removal

Fix:
Used correct path:
`cat input/commands.txt >> output/redirect_output.txt`

Prevention:
Always verify filenames before redirecting

---

### Issue 2 — Misplaced output file

Problem:
Created file in wrong directory

Cause:
Did not specify output path

Fix:
Moved file:
`mv redirect_output.txt output/`

Prevention:
Always define output path explicitly

---

### Issue 3 — Incorrect redirection syntax

Problem:
`2>>&1`

Cause:
Invalid syntax

Fix:
Corrected to:
`2>&1`

Prevention:
Understand redirection operators clearly

---

### Issue 4 — Missing file errors

Problem:
`cat missing.txt`

Cause:
File does not exist

Fix:
Captured error:
`2>> output/redirect_error_output.txt`

Prevention:
Validate files before usage

---

### Issue 5 — Overwriting files accidentally

Problem:
Used `>` on existing file

Cause:
`>` overwrites by default

Fix:
Rebuilt file contents

Prevention:
Use `>>` when appending

---

### Issue 6 — Environment variable syntax error

Problem:
`name = "Hamza"`

Cause:
Spaces around `=`

Fix:
`name="Hamza"`

Prevention:
Shell variables require no spaces

---

### Issue 7 — Wrong directory assumptions

Problem:
Tried accessing non-existent directories

Cause:
Incorrect mental model of structure

Fix:
Used `ls` to verify paths

Prevention:
Always check directory before executing

---

## Key Patterns

- Most issues came from:
  - incorrect paths
  - syntax mistakes
  - misunderstanding redirection behaviour
  - file overwrite vs append confusion

- Effective debugging tools:
  - `ls`
  - `cat`
  - `pwd`
  - checking output files directly

---

## Main Takeaways

- Shell commands are not just tools — they form data pipelines
- stdout and stderr must be controlled intentionally
- `>` overwrites, `>>` appends — critical distinction
- `2>` isolates errors — essential for debugging systems
- `2>&1` merges streams — useful for logging
- Pipes (`|`) enable chaining and automation
- Command substitution allows dynamic workflows
- Environment variables control system behaviour
- Permissions affect command execution directly
- Small syntax errors can break workflows entirely
- Always think:
  - where is input coming from?
  - where is output going?
  - what happens if this fails?
# Evidence

## Completed Tasks

### Environment Setup
- Created structured lab environment:
  - `shell-lab/`
    - `input/`
    - `output/`
    - `errors/`
    - `temp/`

- Created working files:
  - `input/users.txt`
  - `input/logs.txt`
  - `input/commands.txt`

- Verified structure using:
  - `ls`
  - `ls -R`

---

### Output Redirection (stdout)

- Redirected command output:
  - `ls input > redirect_output.txt`

- Appended output:
  - `echo "Hello World" >> redirect_output.txt`

- Moved file to output directory:
  - `mv redirect_output.txt output/`

- Verified using:
  - `cat`
  - `wc -l`

---

### Input Redirection (stdin)

- Used standard input:
  - `wc -l output/redirect_output.txt`

- Used redirected input:
  - `grep "Hello" < output/redirect_output.txt`

- Compared both methods

---

### Error Redirection (stderr)

- Captured errors:
  - `ls fakefolder 2> output/redirect_error_output.txt`

- Appended errors:
  - `cd fakefolder 2>> output/redirect_error_output.txt`

- Generated errors using:
  - invalid paths
  - missing files

---

### Separating stdout and stderr

- Redirected output and errors to different files:
  - `ls input > output/redirect_output.txt 2> output/redirect_error_output.txt`

---

### Combining stdout and stderr

- Combined both streams:
  - `ls input fakefolder > output/combined_output_errors.txt 2>&1`

- Verified combined logs contained:
  - valid output
  - error messages

---

### Pipes and Command Chaining

- Counted error logs:
  - `grep -i "ERROR" input/logs.txt | wc -l`

- Found duplicates:
  - `grep -i "ERROR" input/logs.txt | sort | uniq -c`

- Ranked frequency:
  - `sort -nr`

- Extracted top result:
  - `head -1`

---

### Command Substitution

- Embedded command results:
  - `echo "Count Errors: $(grep -c "ERROR" input/logs.txt)"`

- Used input redirection inside substitution:
  - `echo "Count Number of users: $(wc -l < input/users.txt)"`

---

### Command Discovery

- Used:
  - `man ls`
  - `grep --help`
  - `which ls`

- Observed differences:
  - some commands don’t support `--help` (macOS behaviour)

---

### Environment Variables

- Inspected PATH:
  - `echo $PATH`

- Viewed environment:
  - `env`

- Created variables:
  - `name="Hamza"`

- Exported variable:
  - `export project="Devops"`

- Verified persistence in subshell

---

### Permissions & Superuser

- Modified permissions:
  - `chmod 044 input/commands.txt`

- Encountered permission denial:
  - `cat: Permission denied`

- Used elevated access:
  - `sudo cat input/commands.txt`

---

### Shell Workflow Control

- Used:
  - `Ctrl+C` (interrupt)
  - `alias list="ls -l"`

- Executed alias successfully

---

## Break/Fix Logs

### Issue 1 — Wrong redirect filename

Problem:
`cat input/commands.txt >> redirect_output.txxt`

Cause:
Typo in filename

Diagnosis:
File not found when attempting removal

Fix:
Used correct path:
`cat input/commands.txt >> output/redirect_output.txt`

Prevention:
Always verify filenames before redirecting

---

### Issue 2 — Misplaced output file

Problem:
Created file in wrong directory

Cause:
Did not specify output path

Fix:
Moved file:
`mv redirect_output.txt output/`

Prevention:
Always define output path explicitly

---

### Issue 3 — Incorrect redirection syntax

Problem:
`2>>&1`

Cause:
Invalid syntax

Fix:
Corrected to:
`2>&1`

Prevention:
Understand redirection operators clearly

---

### Issue 4 — Missing file errors

Problem:
`cat missing.txt`

Cause:
File does not exist

Fix:
Captured error:
`2>> output/redirect_error_output.txt`

Prevention:
Validate files before usage

---

### Issue 5 — Overwriting files accidentally

Problem:
Used `>` on existing file

Cause:
`>` overwrites by default

Fix:
Rebuilt file contents

Prevention:
Use `>>` when appending

---

### Issue 6 — Environment variable syntax error

Problem:
`name = "Hamza"`

Cause:
Spaces around `=`

Fix:
`name="Hamza"`

Prevention:
Shell variables require no spaces

---

### Issue 7 — Wrong directory assumptions

Problem:
Tried accessing non-existent directories

Cause:
Incorrect mental model of structure

Fix:
Used `ls` to verify paths

Prevention:
Always check directory before executing

---

## Key Patterns

- Most issues came from:
  - incorrect paths
  - syntax mistakes
  - misunderstanding redirection behaviour
  - file overwrite vs append confusion

- Effective debugging tools:
  - `ls`
  - `cat`
  - `pwd`
  - checking output files directly

---

## Main Takeaways

- Shell commands are not just tools — they form data pipelines
- stdout and stderr must be controlled intentionally
- `>` overwrites, `>>` appends — critical distinction
- `2>` isolates errors — essential for debugging systems
- `2>&1` merges streams — useful for logging
- Pipes (`|`) enable chaining and automation
- Command substitution allows dynamic workflows
- Environment variables control system behaviour
- Permissions affect command execution directly
- Small syntax errors can break workflows entirely
- Always think:
  - where is input coming from?
  - where is output going?
  - what happens if this fails?