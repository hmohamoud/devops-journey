# Shell I/O, Redirection & Command Control — Notes

---

## Core Patterns

| Symbol | Meaning |
|---|---|
| `>` | overwrite stdout into a file |
| `>>` | append stdout into a file |
| `<` | use file as command input |
| `2>` | redirect stderr/errors into a file |
| `2>>` | append stderr/errors into a file |
| `2>&1` | send stderr to the same place as stdout |
| `|` | pipe stdout into another command |
| `$(...)` | run command and inject result as text |
| `<(...)` | run command and use output like a file |

---

## `>` — Overwrite Output

### What it does

Sends normal output into a file and overwrites the file if it already exists.

### Example

`ls -l > output.txt`

### Use when

You want clean output saved into a file.

### Warning

This can wipe the old contents of a file.

---

## `>>` — Append Output

### What it does

Adds normal output to the end of a file.

### Example

`echo "ERROR Database failed" >> logs/app.log`

### Use when

You want to keep logs or history.

---

## `<` — Input Redirection

### What it does

Feeds a file into a command as input.

### Example

`wc -l < data/users.txt`

### Why use it

It gives cleaner output.

Without input redirection:

`wc -l data/users.txt`

Output:

`11 data/users.txt`

With input redirection:

`wc -l < data/users.txt`

Output:

`11`

---

## `2>` — Redirect Errors

### What it does

Sends error output into a file.

### Example

`ls fakefolder 2> errors.txt`

### Use when

You want to capture errors separately from normal output.

---

## `2>>` — Append Errors

### What it does

Adds error output to the end of an error file.

### Example

`ls fakefolder 2>> errors.txt`

### Use when

You want to keep an error history.

---

## `2>&1` — Combine Output and Errors

### What it does

Sends stderr to the same place as stdout.

### Example

`ls input fakefolder > output.txt 2>&1`

### Use when

You want one complete log containing normal output and errors.

### Important

Order matters.

Correct:

`command > file.txt 2>&1`

Meaning:

1. stdout goes to `file.txt`
2. stderr goes wherever stdout is going

---

## `|` — Pipe

### What it does

Sends stdout from one command into another command.

### Example

`grep "ERROR" logs/app.log | wc -l`

### Meaning

1. `grep` finds ERROR lines
2. `wc -l` counts them

### Use when

You want to process output step by step.

---

## `$(...)` — Command Substitution

### What it does

Runs a command and injects its output as text.

### Example

`echo "Users: $(wc -l < data/users.txt)"`

### Output

`Users: 11`

### Use when

You want dynamic values inside another command.

### Memory

`$(...)` = command output becomes text.

---

## `<(...)` — Process Substitution

### What it does

Runs a command and treats the output like a temporary file.

### Example

`diff <(sort users.txt) <(sort users.txt | uniq)`

### Meaning

Compare sorted original users against sorted unique users.

### Use when

A command expects files, but you want to compare command outputs without creating temporary files.

### Memory

`<(...)` = command output behaves like a file.

---

## `$PATH`

### What it is

A list of directories the shell checks to find commands.

### Example

`echo $PATH`

### Why it matters

When you type:

`ls`

the shell searches inside `$PATH` to find the real `ls` program.

If the command is not in `$PATH`, you may get:

`command not found`

---

## `env`

### What it does

Shows environment variables.

### Example

`env`

Useful checks:

`echo $HOME`

`echo $USER`

`echo $SHELL`

`echo $PATH`

---

## Shell Variable

### What it is

A variable that only exists in the current shell.

### Example

`name="Hamza"`

`echo $name`

A child process may not see it.

---

## Environment Variable

### What it is

A variable that has been exported and can be passed to child processes.

### Example

`export project="devops"`

### Verify

`env | grep project`

### Difference

Shell variable = current shell only.

Environment variable = current shell plus child processes.

---

## `sudo`

### What it does

Runs a command with administrator/root privileges, if the user is allowed to use sudo.

### Example

`sudo apt update`

### Use when

- installing software
- editing protected system files
- changing system settings
- changing protected permissions

### Risk

`sudo` is powerful. If misused, it can delete files, break permissions, expose sensitive files, or damage the system.

Only use it when elevated access is genuinely needed.

---

## `--help`

### What it does

Shows quick command usage.

### Example

`grep --help`

### Use when

You need a quick reminder of syntax or options.

---

## `man`

### What it does

Opens the full manual page.

### Example

`man ls`

### Use when

You need deeper explanation.

Inside `man`:

| Key | Action |
|---|---|
| `q` | quit |
| `Space` | move down a page |
| `/word` | search for a word |

---

## Real Job Patterns

Save output:

`command > file.txt`

Append logs:

`command >> file.txt`

Use file as input:

`wc -l < file.txt`

Capture errors only:

`command 2> errors.txt`

Capture everything:

`command > file.txt 2>&1`

Chain commands:

`command1 | command2`

Dynamic output:

`echo "Users: $(wc -l < file.txt)"`

Compare command outputs:

`diff <(sort a.txt) <(sort b.txt)`

---

## Decision Guide

| Need | Use |
|---|---|
| Save clean output | `>` |
| Keep adding logs | `>>` |
| Use file as input | `<` |
| Save errors only | `2>` |
| Save output and errors together | `> file 2>&1` |
| Process output step by step | `|` |
| Insert command result as text | `$(...)` |
| Treat command output like a file | `<(...)` |

---

## Debugging Guide

| Problem | Likely cause |
|---|---|
| Output missing from terminal | it was redirected to a file |
| File got wiped | used `>` instead of `>>` |
| Errors still showing | did not redirect stderr with `2>` |
| Command not found | `$PATH` issue or command not installed |
| Variable missing in child shell | variable was not exported |
| Command keeps running | stop it with `Ctrl + C` |

---

## Final Summary

| Symbol / Command | Meaning |
|---|---|
| `>` | overwrite stdout |
| `>>` | append stdout |
| `<` | use file as stdin |
| `2>` | redirect stderr |
| `2>>` | append stderr |
| `2>&1` | combine stdout and stderr |
| `|` | pipe stdout to next command |
| `$(...)` | inject command output as text |
| `<(...)` | use command output like a file |
| `$PATH` | where shell searches for commands |
| `env` | show environment variables |
| `export` | share variable with child processes |
| `sudo` | run command with elevated privileges |
| `--help` | quick help |
| `man` | full manual |

````
