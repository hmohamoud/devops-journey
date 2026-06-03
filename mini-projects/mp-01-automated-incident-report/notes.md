cat > notes.md <<'EOF'
# Notes

## Project Summary
This mini-project is an Automated Incident Report System built with Bash.

The goal is to scan sample log files, detect ERROR and WARNING lines, count them, and generate a readable incident report.

This helps me practise turning Linux commands into a small automation tool instead of only running commands manually.

---

## What I Learned

### Shebang
`#!/bin/bash` must be the first line of every Bash script so the system knows which interpreter to use.

### Command Substitution
`$(command)` stores the output of a command inside a variable.

Example:

`timestamp=$(date +"%Y-%m-%d_%H-%M-%S")`

### Variable Assignment
No spaces around `=` when assigning variables.

Correct:

`name="value"`

Incorrect:

`name = "value"`

### Quoting Variables
Always use `"$variable"` instead of `$variable` to prevent Bash breaking on spaces or special characters.

### if Statements
Bash needs spaces inside brackets: `[ condition ]`

An `if` statement must also close with `fi`.

### File and Directory Checks
`-f` checks if a file exists.

`-d` checks if a directory exists.

### Combining Conditions
`&&` combines two conditions. Both must be true.

### grep Flags
`-i` makes search case-insensitive.

`-E` enables extended regex like `"error|warning"`.

`-h` hides the filename prefix from results.

### Timestamp Format
`date +"%Y-%m-%d_%H-%M-%S"` formats a timestamp that is safe for filenames.

It has no spaces, no colons, and sorts chronologically.

### Comparing Numbers
`-eq` compares numbers in Bash conditions.

Example:

`[ "$count" -eq 0 ]`

### Redirection
`>>` appends output to a file without overwriting it.

I used it to build the report line by line.

### Pipes
A pipe sends the output of one command into another.

Example:

`grep -ih "error" logs/app.log | wc -l`

### Sorting Repeated Lines
`sort | uniq -c | sort -nr` finds and ranks repeated lines by frequency.

### Automation
Instead of running commands manually every time, a Bash script combines them into one repeatable tool.
Scripts can use variables, conditions, and flow — unlike running commands one at a time.
