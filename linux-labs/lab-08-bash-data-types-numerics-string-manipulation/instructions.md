# Lab 08 — Bash Data Types, Numerics & String Manipulation

## Objective

Develop full control over how Bash stores, validates, calculates, and transforms data.

You must be able to:
- create and manage variables safely across scopes
- build and manipulate both indexed and associative arrays
- validate script arguments and user input before trusting them
- perform arithmetic and choose the correct comparison operator every time
- transform strings using parameter expansion alone
- produce clean, formatted, reusable script output

---

## Scenario

You've inherited a fleet of servers with no documentation. The inventory file is inconsistent, some entries are broken, and you need scripts that can read it, validate it, calculate from it, and report on it — using nothing but Bash variables, arrays, functions, arithmetic, and string manipulation.

You are no longer just running one-off commands.

You are building **reusable logic that has to survive bad input**.

---

## Constraints (MANDATORY)

- No `awk` for this lab
- No `sed` for core logic
- No `python`
- Do NOT guess syntax — predict what a command will do before running it, then verify the actual output matches
- Every variable is quoted unless you have a specific, stated reason not to
- Every numeric comparison uses the correct operator — no `=` on numbers
- No config/data change or script runs without validating its input first
- Record every mistake and fix in `evidence.md`

---

## Environment Setup

```text
bash-lab/
├── data/
│   └── servers.txt
├── scripts/
└── output/
```

`data/servers.txt`:

```text
web01,192.168.1.10,running,8080,nginx
web02,192.168.1.11,running,8080,nginx
web03,192.168.1.12,stopped,8080,nginx
db01,192.168.1.20,running,5432,postgres
db02,192.168.1.21,failed,5432,postgres
cache01,192.168.1.30,running,6379,redis
cache02,192.168.1.31,running,6379,redis
auth01,192.168.1.40,running,9000,auth-service
auth02,192.168.1.41,stopped,9000,auth-service
worker01,192.168.1.50,running,7000,job-worker
worker02,192.168.1.51,running,7000,job-worker
worker03,192.168.1.52,failed,7000,job-worker
proxy01,192.168.1.60,running,443,nginx
proxy02,192.168.1.61,running,443,nginx
monitor01,192.168.1.70,running,9090,prometheus
```

Fields: `name,ip,status,port,service`

- [ ] Verify the file exists and count its lines

---

## Task 1 — Variable Fundamentals

- [ ] Create a variable holding a server name, print it two different ways (`echo` and `printf`)
- [ ] Update that same variable three times, printing it after each change
- [ ] Create a variable whose value contains multiple spaces, then print it once unquoted and once quoted
- [ ] Try to name a variable starting with a digit and see what Bash does with it

Answer:
→ why did the quoted and unquoted prints differ
→ why did the digit-prefixed name fail

---

## Task 2 — Variable Scope: Local vs Global vs Environment

- [ ] Write a function that sets a variable's value **without** declaring it `local`. Call the function, then check whether that variable exists outside the function.
- [ ] Rewrite the same function using `local`. Call it again, then check whether the variable leaked this time.
- [ ] Create a plain shell variable and confirm whether a `bash -c` subshell can see it
- [ ] Export that variable and confirm whether the subshell can see it now

Answer:
→ what specifically changed between the leak test and the no-leak test
→ what specifically changed between the non-exported and exported subshell test


---

## Task 3 — Default Values & Safe Variable Expansion

There are four parameter-expansion forms for handling missing variables. Use each one on purpose, on a variable you know is unset:

- [ ] One that returns a fallback value **without** changing the original variable — confirm the variable is still unset afterward
- [ ] One that returns a fallback value **and assigns it** into the variable — confirm the variable is now set afterward
- [ ] One that exits the script with a custom error message when the variable is unset — trigger it and capture the exit code
- [ ] One that only returns a value when the variable **is already** set — test it both set and unset
- [ ] Apply one of these forms to a server-name field that's missing from a line in `servers.txt`, so a blank field never silently becomes an empty string downstream

Answer:
→ which of the four forms actually modifies the variable, and which don't

---

## Task 4 — Special Variables

- [ ] Write a script that prints, one per line: script name, first argument, second argument, argument count, all arguments, exit status of the previous command, this script's own process ID, and the PID of the last backgrounded process
- [ ] Run it with zero, one, and three arguments — compare what changes
- [ ] Run it with an argument that contains a space, and loop over the "all arguments" variable two different ways inside the script — find the version that preserves the space-containing argument as one item, and the version that breaks it apart
- [ ] Start a background process and immediately capture its process ID using the correct special variable
- [ ] Run a command that fails on purpose, then check the exit status; run a command that succeeds, then check the exit status again

Answer:
→ which special variable preserves argument boundaries and which one doesn't, and why that matters in a loop

---

## Task 5 — Data Types: Strings & Integers

- [ ] Concatenate two strings into a new variable
- [ ] Take an integer variable and add 1 to it using arithmetic expansion (not string concatenation)
- [ ] Take a variable holding a non-numeric string and try to run arithmetic on it — observe what Bash does

Answer:
→ what does the failed arithmetic attempt tell you about how Bash treats variable "types"

---

## Task 6 — Arrays (Indexed)

- [ ] Build an array from every server name in `servers.txt` — pure Bash, no `awk`
- [ ] Print one element by its index, and print the last element without knowing the array's length in advance
- [ ] Print the whole array as a single expansion
- [ ] Print how many elements the array has
- [ ] Loop through the array, printing each element on its own line
- [ ] Add one new element to the array without rebuilding it
- [ ] Remove one specific element from the middle of the array, then loop through it again
- [ ] Print a slice containing only a few elements from the middle of the array

