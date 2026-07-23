# Bash Data Types, Numerics & String Manipulation — Notes

---

## Core Concepts

| Concept | Purpose |
|---|---|
| Variables | store a single value; scope depends on `local` / export |
| Parameter expansion | fallback, default, error, and conditional handling of unset/empty variables |
| Special variables | `$0`, `$1..$9`, `$#`, `$@`, `$*`, `$?`, `$$`, `$!` — script and process metadata |
| Arrays | indexed collections built and manipulated without `awk` |
| Arithmetic expansion | `$(( ))` — integer math, never string concatenation |
| Comparison operators | numeric (`-eq`, `-gt`, ...), string (`=`, `<`, `>`, `-z`, `-n`), file tests |
| String manipulation | length, substring, case conversion via parameter expansion only |

---

## Variables — Create, Print, Quote

### Two ways to print

```bash
name="web01"
echo "$name"
printf "%s\n" "$name"
```

### Quoted vs unquoted

```bash
label="fleet   report"
echo $label     # word-splitting collapses the extra spaces
echo "$label"   # exact value preserved, spaces and all
```

Quoting only visibly matters when a variable contains **redundant whitespace** (multiple spaces, leading/trailing spaces). Default to quoting always — it costs nothing when there's nothing to collapse, and prevents silent breakage when there is.

### Naming

Variable names cannot start with a digit:

```bash
1name="x"   # syntax error
name1="x"   # fine
```

---

## Variable Scope: Local vs Global vs Environment

| Without `local` | With `local` |
|---|---|
| Function modifies the same variable that exists outside it | Function creates a separate variable, invisible outside it |
| Change persists after the function returns | Variable is destroyed the moment the function ends |

```bash
status="stopped"
set_status() {
    status="running"   # no local → overwrites the outer variable
}
set_status
echo "$status"   # running
```

```bash
status="stopped"
set_status() {
    local status="running"   # local → outer variable untouched
}
set_status
echo "$status"   # stopped
```

### Plain shell variable vs environment variable

A plain (non-exported) shell variable only exists in the current shell — a subshell (`bash -c '...'`) cannot see it, because it isn't part of the process environment. `export` makes it an environment variable, which **is** passed down to child processes.

```bash
name="Hamza"
bash -c 'echo $name'      # empty — not visible

export name
bash -c 'echo $name'      # Hamza — now visible
```

### Calling a function

Defining a function does nothing on its own — it has to be called by name:

```bash
my_function() {
    # commands
}
my_function   # required to actually run it
```

---

## Default Values & Safe Expansion

| Form | Behavior |
|---|---|
| `${var:-fallback}` | returns fallback if unset/empty; **does not** modify `var` |
| `${var:=fallback}` | returns fallback if unset/empty; **assigns** it into `var` |
| `${var:?error message}` | prints the error and exits the script if unset/empty |
| `${var:+value}` | returns `value` only if `var` **is already** set (opposite logic of the others) |

```bash
echo "${count:-0}"    # 0 (count still unset afterward)
echo "${count:=0}"    # 0 (count is now permanently 0)
: "${name:?name is required}"   # exits with an error if $name is unset
echo "${debug:+--verbose}"      # only prints --verbose if $debug is set to something
```

Use `${field:-}` on any value pulled from external/inconsistent data (like a CSV field that might be blank) so a missing field never silently becomes an unhandled empty string downstream.

---

## Special Variables

| Variable | Meaning |
|---|---|
| `$0` | the script's own name |
| `$1`, `$2`, ... | positional arguments |
| `$#` | number of arguments passed |
| `$@` | all arguments, each preserved as a separate word (when quoted) |
| `$*` | all arguments joined into a single string |
| `$?` | exit status of the last command |
| `$$` | this script's own process ID |
| `$!` | the PID of the last backgrounded process |

### `"$@"` vs `$@` — the one that actually matters

```bash
set -- "web fleet" "db01"

for arg in "$@"; do echo "$arg"; done
# web fleet
# db01

for arg in $@; do echo "$arg"; done
# web
# fleet
# db01
```

**`"$@"` (quoted)** — each argument stays whole, even with internal spaces.
**`$@` (unquoted)** — Bash re-splits everything on whitespace, silently breaking any argument that contains a space.

Rule: always loop with `"$@"`. Unquoted `$@` (or `$*`) is the version that breaks the moment someone passes a multi-word argument.

---

## Data Types: Strings & Integers

