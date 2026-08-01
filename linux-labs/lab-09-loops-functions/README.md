# Lab 09 — Loops, Functions & Conditionals

**Environment:** macOS Sequoia | Zsh | VS Code Terminal | Apple Silicon (M-series)

---

## Problem

Reading a file line by line, writing a function that validates input and exits correctly, and branching on a real condition are not separate skills — they're the same three moves used constantly, in almost every operational script.

Needed to build that muscle memory directly: loops that don't just iterate but filter and count, functions that scope their variables correctly and hand back the right kind of result (status vs data), and conditionals that branch on real multi-value data — then combine all three into one working tool.

---

## What I Built

```text
bash-lab/
├── data/
│   └── fleet.txt
├── scripts/
│   ├── fleet-functions.sh
│   ├── fleet-conditions.sh
│   ├── fleet-filter.sh
│   └── fleet-report.sh
└── output/
```

`data/fleet.txt` — 15 servers, fields: `name,ip,status,port,service,cpu_load,uptime_days`.

Used this environment to drill every core loop pattern, build a set of reusable functions with correct scoping, branch on real server data with `if`/`elif`/`case`, control loop flow with `break`/`continue` (including nested-loop `break N`), and combine all four blocks into a single capstone tool — `fleet-report.sh`.

---

## How I Solved It

**Loops (Block 1):**

- `while IFS=, read -r name ip status port service cpu uptime; do ... done < fleet.txt` is the loop written constantly — one line consumed per iteration
- Printing "all names, then all statuses" (rather than interleaved) requires building two arrays in a single pass and looping over each separately afterward — a straight-through read loop only ever has one line's data at a time
- Filtering (`status == "running"`) and reformatting (`name: cpu%`) both happen inside the same read loop, no second pass needed
- `for f in bash-lab/data/*.txt` loops over files by glob — confirmed the difference between a literal path (one item) and an actual glob (expanded by Bash before the loop runs)
- Arrays built inside a `while read` loop (`servers+=("$name")`) then looped separately with `"${servers[@]}"`
- Running vs not-running counted with two counters incremented directly inside the same read loop

**Functions (Block 2):**

- `is_running()` — returns `0`/`1` via `[ "$1" == "running" ]`, called plain (no brackets) as `if is_running "$status"; then ... fi`
- `cpu_tier()` — `local`-scoped result variable, cascading threshold checks, `echo`s the tier back, captured with `tier=$(cpu_tier "$cpu")`
- `validate_args()` — compares `$#` against a required count, prints usage and `return 2` on mismatch
- `log_line()` — prefixes any message with `$(date +%H:%M:%S)`
- Proved `local` doesn't leak: called `cpu_tier()`, then `echo "$result"` outside printed nothing
- Rebuilt the same function without `local` and confirmed the variable **did** leak — in a 200-line script, an unscoped variable can silently corrupt state used somewhere else entirely

**Conditionals (Block 3):**

- `if [ "$status" == "running" ]; then ... else ... fi` → UP/DOWN
- Added `elif` for a third status (`failed`) → three distinct branches instead of two
- `case "$service" in nginx|proxy*) ... ; postgres|redis) ... ; *) ... ; esac` bucketed all 15 lines into web/data/other, including `proxy01`/`proxy02` matching via the wildcard pattern
- `[[ $ip =~ ^192\.168\.1\.(1|2)[0-9]$ ]]` flagged the `.10`–`.29` IP range — the one regex pattern worth knowing cold
- Combined two conditions with `&&` in a single `if` to find servers that are both `running` AND `cpu_load` over `50`

**break/continue (Block 4):**

- `continue` skipped `stopped`/`failed` servers immediately, printing only the running ones
- `break` stopped the loop the instant `cpu_load` exceeded `90`, with an alert — confirmed it stops exactly at `cache02`
- Nested loop (outer over service names, inner over disk/memory/cpu) confirmed a plain `break` only ever exits the loop it's directly inside — the outer loop kept running through all 3 services regardless

**Capstone — `fleet-report.sh`:**

- `validate_args "$#" 0` gates entry before any work happens
- Main `while IFS=, read -r ...` loop through `fleet.txt`
- `continue` past `stopped`/`failed`
- `cpu_tier()` and a service `case` called per running server
- One line printed per server: `name | service_tier | cpu_tier`
- `break` plus a clear alert the moment a `critical` tier is hit — nothing after it gets processed
- Running total printed at the end
- Exit `0` on a clean completion, exit `1` if it broke early

---

## Proof

### Loops — interleaved vs two-pass output, filtering, and counters

![loops](screenshots/loops.png)

### Functions — scoping proof (local vs no local)

