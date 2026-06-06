# Rebuild Reflection

## Why I Did This Rebuild

I did this rebuild to check if I actually understood the pattern from the Automated Incident Report System.

This was not meant to be another full mini-project. It was more like a small test to see if I could rebuild the same idea in a simpler way.

The script I tried to build was `warning_summary.sh`.

The goal was simple:

```text
read the logs
find WARNING lines
count the warnings
create a report
handle missing files
write errors if something is wrong
```

The main reason I did this was because I did not want to move on while secretly not understanding the first project.

---

## What I Was Trying To Build

I was trying to build a Bash script that:

- creates a `reports/` folder
- creates an `errors/` folder
- creates a timestamp
- checks if `logs/app.log` and `logs/auth.log` exist
- searches both logs for WARNING lines
- counts how many WARNING lines exist
- writes the result into a warning summary report
- writes an error file if a log file is missing
- prints a message when the script finishes

The rebuild helped me see what I actually remembered and what I was still shaky on.

---

## The Pattern I Was Trying To Rebuild

The pattern was:

```text
1. Set variables
2. Create output folders
3. Check if input files exist
4. Search/process the files
5. Store useful command output in variables
6. Use if statements to decide what happens
7. Redirect output into report/error files
8. Print a final message
```

This is the main structure I need to remember for future Bash scripts.

---

## What I Got Stuck On

### 1. What “Read the Log” Actually Means

This confused me more than I expected.

When I saw “read the log”, I thought it meant using:

```bash
cat logs/app.log
```

That made sense to me because `cat` lets me view the file.

But what clicked is that in a script, “read the log” can also mean using the log file as input for another command.

So this also reads the log:

```bash
grep -ih "warning" logs/app.log logs/auth.log
```

`grep` reads through the file, checks each line, and only prints the lines that match.

So the difference is:

```text
cat = show the whole file
grep = read/search the file and return only matching lines
wc = read input and count it
sort = read input and organise it
```

For this rebuild, `grep` was the better tool because I did not need to see the whole log. I only needed WARNING lines.

This was an important thing for me to understand because I kept thinking “read” literally meant `cat`.

---

### 2. Command Substitution

I got stuck on command substitution as well.

I tried to use it like this:

```bash
create_report=$(mkdir -p reports)
"$create_report"
```

At first, I thought this made sense because the command still runs.

But the part I was missing is that command substitution is not just for running commands. It is for capturing the output of a command.

This is useful:

```bash
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
```

because `date` prints something, and I want to store that timestamp.

This is useful:

```bash
count_warning=$(grep -ih "warning" logs/app.log logs/auth.log | wc -l)
```

because the command prints a number, and I want to store that number.

This is useful:

```bash
scan_warning=$(grep -ih "warning" logs/app.log logs/auth.log)
```

because `grep` prints matching warning lines, and I want to store those lines.

But this is not useful:

```bash
create_report=$(mkdir -p reports)
```

because `mkdir` creates a folder but does not print useful text that I need to store.

The correct version is just:

```bash
mkdir -p reports
mkdir -p errors
```

What clicked:

```text
Use command substitution when I need the output of a command.
Do not use command substitution just to run an action.
```

That was a big weakness in my thinking during the rebuild.

---

### 3. Checking The Same File Twice

In my first attempt, I wrote:

```bash
if [ -f logs/app.log ] && [ -f logs/app.log ]; then
```

I accidentally checked `logs/app.log` twice.

What I actually meant was:

```bash
if [ -f logs/app.log ] && [ -f logs/auth.log ]; then
```

This showed me that I need to slow down when writing conditions.

The correct idea is:

```text
check app.log exists
AND
check auth.log exists
```

Each file needs its own `-f` check.

---

### 4. Missing File Messages

I also had to think about what should happen if a file is missing.

At first, I could have just written something generic like:

```text
log files not found
```

But that is not that useful.

A better message is specific:

```text
logs/app.log is missing
logs/auth.log is missing
```

The better pattern is:

