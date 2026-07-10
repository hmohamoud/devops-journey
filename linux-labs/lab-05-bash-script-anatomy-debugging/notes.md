# Notes — Lab 05: Bash Script Anatomy, Conditions & Debugging

---

## Shebang

Every Bash script must start with:

```bash
#!/bin/bash
```

This tells the system which interpreter to run the script with.
Without it, the system may not know how to execute the file.

---

## Running Scripts

Two ways to run a script:

```bash
bash script.sh       # does not need execute permission
./script.sh          # needs execute permission
```

To add execute permission:

```bash
chmod +x script.sh
```

`bash script.sh` works because you are explicitly calling the bash interpreter.
`./script.sh` requires execute permission because the system runs it directly.

---

## Variables

```bash
name="Hamza"
```

Rules:
- No spaces around `=`
- Use double quotes for strings
- Access with `$name` or `"$name"`

---

## Quoting Variables

Always quote variables when using them:

```bash
"$variable"
```

Without quotes, Bash splits on spaces and breaks paths containing spaces.

If the variable is inside an already quoted string, it does not need separate quotes:

```bash
echo "Hello $name"
```

If the variable is used by itself, quote it directly:

```bash
echo "$report_filename"
```

---

## Command Substitution

Stores the output of a command inside a variable:

```bash
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
```

Use command substitution when you need the output of a command.
Do not use it just to run an action.

Useful:
```bash
count=$(grep -i "ERROR" app.log | wc -l)
```

Not useful:
```bash
created=$(mkdir -p output)
```

`mkdir` performs an action and produces no output.
The variable will be empty even though the directory was created.

---

## File and Directory Checks

```bash
-f    # checks if a file exists
-d    # checks if a directory exists
!     # negates the condition (means NOT)
```

Examples:

```bash
if [ -f "logs/app.log" ]; then
if [ -d "reports/" ]; then
if [ ! -f "logs/app.log" ]; then
```

---

## if / else / fi

```bash
if [ condition ]; then
    # do something
else
    # do something else
fi
```

Spaces are required inside brackets.
Every if must close with fi.

---

## Nested if Statements

```bash
if [ -f "logs/app.log" ]; then
    count=$(grep -i "WARNING" logs/app.log | wc -l)
    if [ "$count" -eq 0 ]; then
        echo "No warnings found"
    else
        echo "Warnings found: $count"
    fi
else
    echo "Missing file: logs/app.log"
fi
```

Outer if = can the job run?
Inner if = what was the result?

---

## Numeric Comparisons

```bash
-eq    # equal to
-ne    # not equal to
-gt    # greater than
-lt    # less than
-ge    # greater than or equal to
-le    # less than or equal to
```

Use `-eq` for numbers, not `=`.
`=` is for comparing strings.

---

## Script Arguments

```bash
$1     # first argument
$2     # second argument
$@     # all arguments
$#     # number of arguments provided
```

Example:
```bash
./script.sh bash-lab/input/app.log ERROR
```

`$1` = bash-lab/input/app.log
`$2` = ERROR

Instead of hardcoding values inside the script, arguments make scripts reusable.

---

## Exit Codes

```bash
exit 0    # success
exit 1    # failure
exit 2    # wrong usage, missing arguments
```

echo is for the human — it prints a message to the terminal.
exit is for the system — it sends a success or failure code to Bash, CI/CD, or automation tools.

Example:
```bash
echo "Missing file: bash-lab/input/app.log"
exit 1
```

Check the last exit code:
```bash
echo $?
```

---

## Debugging with echo

Print variable values to the terminal to inspect what Bash has stored:

```bash
echo "DEBUG report_directory=$report_directory"
echo "DEBUG timestamp=$timestamp"
echo "DEBUG report_filename=$report_filename"
```

DEBUG does not create files or folders.
DEBUG only helps you see what Bash is working with.
If the value is wrong, the problem is with that variable, the path, or how the value was built.

---

## Debugging with bash -x

```bash
bash -x script.sh
```

Shows every line Bash executes, with variable values expanded.
Useful for finding exactly which line is failing.

Inside the script:
```bash
set -x    # turn tracing on
set +x    # turn tracing off
```

Run normally when using set -x inside the script:
```bash
./script.sh
```

Difference:
- `echo DEBUG` = you choose which variables to inspect
- `bash -x` = Bash shows the entire script running line by line

---

## Working Directory vs Script Location

The working directory is where you run the command from, not where the script lives.

Relative paths depend on the working directory, not the script location.

If you run a script from the wrong directory, relative paths inside the script will fail.

Always run scripts from the correct location or use absolute paths.

---

## Clear Error Messages

Vague:
```bash
echo "file missing"
```

Specific:
```bash
echo "Missing file: bash-lab/input/app.log"
```

Specific error messages tell the engineer exactly what failed.
Vague messages waste time during debugging.

---

## sudo

Runs a command with administrator privileges:

```bash
sudo command
```

Key commands:
- `sudo` — runs a single command with elevated permissions
- `sudo su` — switches to root entirely, use with caution
- `whoami` — checks which user you are running as

Use when:
- installing software
- editing protected system files
- changing system settings
- changing protected permissions

Risk: sudo is powerful. Misuse can delete files, break permissions, or damage the system.
Only use it when elevated access is genuinely needed.
