# Lab 08 — Bash Data Types, Numerics & String Manipulation

**Environment:** macOS Sequoia | Zsh | VS Code Terminal | Apple Silicon (M-series)

---

## Problem

> "The inventory file has no documentation, some entries are broken, and every answer has to survive bad input — not just work once against clean data."

No `awk`, no `sed` for core logic, no `python`. Every variable quoted unless there's a stated reason not to. Every numeric comparison uses the correct operator. Nothing runs against untrusted input without validating it first.

Needed to build reusable Bash logic that could:

- create and manage variables safely across function/global/environment scope
- build and manipulate indexed arrays without external tools
- validate arguments and interactive input before trusting either
- perform arithmetic and pick the correct comparison operator every time
- transform strings using parameter expansion alone
- survive missing, empty, and malformed data without crashing

---

## What I Built

```text
bash-lab/
├── data/
│   └── servers.txt
├── scripts/
│   └── fleet-check.sh
├── output/
├── notes.md
├── evidence.md
└── README.md
```

`data/servers.txt` — 15 servers, fields: `name,ip,status,port,service`.

Used this environment to work through variable scope, default-value expansion, special variables, arrays, arithmetic, and every comparison operator category — then proved mastery with a closed-book predict-then-run exercise and a from-scratch script (`fleet-check.sh`).

---

## How I Solved It

**Variables & quoting (Task 1):** Printed the same variable with `echo` and `printf`, updated it three times in place, and compared unquoted vs quoted output on a value containing multiple spaces — unquoted expansion runs through word-splitting and collapses redundant whitespace, quoted expansion preserves it exactly. Confirmed a variable name can't start with a digit.

**Scope — local vs global vs environment (Task 2):** Wrote the same function twice, once without `local` and once with it, and checked the outer variable's value after each call. Without `local`, the function's assignment persists outside it. With `local`, the assignment is destroyed the moment the function returns. Then confirmed a plain shell variable is invisible to a `bash -c` subshell, and became visible only after `export`.

**Default values (Task 3):** Exercised all four parameter-expansion fallback forms — `:-` (fallback only), `:=` (fallback + assign), `:?` (fallback + exit with error), `:+` (only if already set) — against a variable known to be unset, confirming exactly which ones mutate the variable and which don't.

**Special variables (Task 4):** Printed `$0`, `$1`, `$2`, `$#`, `$@`, `$?`, `$$`, and `$!` from inside a script, then ran it with 0/1/3 arguments and with a space-containing argument, looping over it with `"$@"` and unquoted `$@` to isolate which one preserves argument boundaries.

**Data types (Task 5):** Concatenated two strings by placing expansions adjacent inside one quoted string, incremented an integer with `$(( ))`, then ran arithmetic on a non-numeric variable and observed Bash silently treat it as `0` rather than erroring.

**Arrays (Task 6):** Built an indexed array of every server name from `servers.txt` using a pure-Bash `while IFS=, read` loop (no `awk`), then exercised indexing, negative indexing for the last element, full-array printing, length counting, looping, appending, removing a middle element with `unset`, and slicing.

**Command substitution (Task 8):** Captured single-command output, a two-stage piped command, and a line count (using input redirection so the filename never printed) — all into variables — then combined two captured values into one sentence with `printf`.

**User input & arguments (Task 9):** Wrote a server lookup that distinguishes three outcomes with distinct exit codes: no argument, argument not found, argument found — then layered on an interactive fallback prompt that re-asks until real input is given.

**Arithmetic (Task 10):** Ran every arithmetic operator against variables (not hard-coded numbers), confirmed integer division truncates rather than rounds, verified all three increment styles land on the same final value, and demonstrated the printed difference between pre- and post-increment.

**Operators (Task 11):** Wrote one `if` check per numeric comparison operator against real port numbers, one per string comparison operator against real status/service values (including a genuinely empty field), combined conditions with AND/OR/NOT, and tested all six file-test operators — deliberately forcing three of them to fail (missing file, non-executable script, empty file) to confirm the script caught each failure cleanly.

**Break/Fix set:** Diagnosed and fixed six seeded bugs — the unquoted-array loop trap, the space-breaking unquoted variable, the `=` vs `-eq` numeric-comparison mismatch, the scope leak from a missing `local`, and the unquoted-`$@` argument-splitting bug.

**Mastery check (Part A / Part B):** Closed-book — ten predict-then-run questions covering every concept above, plus building `fleet-check.sh` from a blank file: full argument validation, an array built without `awk`, a not-found/found branch with correct exit codes, a proven non-leaking `local` variable, and a default-value expansion used in the validation path itself. Full write-up in `evidence.md`.

---

## Break/Fix Summary

| Issue | Cause | Fix |
|---|---|---|
| Array loop only printed one element | looped over `$servers` instead of `"${servers[@]}"` | use `"${servers[@]}"` |
| Spaced value broke downstream parsing | printed with `echo $var` instead of `echo "$var"` | quote the expansion |
| `[ "$count" = 15 ]` "worked" but was still wrong | `=` is a string comparison being used on a number | use `-eq` for numeric comparisons |
| `set_status` silently overwrote the outer `status` | no `local` declared inside the function | add `local status="running"` |
| `for arg in $@` split a spaced argument apart | unquoted `$@` re-splits on whitespace | always loop with `"$@"` |
| `[ 15 -eq 015 ]` unexpectedly failed | leading zero read as octal by `-eq` | strip leading zeros or use `10#` forced-decimal parsing |

---

## Key Snippets

```bash
# safe array build, no awk
servers=()
while IFS=, read -r name ip status port service; do
    servers+=("$name")
done < bash-lab/data/servers.txt

# safe argument loop
for arg in "$@"; do echo "$arg"; done

# default value that also assigns
: "${count:=0}"

# scoped function variable
my_func() { local temp="value"; }

# correct numeric comparison
[ "$port" -gt 8000 ]

# correct string comparison
[ -z "$field" ] || [ "$field" = "expected" ]
```

---

## Improvements After Completion

- Learned that Bash never errors on a type mismatch — a non-numeric variable in arithmetic silently becomes `0`, which is far more dangerous than a crash because it fails quietly.
- Learned that `local` isn't just a style choice — leaving it off is a scope bug that can sit undetected until a bigger script relies on a variable's value being untouched.
- Learned that `${var:-default}` and `${var:=default}` look nearly identical but behave completely differently — one is read-only, one is permanent.
- Learned that `"$@"` vs `$@` is the single most consequential quoting decision in any script that loops over arguments.
- Learned that a leading zero on a numeric literal is a real, reproducible trap in `-eq` comparisons — not a theoretical edge case.
- Learned that every one of these behaviors had to be predicted correctly, closed-book, before it counted as actually understood — running the command and seeing the "right" answer isn't the same as knowing why it's right.

---

## Key Takeaway

Before this lab, I could write a script that worked against clean input.

After this lab, I could explain — before running anything — exactly why a script would behave a certain way against messy, missing, or malformed input, and prove it with a script built from a blank file with no notes open.

The three questions that mattered on every single task:

1. Is this variable quoted, and does it need to be?
2. Is this the correct comparison operator for the data type I actually have?
3. Does this variable's scope match what the rest of the script expects?

That is the difference between a script that happens to work and a script that survives contact with real data.

---

## Next Step

[Lab 09 — Loops, Functions & Conditionals](../lab-09-loops-functions-conditionals/)