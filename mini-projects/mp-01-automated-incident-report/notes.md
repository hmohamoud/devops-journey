# Notes

## Project Summary

This mini-project is an Automated Incident Report System built with Bash.

The goal is to scan sample log files, detect ERROR and WARNING lines, count them, and generate a readable incident report.

This helps me practise turning Linux commands into a small automation tool instead of only running commands manually.

---

## What I Learned

### Shebang

```bash
#!/bin/bash
```

Must be the first line of every Bash script so the system knows which interpreter to use.

---

### Command Substitution

```bash
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
```

Stores the output of a command inside a variable.

---

### Variable Assignment

```bash
name="value"      # correct
name = "value"    # incorrect — spaces break assignment
```

Bash does not allow spaces around `=` when assigning variables.

---

### Quoting Variables

```bash
"$report_filename"    # correct
$report_filename      # incorrect — can break on spaces
```

Quoting variables helps prevent Bash from breaking on spaces or special characters.

---

### If Statements

```bash
if [ -f logs/app.log ] && [ -f logs/auth.log ]; then
    # do something
fi
```

Spaces are required inside brackets.

An `if` statement must close with `fi`.

---

### File and Directory Checks

```bash
-f    # checks if a file exists
-d    # checks if a directory exists
```

I used `-f` to check that the log files existed before scanning them.

---

### Combining Conditions

```bash
[ -f logs/app.log ] && [ -f logs/auth.log ]
```

Both conditions must be true.

---

### grep Flags

```bash
-i    # case-insensitive
-E    # extended regex e.g. "error|warning"
-h    # hides filename prefix from results
```

These flags helped the script find ERROR and WARNING lines cleanly.

---

### Timestamp Format

```bash
date +"%Y-%m-%d_%H-%M-%S"
```

No spaces, no colons, sorts chronologically, and is safe for filenames.

---

### Comparing Numbers

```bash
if [ "$count_error" -eq 0 ]; then
```

`-eq` compares numbers in Bash conditions.

---

### Redirection

```bash
echo "Incident Report" >> "$report_filename"
```

`>>` appends without overwriting.

I used it to build the report line by line.

---

### Pipes

```bash
grep -ih "error" logs/app.log logs/auth.log | wc -l
```

A pipe sends the output of one command into another.

---

### Sorting Repeated Lines

```bash
sort | uniq -c | sort -nr
```

Finds and ranks repeated lines from most to least frequent.

---

### Automation

Instead of running commands manually every time, a Bash script combines them into one repeatable tool.

Scripts can use variables, conditions, and flow — unlike typing commands one at a time.
