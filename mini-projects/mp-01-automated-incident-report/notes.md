# Notes

## Project Summary
This mini-project is an Automated Incident Report System built with Bash.
The goal is to scan sample log files, detect ERROR and WARNING lines, 
count them, and generate a readable incident report. This helps me 
practise turning Linux commands into a small automation tool instead 
of only running commands manually.

---

## What I Learned

### Shebang
#!/bin/bash must be the first line of every bash script so the system 
knows which interpreter to use.

### Command Substitution
$(command) stores the output of a command into a variable.
e.g. timestamp=$(date +"%Y-%m-%d_%H-%M-%S")

### Variable Assignment
No spaces around = when assigning variables.
e.g. name="value" not name = "value"

### Quoting Variables
Always use "$variable" not $variable to prevent bash breaking on 
spaces or special characters.

### if Statements
Need spaces inside brackets [ condition ] and must close with fi.

### File and Directory Checks
-f checks if a file exists, -d checks if a directory exists.

### Combining Conditions
&& combines two conditions, both must be true.

### grep Flags
-i makes search case-insensitive
-E enables extended regex like "error|warning"
-h hides the filename prefix from results

### Timestamp Format
date +"%Y-%m-%d_%H-%M-%S" formats a timestamp that is safe for filenames.
No spaces, no colons, sorts chronologically.

### Comparing Numbers
-eq compares numbers in bash conditions.
e.g. [ "$count" -eq 0 ]