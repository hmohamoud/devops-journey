# Challenge — Shell I/O, Redirection & Command Control

## Rules

- Do NOT use `notes.md`
- Do NOT copy from `instructions.md`
- Predict where output will go before running each command
- Verify every file created with `cat` or `ls`
- If something fails, diagnose it before fixing
- No vague answers: every fix must include the corrected command

---

## Challenge 1 — stdout: overwrite vs append

Create:

- `output/stdout_test.txt`

Tasks:

1. Write the list of files in `input/` into `output/stdout_test.txt` using `>`
2. Append the current date into the same file using `>>`
3. Verify the file contains both outputs
4. Overwrite it again with only `Hello`
5. Explain what was lost and why

---

## Challenge 2 — stdin

Use `input/users.txt`.

Tasks:

1. Count lines using normal file argument
2. Count lines using `<`
3. Compare the output difference

Answer:

- Why does `wc -l input/users.txt` show the filename?
- Why does `wc -l < input/users.txt` not show the filename?

---

## Challenge 3 — stderr only

Create an error intentionally.

Tasks:

1. Run `ls fakefolder`
2. Redirect only the error into `errors/stderr_test.txt`
3. Confirm the error does not appear in terminal
4. Confirm the error exists inside the file

---

## Challenge 4 — stdout and stderr separated

Run one command that includes:

- one valid path
- one invalid path

Tasks:

1. Send normal output to `output/stdout_only.txt`
2. Send errors to `errors/stderr_only.txt`
3. Verify both files

Expected pattern:

- valid output should be in stdout file
- error should be in stderr file

---

## Challenge 5 — stdout and stderr combined

Run one command that includes:

- one valid path
- one invalid path

Tasks:

1. Send both stdout and stderr into `output/combined_streams.txt`
2. Verify the file contains both normal output and error output

Required operator:

- `2>&1`

---

## Challenge 6 — pipeline mastery

Use `input/logs.txt`.

Tasks:

1. Count all ERROR lines ignoring case
2. Count repeated ERROR messages
3. Sort the repeated ERROR counts highest first
4. Show only the most common ERROR

You must use pipes.

---

## Challenge 7 — command substitution

Use `$(...)`.

Tasks:

1. Print:
   `Total users: NUMBER`

2. Print:
   `Total errors: NUMBER`

3. Print:
   `Most common error: RESULT`

Rules:

- NUMBER / RESULT must come from commands
- Do not manually type the values

---

## Challenge 8 — command discovery

Tasks:

1. Find the path of `ls`
2. Find the path of `grep`
3. Use `type` on `cd`
4. Use `man` on `ls`
5. Use `--help` on `grep`

Answer:

- Why is `cd` different from `ls`?
- Why might `ls --help` behave differently on macOS?

---

## Challenge 9 — environment variables

Tasks:

1. Print `$PATH`
2. Create a shell variable called `lab_name`
3. Print it
4. Export a variable called `PROJECT`
5. Start a subshell
6. Confirm exported variable exists in subshell
7. Confirm non-exported variable does not exist in subshell
8. Exit subshell

Answer:

- What is the difference between a shell variable and an exported environment variable?

---

## Challenge 10 — alias and history

Tasks:

1. Create alias:
   `ll="ls -l"`

2. Run `ll`
3. Run `history`
4. Re-run previous command using `!!`

Answer:

- Why are aliases useful?
- Why can aliases be dangerous if badly named?

---

## Challenge 11 — sudo awareness

Tasks:

1. Remove your read permission from a test file
2. Try to read it normally
3. Read it using `sudo`
4. Restore permissions

Answer:

- What did `sudo` allow you to do?
- Why should you not use `sudo` blindly?

---

## Challenge 12 — overwrite accident recovery

Tasks:

1. Create `shell-lab/output/report.txt`
2. Add three lines using `>>`
3. Accidentally overwrite it using `>`
4. Explain what happened
5. Recreate the correct file

Answer:

- What should you use when you want to preserve existing content?

---

## Challenge 13 — debugging redirection

Fix each broken command.

### Broken A
ls input fakefolder > output/a.txt

Problem:
Error still appears in terminal.

Fix it so:
- stdout goes to `output/a.txt`
- stderr goes to `errors/a.err`

---

### Broken B
ls input fakefolder > output/b.txt 2>>&1

Problem:
Invalid redirection syntax.

Fix it so:
- stdout and stderr go into `output/b.txt`

---

### Broken C
wc -l input/users.txt > output/count.txt

Problem:
Output includes filename.

Fix it so:
- output contains only the number

---

### Broken D
echo Count: grep -c ERROR input/logs.txt

Problem:
Command result is not executed inside echo.

Fix it using command substitution.

---

## Challenge 14 — real incident report

Create:

- `output/incident_report.txt`

It must contain:

1. total ERROR count
2. most common ERROR
3. current date
4. command path for `grep`
5. any stderr from checking a fake file

Rules:

- Use redirection
- Use command substitution
- Use pipes
- Capture errors properly
- Verify final report with `cat`

---

## Challenge 15 — final no-hints check

Answer instantly:

- What does `>` do?
- What does `>>` do?
- What does `<` do?
- What does `2>` do?
- What does `2>>` do?
- What does `2>&1` do?
- What does `|` do?
- What does `$(...)` do?
- What is stdout?
- What is stderr?
- What is stdin?
- What is `$PATH`?
- What does `export` do?
- Why should you inspect output files after redirection?

---

## Pass Criteria

You pass this lab only if you can:

- redirect stdout without confusion
- redirect stderr without confusion
- separate stdout and stderr
- combine stdout and stderr
- use input redirection
- build pipelines
- use command substitution
- explain `$PATH`
- use exported variables correctly
- recover from overwrite mistakes
- debug broken redirection commands
- create a real incident report without manual values