Bash doesn't have real "types" — everything is stored as a string. Arithmetic context (`$(( ))`) is what decides whether a value is treated numerically.

```bash
a="fleet"
b="report"
c="$a$b"      # concatenation = adjacent expansions, no + operator
c="$a $b"     # literal space inserted between them

x=5
x=$((x + 1))  # correct: arithmetic expansion
x="$x"+1      # wrong: this is string concatenation, not math
```

**Non-numeric variables inside `$(( ))` don't error — they're silently treated as `0`.** This is a common source of quietly-wrong results, not crashes.

---

## Arrays (Indexed)

```bash
servers=()
while IFS=, read -r name ip status port service; do
    servers+=("$name")
done < data/servers.txt
```

**Array append is `+=()` — this one is pure muscle memory:**

```bash
servers+=("newserver01")
```

### Curly braces around an array expansion

```bash
echo "${servers[@]}"
echo "${servers[0]}"
```

The curly braces `{ }` are what mark the start and end of the expansion so Bash knows exactly which characters belong to the array reference and which don't — `$servers[@]` (no braces) does **not** work the way you'd expect, because Bash would expand `$servers` on its own first and then treat `[@]` as literal text tacked onto the result. The braces are what let `[@]` (or `[0]`, `[-1]`, `[@]:2:3`, etc.) bind to the array name correctly. Whatever changes between element access, index access, length, or slicing all happens *inside* those braces — the braces themselves are just the container that makes the array-specific syntax legal.

| Operation | Syntax |
|---|---|
| Access one element | `${servers[0]}` |
| Access the last element | `${servers[-1]}` (no need to know the length) |
| Print the whole array | `${servers[@]}` |
| Count elements | `${#servers[@]}` |
| Loop through | `for s in "${servers[@]}"; do ...; done` |
| Append | `servers+=("newserver")` |
| Remove by index | `unset 'servers[2]'` |
| Slice | `${servers[@]:start:length}` — e.g. `${servers[@]:2:3}` starts at index 2, takes 3 elements |

**Slicing, visually:**

```text
${servers[@]:2:3}
          |  |
          |  └── take 3 elements
          └──── start at index 2
```

**After `unset`, the array keeps its original indices** — removing the middle element leaves a gap rather than reflowing everything down to a clean `0..n-1` sequence. `"${servers[@]}"` still loops correctly over what remains, but don't assume the index numbers are contiguous afterward.

**The classic loop bug:**

```bash
for s in $servers; do echo "$s"; done
```

This does **not** loop the array — `$servers` (unquoted, no `[@]`) expands only to index `0`. The fix is always `"${servers[@]}"`.

---

## Command Substitution

```bash
today="$(date)"
count="$(wc -l < data/servers.txt)"          # no filename printed, thanks to input redirection
combined="$(grep -i error app.log | wc -l)"  # captures a full pipeline in one step
printf "Servers: %s, checked on %s\n" "$count" "$today"
```

`$(...)` runs a command and drops its output into the variable as plain text — this works for single commands and entire piped chains equally well.

---

## Arithmetic

```bash
sum=$((a + b))
diff=$((a - b))
prod=$((a * b))
quot=$((a / b))     # integer division — the remainder is dropped, no rounding
rem=$((a % b))
```

Never quote variables inside `$(( ))` — it's a numeric context, not a string context, and quoting adds nothing.

### Increment styles

```bash
((counter++))
((counter+=1))
counter=$((counter + 1))
```

All three land on the same final value. The difference that actually shows up in output:

```bash
counter=5
echo $((counter++))   # prints 5, THEN increments (post-increment: use it, then bump it)
echo $((++counter))   # increments FIRST, then prints (pre-increment: bump it, then use it)
```

---

## Comparison Operators

### Numeric

| Operator | Meaning |
|---|---|
| `-eq` | equal |
| `-ne` | not equal |
| `-gt` | greater than |
| `-lt` | less than |
| `-ge` | greater or equal |
| `-le` | less or equal |

### String

| Operator | Meaning |
|---|---|
| `=` | strings are equal |
| `!=` | strings are not equal |
| `\<` | comes before, alphabetically (`[ "$a" \< "$b" ]`) |
| `\>` | comes after, alphabetically |
| `-z` | string is empty (length zero) |
| `-n` | string is not empty |

**Mnemonic:** think of `<` and `>` like a mouth opening toward the bigger/later thing.