```bash
if [ ! -f logs/app.log ]; then
    echo "logs/app.log is missing" >> "$errors_filename"
fi

if [ ! -f logs/auth.log ]; then
    echo "logs/auth.log is missing" >> "$errors_filename"
fi
```

What I learned:

Good error messages should tell me exactly what went wrong.

That saves time because I do not have to investigate manually.

---

### 5. Nested If Statements

I got stuck on why the “no warnings found” check should be inside the main file check.

The reason is simple now:

The script should only count warnings after it knows the log files exist.

The outer `if` is asking:

```text
Can I do the job?
```

The inner `if` is asking:

```text
What was the result after doing the job?
```

So the structure is:

```bash
if [ -f logs/app.log ] && [ -f logs/auth.log ]; then
    count_warning=$(grep -ih "warning" logs/app.log logs/auth.log | wc -l)

    if [ "$count_warning" -eq 0 ]; then
        echo "Warnings not found"
    else
        echo "Warnings found"
    fi
else
    echo "A log file is missing"
fi
```

That helped me understand the logic better.

The outer check is about whether the script can run properly.

The inner check is about what the script found.

---

### 6. Variable Naming Mistake

I made a mistake like this:

```bash
"$count _warning"
```

There was a space inside the variable name.

The correct version is:

```bash
"$count_warning"
```

This showed me that Bash is very strict.

A small space can break the logic.

I need to be more careful when writing variable names.

---

### 7. Bracket Spacing

I also wrote something like:

```bash
if [! -f logs/auth.log ]; then
```

That is wrong.

The correct version is:

```bash
if [ ! -f logs/auth.log ]; then
```

Bash needs spaces inside the brackets.

Correct:

```bash
[ condition ]
```

Wrong:

```bash
[condition]
```

This is one of those small Bash syntax things I need to repeat until it becomes automatic.

---

### 8. Report Filename Formatting

I wrote the filename in a messy way:

```bash
report_filename=""$report_directory"/incident-report-"$timestamp".txt"
```

It might work in some cases because Bash joins strings together, but it is ugly and harder to read.

The cleaner way is:

```bash
report_filename="$report_directory/warning-summary-$timestamp.txt"
```

What I learned:

Even if something works, it still matters if it is readable.

Clean variables make the script easier to understand and debug.

---

### 9. Report Naming

I originally used an incident report style name, but this rebuild was only about warnings.

So the better name is:

```bash
warning-summary-$timestamp.txt
```

This makes more sense because the file name matches what the script actually does.

What I learned:

File names should match the purpose of the output.

---

### 10. Writing Useful Report Output

At first, my report only really said:

```text
Warnings found
```

That works, but it is not very useful.

A better report should include:

```text
title
timestamp
files scanned
warning count
matching warning lines
```

What I learned:

A report should not just say something happened.

It should give useful information to the person reading it.

---

### 11. Redirection

I had to keep remembering that if I want something inside the report, I need to redirect it.

This prints to the terminal:

```bash
echo "Warnings found"
```

This writes to the report:

```bash
echo "Warnings found" >> "$report_filename"
```

This was important because terminal output and file output are not the same thing.

If I want the report file to contain something, I need:

```bash
>> "$report_filename"
```

---

### 12. Quoting Variables

I used variables like:

```bash
"$report_filename"
"$errors_filename"
```

This is safer than writing them without quotes.

Correct:

```bash
echo "text" >> "$report_filename"
```

Less safe:

```bash
echo "text" >> $report_filename
```

What I learned:

When variables are used as file paths, I should wrap them in double quotes.

That helps prevent problems with spaces or special characters.

---

### 13. Running The Script From The Wrong Directory

This was another thing that confused me.

I ran the script like this from the repo root:

```bash
./mini-projects/mp-01-rebuild/warning_summary.sh
```

But the script checks for:

```text
logs/app.log
logs/auth.log
```

Because I ran it from the repo root, Bash looked for:

```text
devops-journey/logs/app.log
devops-journey/logs/auth.log
```

instead of:

```text
devops-journey/mini-projects/mp-01-rebuild/logs/app.log
devops-journey/mini-projects/mp-01-rebuild/logs/auth.log
```

What I learned:

