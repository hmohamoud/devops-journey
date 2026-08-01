# Evidence — Lab 09

## Completed Tasks

### Environment Setup
- Created structured lab environment:
  - `bash-lab/`
    - `data/`
    - `scripts/`
    - `output/`

- Populated:
  - `data/fleet.txt` — 15 servers, fields `name,ip,status,port,service,cpu_load,uptime_days`

- Verified with:
  - `wc -l bash-lab/data/fleet.txt`

---

### Block 1 — Loops

- Printed every server name and status, interleaved:
  - `while IFS=, read -r name ip status port service cpu uptime; do echo "$name"; echo "$status"; done < bash-lab/data/fleet.txt`

- Printed all names first, then all statuses, using two arrays built in one pass:
  ```bash
  names=()
  statuses=()
  while IFS=, read -r name ip status port service cpu uptime; do
      names+=("$name")
      statuses+=("$status")
  done < bash-lab/data/fleet.txt
  for n in "${names[@]}"; do echo "$n"; done
  for s in "${statuses[@]}"; do echo "$s"; done
  ```

- Filtered to only `running` servers inside the same read loop.

- Printed `name: cpu%` format for every server.

- Looped over files by glob:
  - `for f in bash-lab/data/*.txt; do echo "$f"; done`
  - Confirmed the difference between a literal path (`for f in bash-lab/data`, one item) and an actual glob (`for f in bash-lab/data/*.txt`, expanded by Bash before the loop runs) by adding and removing test files.

- Built an array from server names, looped with `"${server[@]}"`.

- Counted running vs not-running with two counters incremented directly inside a single read loop:
  ```bash
  running=0
  not_running=0
  while IFS=, read -r name ip status port service cpu uptime; do
      if [ "$status" == "running" ]; then
          running=$((running + 1))
      else
          not_running=$((not_running + 1))
      fi
  done < bash-lab/data/fleet.txt
  ```

---

### Block 2 — Functions

- `is_running()` — returns `0`/`1` via `[ "$1" == "running" ]`, called plain with `if is_running "$status"; then ... fi`.

- `cpu_tier()` — `local result`, cascading `elif [ "$1" -lt X ]` thresholds, `echo`s the result, captured with `tier=$(cpu_tier "$cpu")`.

- `validate_args()` — compares `$#` against a required count, `echo`s a usage message and `return 2` on mismatch. Called as:
  ```bash
  if ! validate_args "$#" 0; then
      exit 2
  fi
  ```

- `log_line()`:
  ```bash
  log_line() {
      echo "$(date +%H:%M:%S) $1"
  }
  ```

- Proved `cpu_tier()`'s `local result` doesn't leak — called it, then `echo "$result"` outside printed nothing.

- Rebuilt the same function without `local`, called it, confirmed `$result` **did** leak and held the last computed value outside the function.

---

### Block 3 — Conditionals

- `if/else` printing UP/DOWN by status.

- Added `elif` for a third branch (`failed`), giving three distinct outputs per server.

- Built the service-tier `case`:
  ```bash
  case "$service" in
      nginx|proxy*) tier="web" ;;
      postgres|redis) tier="data" ;;
      *) tier="other" ;;
  esac
  ```
  Confirmed all 15 lines bucket correctly, including `proxy01`/`proxy02` matching via the `*` wildcard and `auth-service`/`job-worker`/`prometheus` correctly falling through to `*)`.

- Regex-flagged the `.10`–`.29` IP range:
  ```bash
  if [[ $ip =~ ^192\.168\.1\.(1|2)[0-9]$ ]]; then
      echo "$name ($ip) is in the .10-.29 range"
  fi
  ```

- Combined conditions with `&&` to find servers that are both `running` AND `cpu_load` over `50` — confirmed `db01`, `cache02`, `worker01`, `worker02` matched, and confirmed a low-cpu running server (`web01`, cpu 42) correctly did not.

---

### Block 4 — break/continue

- `continue`-skipped `stopped`/`failed` servers, printing only running ones — confirmed 11 of 15 servers printed.

- `break`-stopped the loop the instant `cpu_load` exceeded `90`, with an alert message — confirmed it stops exactly at `cache02` (cpu 97), nothing after it in the file gets processed.

- Nested loop over 3 services / `disk memory cpu` checks — confirmed a plain `break` inside the inner loop only stops that inner loop; the outer loop keeps iterating through all 3 services regardless.