- `[ "$a" \< "$b" ]` → the mouth opens toward `$b`, meaning `$b` comes after `$a` alphabetically.
- `[ "$a" \> "$b" ]` → the mouth opens toward `$a`, meaning `$a` comes after `$b` alphabetically.

**Never use `=` on numbers.** `"15" = "15"` matches as strings even though `=` is the wrong tool — which is exactly what makes it dangerous: it can silently give the right answer on some inputs and the wrong one on others (e.g. leading zeros).

### Leading-zero trap

```bash
[ 15 -eq 015 ]   # false — 015 is read as octal (13), not fifteen
```

Never hardcode zero-padded numeric literals into a numeric comparison without accounting for octal interpretation.

### File tests

| Flag | Checks |
|---|---|
| `-f` | is a regular file |
| `-d` | is a directory |
| `-e` | exists (file or directory, doesn't care which) |
| `-w` | writable — can create/modify/delete inside (for a directory) |
| `-x` | executable (file) / traversable with `cd` (directory) |
| `-r` | readable — can view (file) / can `ls` (directory) |

### Logical combinators

```bash
if [ "$status" == "running" ] && [ "$port" -gt 8000 ]; then ...; fi
if [ "$status" == "running" ] || [ "$status" == "stopped" ]; then ...; fi
if ! [ -f "$file" ]; then ...; fi
```

---

## String Manipulation (Parameter Expansion)

| Expansion | Meaning |
|---|---|
| `${#variable}` | length of the variable |
| `${variable:start}` | extract from a position to the end |
| `${variable:start:length}` | extract a fixed-length substring |
| `${variable^^}` | uppercase the entire value |
| `${variable,,}` | lowercase the entire value |
| `${variable#pattern}` | remove shortest match from the front |
| `${variable##pattern}` | remove longest match from the front |
| `${variable%pattern}` | remove shortest match from the end |
| `${variable%%pattern}` | remove longest match from the end |

All of this is pure Bash — no `sed`, `awk`, or external tools required.

---

## Decision Guide

| Need | Use |
|---|---|
| Fallback value without changing the variable | `${var:-default}` |
| Fallback value that also gets saved | `${var:=default}` |
| Hard-stop if a required variable is missing | `${var:?message}` |
| Only use a value if the variable is already set | `${var:+value}` |
| Loop over every argument safely | `for a in "$@"` |
| Loop over every array element safely | `for e in "${arr[@]}"` |
| Compare two numbers | `-eq` / `-ne` / `-gt` / `-lt` / `-ge` / `-le` |
| Compare two strings | `=` / `!=` / `-z` / `-n` |
| Do math | `$(( ))` |
| Capture command output | `$( )` |

---

## Debugging Guide

| Problem | Likely cause |
|---|---|
| Array loop only prints one element | used `$array` or unquoted `${array[@]}` instead of `"${array[@]}"` |
| A spaced argument gets torn apart in a loop | used `$@` instead of `"$@"` |
| Arithmetic silently returns `0` for a variable | the variable held a non-numeric string; Bash coerces it to `0` instead of erroring |
| Numeric comparison behaves unexpectedly on padded numbers | leading-zero literal is being read as octal |
| A function's variable "disappeared" | it was declared `local`, and the read happened outside the function |
| A function's variable "leaked" and broke something later | it was **not** declared `local` when it should have been |
| `${var:-default}` doesn't seem to "stick" | correct — that form never assigns; use `${var:=default}` if persistence is needed |
| Variable named `1name` fails | variable names cannot start with a digit |

---

## Final Summary

| Symbol / Form | Meaning |
|---|---|
| `local var=` | scope a variable to the current function only |
| `export var` | make a shell variable visible to child processes |
| `${var:-x}` | fallback, no assignment |
| `${var:=x}` | fallback, with assignment |
| `${var:?x}` | error and exit if unset |
| `${var:+x}` | value only if var is set |
| `"$@"` | arguments, each preserved separately |
| `$*` | arguments joined into one string |
| `${#arr[@]}` | array element count |
| `${arr[-1]}` | last array element |
| `${arr[@]:s:n}` | array slice starting at `s`, length `n` |
| `unset 'arr[i]'` | remove one array element (leaves a gap) |
| `$(( ))` | arithmetic expansion |
| `$( )` | command substitution |
| `-eq / -ne / -gt / -lt / -ge / -le` | numeric comparisons |
| `= / != / -z / -n` | string comparisons |
| `-f / -d / -e / -w / -x / -r` | file test operators |
| `${var^^} / ${var,,}` | uppercase / lowercase |
| `${#var}` | string length |