![functions scoping](screenshots/functions-scoping.png)

### Conditionals — if/elif/case and combined regex + AND logic

![conditionals](screenshots/conditionals.png)

### break/continue — filtering, early stop at cache02, nested-loop behavior

![break-continue](screenshots/break-continue.png)

### Capstone — fleet-report.sh breaking at cache02, exit code 1

![fleet report break](screenshots/fleet-report-break.png)

### Capstone — fleet-report.sh full run with cache02 removed, exit code 0

![fleet report clean](screenshots/fleet-report-clean.png)

---

## Break/Fix Summary

| Issue | Cause | Fix |
|---|---|---|
| `for ((i=0; i<=5; i++))` printed 6 numbers instead of 5 | `<=5` starting from `0` produces 6 values, not 5 | `for ((i=0; i<5; i++))` |
| `until [ "$i" -eq 0 ]; do echo "$i"; done` never stopped | loop body never modified `$i` | add `i=$((i - 1))` inside the loop |
| `case` fell through from `running` into `stopped` | missing `;;` after the `running` branch | add `;;` to every branch |
| `tier` leaked out of `set_tier()` | no `local` inside the function | `local tier="web"` |
| `break` only stopped the inner loop, not the outer | plain `break` is scoped to the loop it's directly inside | `break 2` to exit two levels |
| `[ "$name" == proxy* ]` matched unreliably | `[ ]` treats `proxy*` as a filesystem glob, not a pattern | use `[[ "$name" == proxy* ]]` |
| `return "ok"` threw a numeric-argument error | `return` only accepts exit codes 0–255, not text | `echo "ok"` and capture with `result=$(...)` instead |

---

## Key Scripts

```bash
# The loop you will write constantly
while IFS=, read -r name ip status port service cpu uptime; do
    echo "$name: $status"
done < bash-lab/data/fleet.txt

# Scoped function returning data, not status
cpu_tier() {
    local result
    if [ "$1" -lt 40 ]; then result="low"
    elif [ "$1" -lt 70 ]; then result="medium"
    elif [ "$1" -lt 90 ]; then result="high"
    else result="critical"
    fi
    echo "$result"
}
tier=$(cpu_tier "$cpu")

# Regex flag for a specific IP range
if [[ $ip =~ ^192\.168\.1\.(1|2)[0-9]$ ]]; then
    echo "$name ($ip) is in the .10-.29 range"
fi

# break out of two nested loop levels at once
for outer in a b c; do
    for inner in 1 2 3; do
        if [ "$inner" -eq 2 ]; then break 2; fi
        echo "$outer-$inner"
    done
done

# Capstone exit logic
broke_early=0
while IFS=, read -r name ip status port service cpu uptime; do
    [ "$status" == "stopped" ] || [ "$status" == "failed" ] && continue
    tier=$(cpu_tier "$cpu")
    if [ "$tier" == "critical" ]; then
        echo "ALERT: $name hit critical load"
        broke_early=1
        break
    fi
    echo "$name | $service | $tier"
done < bash-lab/data/fleet.txt

[ "$broke_early" -eq 1 ] && exit 1 || exit 0
```

---

## Improvements After Completion

- Learned that `<=N` starting from `0` always produces `N+1` values — checked the actual count instead of assuming the boundary was right
- Learned every loop condition needs something inside the body that actually moves it toward becoming true, checked specifically for `until`
- Learned `;;` is mandatory punctuation on every `case` branch, not optional for one-liners
- Learned `local` is not a style choice — without it, a function's variable is the exact same variable as the one outside it
- Learned plain `break` is always scoped to the loop directly containing it — `break N` is required to escape nested levels
- Learned `[ ]` and `[[ ]]` are not interchangeable the moment pattern matching is involved — `[ ]` runs `proxy*` past the filesystem, `[[ ]]` treats it as a real pattern
- Learned `return` can only hand back a number (0–255); `echo` + `$()` is the only way to hand back real data

---

## Key Takeaway

Before this lab, loops, functions, and conditionals were three separate topics.

After this lab, they're one skill: read a line, decide something about it, act on that decision, and know exactly how to stop — cleanly, at the right level, with the right exit code.

The three questions that mattered on every block:

1. Does this loop's condition actually change on every iteration, or will it run forever?
2. Does this function need to hand back a status (`return`) or real data (`echo`) — never both through the same channel?
3. Is this variable scoped correctly, or is it quietly leaking into the rest of the script?

That is the difference between a script that filters data and a script that reports on it reliably.

---

## Next Step

[Lab 10 — Error Handling & Production Debugging](../lab-10-error-handling-production-debugging /)