Answer:
→ after removing the middle element, does the array still index cleanly from 0 upward with no gaps, or not — prove it

---

## Task 8 — Command Substitution

- [ ] Capture the output of a single command into a variable
- [ ] Capture the current date into a variable
- [ ] Capture a line count from `servers.txt` into a variable, without printing the filename
- [ ] Capture the output of a two-command pipeline into a single variable in one step (no temp file)
- [ ] Combine two separate captured variables into one readable sentence using `printf`

---

## Task 9 — User Input & Script Arguments

- [ ] Write a script that looks up a server by name, passed as an argument
  - [ ] No argument at all → usage message, distinct non-zero exit code
  - [ ] Argument given but not found → distinct "not found" message, distinct non-zero exit code
  - [ ] Argument found → print the full record, exit `0`
- [ ] Add a fallback: if no argument was given, prompt the user for one interactively instead of failing immediately
- [ ] Add a loop that keeps re-prompting if the user enters nothing, and only proceeds once real input is given

---

## Task 10 — Bash Arithmetic

- [ ] Perform addition, subtraction, multiplication, division, and modulo using variables (not hard-coded numbers)
- [ ] Divide two integers where the result isn't whole, and observe what Bash does with the remainder
- [ ] Increment a counter three different ways and confirm all three land on the same final value
- [ ] Compare incrementing a variable *before* it's used in an expression vs incrementing it *after* — show the difference in the printed result
- [ ] Loop through every server's port number and classify each as even or odd using modulo

Answer:
→ which increment style will you actually reach for in real scripts, and why

---

## Task 11 — Bash Operators

- [ ] Write one `if` check for each numeric comparison operator, run against real port numbers from `servers.txt`
- [ ] Write one `if` check for each string comparison operator, run against real status/service values — include one case where the field is genuinely empty
- [ ] Combine two conditions with a logical AND, then rewrite the same logic with logical OR and negation
- [ ] Test all six file-test operators, one at a time, against real files or directories in `bash-lab/`
- [ ] Force at least three of those six tests to fail on purpose (missing file, non-executable script, empty file) and confirm your script catches each failure cleanly instead of crashing

---

## Break/Fix Tasks (trimmed to the 6 highest-value ones)

### Break/Fix 4
```bash
for s in $servers
```
Only the first array element prints. Find the missing syntax.

### Break/Fix 5
```bash
echo $server_name
```
A name with a space breaks downstream parsing. Fix the quoting.

### Break/Fix 6
```bash
count=$(wc -l < bash-lab/data/servers.txt)
if [ $count = 15 ]
```
This comparison silently misbehaves for some values. Find the operator mistake.

### Break/Fix 8
```bash
set_status() {
  status="running"
}
set_status
echo "$status"
```
This "works" — nothing crashes — but it's a scope bug waiting to break a bigger script. Find it and fix it.

### Break/Fix 9
```bash
for arg in $@; do
  echo "$arg"
done
```
Run this with a spaced argument and watch it split incorrectly. Fix it and explain the general rule.
---

## Verification Checkpoints

You must be able to, without notes:

- [ ] Create, quote, scope (`local`/`export`), and default-value a variable correctly
- [ ] Recite and demonstrate every special variable, including the argument-preservation difference
- [ ] Build, loop, slice, grow, and shrink both indexed and associative arrays
- [ ] Capture and nest command substitution
- [ ] Validate script arguments and interactive input before using either
- [ ] Perform every arithmetic operation, including all three increment styles and pre vs post increment
- [ ] Choose the correct operator — numeric, string, logical, or file test — without guessing
- [ ] Manipulate strings using the full parameter-expansion set, including the shortest-vs-greedy prefix/suffix distinction
- [ ] Format aligned, padded output with `printf`
- [ ] Generate files with here documents and explain quoted vs unquoted interpolation
- [ ] Diagnose and fix all 10 Break/Fix scripts by reasoning, not guessing

---

## Success Criteria

You are successful when:

- You handle missing, empty, and malformed data without your scripts crashing
- You never confuse a string comparison with a numeric one
- You never let a function leak a variable it shouldn't
- You build arrays and associative arrays from raw text without reaching for `awk`
- You debug by reasoning about scope, quoting, and operator choice — not guessing
- You write every script yourself, from a blank file, with nothing copy-pasted from a solved example

---

## Coverage Map

| Checklist Item | Covered In |
|---|---|
| Variables (create/read/update/naming/quoting) | Task 1 |
| Local variables / scope basics | Task 2, Break/Fix 8 |
| Environment variables / exporting | Task 2, Task 15 |
| Default values | Task 3 |
| Special variables (incl. `$!`, `$@` vs `$*`) | Task 4, Break/Fix 9 |
| Strings / Integers | Task 5 |
| Arrays (create/read/loop/length/add/remove) | Task 6 |
| Associative arrays | Task 7 |
| Command substitution | Task 8 |
| User input / script arguments | Task 9 |
| Arithmetic expansion (incl. increment/decrement) | Task 10 |
| `let` / `expr` awareness | Task 10 |
| Numeric / string / logical operators | Task 11 |
| File tests (all six) | Task 11 |
| String manipulation (full set) | Task 12 |
| `printf` formatting | Task 13 |
| Here documents / here strings | Task 14 |
| Common environment variables | Task 15 |
| Bash debugging basics | Task 16 |