---

### Capstone — `fleet-report.sh`

Final script combines all four blocks:

1. `validate_args "$#" 0` checked via `if ! validate_args "$#" 0; then exit 2; fi`
2. `while IFS=, read -r ...` main loop over `fleet.txt`
3. `continue` past `stopped`/`failed`
4. `cpu_tier()` called and captured per server; service `case` run per server
5. Printed `name | service_tier | cpu_tier` per running server
6. `break` + alert the instant a `critical` tier is hit
7. Counter incremented per processed server, total printed at the end
8. Exit `1` if broke early (flag variable set right before `break`), exit `0` otherwise

**Confirmed:**
- Full run stops at `cache02`, prints the alert, `echo $?` shows `1`
- With `cache02`'s line commented out, rerun processes the full remaining fleet with no alert, `echo $?` shows `0`
- `cache02`'s line restored afterward

---

## Break/Fix Logs

### Issue 1 — Off-by-one in C-style `for` loop

Problem:
```bash
for ((i=0; i<=5; i++)); do echo "$i"; done
```
Meant to print exactly 5 numbers, printed 6 (`0` through `5`).

Cause:
`i<=5` includes `5` itself, so the loop runs for 6 values (`0,1,2,3,4,5`), not 5.

Fix:
```bash
for ((i=0; i<5; i++)); do echo "$i"; done
```
(equivalently `i<=4`, or start at `1` and keep `i<=5`)

Prevention:
Count the actual values a range produces before assuming a boundary is correct — `<=N` starting from `0` always produces `N+1` values, not `N`.

---

### Issue 2 — Infinite `until` loop from a variable that never changes

Problem:
```bash
i=10
until [ "$i" -eq 0 ]; do echo "$i"; done
```
Never terminates.

Cause:
The loop body never modifies `$i`, so the condition (`$i -eq 0`) can never become true — `until` keeps running while the condition stays false forever.

Fix:
```bash
i=10
until [ "$i" -eq 0 ]; do
    echo "$i"
    i=$((i - 1))
done
```

Prevention:
Every loop condition needs something inside the loop body that actually moves it toward becoming true — checked this specifically for `until`, since it's easy to assume the condition alone "does something."

---

### Issue 3 — `case` fall-through from a missing `;;`

Problem:
```bash
case "$status" in
  running)
    echo "ok"
  stopped)
    echo "down"
    ;;
esac
```
`running` branch had no terminator and fell straight into `stopped`'s code.

Cause:
Every `case` branch needs its own `;;` — without it, Bash keeps executing straight into the next pattern's block regardless of whether it matches.

Fix:
```bash
case "$status" in
    running) echo "ok" ;;
    stopped) echo "down" ;;
esac
```

Prevention:
Treat `;;` as mandatory punctuation, same as a semicolon ending a sentence — never leave a `case` branch without one, even a one-line branch.

---

### Issue 4 — Scope leak from a missing `local`

Problem:
```bash
tier="unset"
set_tier() { tier="web"; }
set_tier
echo "$tier"
```
Prints `web` — the global `tier` got silently overwritten.

Cause:
No `local` inside `set_tier()` — the function modifies the exact same global variable rather than creating its own separate copy.

Fix:
```bash
set_tier() { local tier="web"; }
```
Confirmed: after adding `local`, `echo "$tier"` outside the function correctly prints `unset`, proving the outer variable was never touched.

Prevention:
Every variable assigned inside a function needs `local` unless the function is deliberately meant to modify something in the outer scope.

---

### Issue 5 — `break` only affecting the inner loop, not the outer one

Problem:
```bash
for outer in a b c; do
  for inner in 1 2 3; do
    if [ "$inner" -eq 2 ]; then break; fi
    echo "$outer-$inner"
  done
done
```
Goal was to stop everything once `inner` hit 2 for any `outer`. Instead, the outer loop kept going through `a`, `b`, `c` — only the current inner loop stopped each time.

Cause:
A plain `break` only ever exits the loop it's directly inside — it has no effect on any loop wrapped around it.

Fix:
```bash
for outer in a b c; do
  for inner in 1 2 3; do
    if [ "$inner" -eq 2 ]; then break 2; fi
    echo "$outer-$inner"
  done
done
```
`break 2` tells Bash to break out of 2 levels of loop nesting instead of just 1.