Relative paths depend on where I run the script from.

For this rebuild, the simple fix is to run it from inside the project folder:

```bash
cd mini-projects/mp-01-rebuild
./warning_summary.sh
```

Before running scripts, I should check:

```bash
pwd
```

This tells me where I am.

---

### 14. Broken Quotes In Filename Variables

I also broke the filename variables with quotes.

I wrote:

```bash
report_filename="$report_directory"/incident-report-$timestamp.txt"
errors_filename="$errors_directory"/errors-report-$timestamp.txt"
```

That caused file errors.

The cleaner version is:

```bash
report_filename="$report_directory/warning-summary-$timestamp.txt"
errors_filename="$errors_directory/errors-report-$timestamp.txt"
```

What I learned:

File path variables should be built cleanly with one quoted string.

Broken quotes can create invalid paths or empty redirects.

---

## What I Did Better This Time

Compared to the first time, I was better at:

- setting directory variables
- creating a timestamp
- creating report and error filenames
- using `mkdir -p`
- checking files with `-f`
- using `grep -ih`
- counting matches with `wc -l`
- using an inner `if` for zero warnings
- writing missing-file errors
- understanding that `grep` can read a log as input

I still made mistakes, but I recognised the structure faster than before.

That shows I am improving.

---

## Final Rebuild Pattern To Remember

This is the pattern I need to understand, not copy blindly:

```bash
#!/bin/bash

report_directory="reports"
errors_directory="errors"
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")

report_filename="$report_directory/warning-summary-$timestamp.txt"
errors_filename="$errors_directory/errors-report-$timestamp.txt"

mkdir -p "$report_directory"
mkdir -p "$errors_directory"

if [ -f logs/app.log ] && [ -f logs/auth.log ]; then
    scan_warning=$(grep -ih "warning" logs/app.log logs/auth.log)
    count_warning=$(grep -ih "warning" logs/app.log logs/auth.log | wc -l)

    if [ "$count_warning" -eq 0 ]; then
        echo "Warnings not found" >> "$report_filename"
    else
        echo "Warnings found:" >> "$report_filename"
        echo "$scan_warning" >> "$report_filename"
    fi
else
    if [ ! -f logs/app.log ]; then
        echo "logs/app.log is missing" >> "$errors_filename"
    fi

    if [ ! -f logs/auth.log ]; then
        echo "logs/auth.log is missing" >> "$errors_filename"
    fi
fi

echo "Script processed and complete"
```

---

## Main Lessons From The Rebuild

### Lesson 1

“Read the log” means use the log file as input.

It does not always mean `cat`.

For filtering, `grep` is better because it reads the file and only returns matching lines.

---

### Lesson 2

Command substitution is for capturing command output.

It is useful with commands like:

```text
date
grep
wc -l
```

It is not useful for action-only commands like:

```bash
mkdir -p
```

---

### Lesson 3

The outer `if` checks if the script can do the job.

The inner `if` checks the result of the job.

---

### Lesson 4

Good error messages should say exactly what failed.

Instead of:

```text
log files missing
```

use:

```text
logs/app.log is missing
```

---

### Lesson 5

A working script is good, but a readable script is better.

Clean filenames, clear variables, and useful report headings make the script easier to understand.

---

## Current Weaknesses From The Rebuild

My current weaknesses are:

- Bash syntax is still not automatic
- I sometimes misuse command substitution
- I sometimes confuse human-reading a file with script-processing a file
- I need to slow down when writing file checks
- I need more practice with nested `if` logic
- I still make small spacing mistakes
- I need to improve report formatting without needing help
- I need to pay attention to where I run scripts from
- I need to build file paths more cleanly

These are the exact weaknesses I need to attack in the next lab block.

---

## Did I Pass The Rebuild?

Yes.

I did not write it perfectly, but I rebuilt the main logic myself.

I was able to:

- create the script structure
- check input files
- scan logs for warnings
- count results
- write a report
- handle missing files
- ask better questions when confused
- understand the fixes after review

That means I understood the core pattern enough to move on.

The rebuild proved that I am not fully fluent yet, but I am improving.