Prevention:
Whenever a nested loop needs to stop entirely (not just the innermost level), count how many loop levels need to end and use `break N` — plain `break` is always scoped to the loop directly containing it.

---

### Issue 6 — Unreliable glob match using single brackets

Problem:
```bash
name="proxy02"
if [ "$name" == proxy* ]; then echo "match"; fi
```
Match behavior depended on what files happened to exist in the current directory — not on `$name` at all.

Cause:
`[ ]` doesn't support pattern matching. Inside `[ ]`, `proxy*` gets treated as a filename glob candidate for expansion against the actual filesystem — if matching files exist, it expands into real filenames (breaking the comparison); if none exist, it's left as a literal 3-character-plus-asterisk string, which `"proxy02"` will never equal.

Fix:
```bash
if [[ "$name" == proxy* ]]; then echo "match"; fi
```
`[[ ]]` interprets `proxy*` as a genuine pattern — "starts with proxy" — with no connection to files on disk.

Prevention:
Any pattern matching (`*`, `?`, character classes) inside a condition requires `[[ ]]`, never `[ ]`. This is a concrete, reproducible case where the two brackets are not interchangeable.

---

### Issue 7 — `return` used to hand back text instead of a status

Problem:
```bash
check_status() {
  if [ "$1" == "running" ]; then return "ok"; fi
}
result=$(check_status "running")
echo "$result"
```
Threw `numeric argument required` and `$result` never held anything useful.

Cause:
`return` can only hand back a number from 0–255 (an exit status) — it cannot return text. `"ok"` isn't a valid exit code, hence the error.

Fix (two valid approaches depending on intent):
```bash
# Option A — if only true/false is needed
check_status() {
    [ "$1" == "running" ]
}
if check_status "running"; then echo "yes"; fi
```
```bash
# Option B — if actual text is needed back
check_status() {
    if [ "$1" == "running" ]; then echo "ok"; fi
}
result=$(check_status "running")
```

Prevention:
Decided up front, before writing a function, whether it needs to hand back a status (`return`, checked with `if function_name` or `$?`) or actual data (`echo`, captured with `$()`) — never both through the same mechanism.

---

## Key Patterns

- Most issues came from:
  - boundary/off-by-one errors in loop conditions
  - forgetting a loop body needs to actually change the value the condition checks
  - missing `;;` in `case`, causing silent fall-through
  - missing `local`, causing a function to silently corrupt an outer-scope variable
  - assuming `break` affects every loop it's nested inside, instead of just the innermost one
  - assuming `[ ]` and `[[ ]]` are interchangeable for pattern matching — they are not
  - confusing what `return` can hand back (a number only) versus what `echo` can hand back (real data)

- Effective debugging tools:
  - predicting output before running, then comparing
  - testing a function in isolation (`function_name "known_input"; echo $?` or `result=$(function_name "known_input"); echo "$result"`) before wiring it into a bigger loop
  - deliberately breaking `local` on purpose to see a variable leak, to prove the mechanism rather than just trust the rule

---

## Main Takeaways

- Every command in Bash produces an exit status: `0` means success/true, anything else means failure/false — `if` never reads "true/false" directly, it always reads this number.
- `[ ]` is a command, not special syntax — this is why `if` works identically whether given `[ ]`, `[[ ]]`, or a plain function call: it always just checks the exit status of whatever runs.
- `return` and `echo` are not interchangeable: `return` only ever hands back a number (0–255), `echo` hands back real output — mixing them up is one of the most common early function mistakes.
- `local` is not optional style — without it, a function's internal variable IS the same variable that exists everywhere else in the script, and any function can silently corrupt it.
- `break` is scoped to exactly the loop it's written inside; `break N` is required to escape N levels of nesting at once.
- `case` is for one variable checked against several known values/patterns; `if`/`elif` is for combining different kinds of checks (numeric, string, file tests) together.
- `[[ ]]` is required, not optional, the moment pattern matching (`*`) or regex (`=~`) is involved — `[ ]` either does something unexpected (filesystem globbing) or nothing useful at all.
- Always think:
  - is this exit code 0 (success) or non-zero (failure), and does my `if` match that correctly?
  - does this function need to return data (`echo`) or a status (`return`) — never both through the same channel?
  - does this loop's condition actually change on every iteration, or will it run forever?