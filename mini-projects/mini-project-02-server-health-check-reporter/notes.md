# Notes — Server Health Check Reporter

Written after actually building the script, not before. These are the real things I learned, in my own words, from real mistakes I made while building this — not textbook definitions.

---

## What Was Learned

### Default-value expansion (`${1:-data/servers.txt}`)
This gives `fleet_file` a fallback value if `$1` was never passed. It's better than checking `if [ -z "$1" ]` first and assigning inside an `if`, because it does the check-and-assign in one line, and it doesn't crash under `set -u` when `$1` doesn't exist at all — `${1:-}` safely returns an empty string instead of an "unbound variable" error.

I initially misunderstood this — I thought `${1:-}` meant "there is no `$1`," but it actually means "give me `$1` if it exists, otherwise fall back safely." When `-h` was passed, `${1:-}` still correctly returned `"-h"` — same as plain `$1` would — it only changes behavior in the *missing* case.

### `while IFS=, read -r ...` vs `awk`
This reads the file one line at a time and splits each line on commas directly into named variables (`name`, `ip`, `status`, etc.) — no external tool needed, and it keeps every field available as its own variable for the rest of that loop iteration.

### Why the health-classification function needs `local`
Without `local`, the `result` variable inside `is_healthy()` would leak out into the global script scope, potentially colliding with a variable of the same name used elsewhere. `local` keeps it contained to just that one function call — it's created fresh and destroyed every time the function runs, and never visible outside it.

### The difference between checking exit status and capturing output
I originally wrote `if is_healthy "$status" "$cpu"` — this only checks whether the function *succeeded* (exit code 0), not what it printed. Since the function never explicitly returns a failure code, that `if` was always true, no matter what health value it actually calculated. The fix was `health=$(is_healthy "$status" "$cpu")` — command substitution, which captures the actual echoed text into a variable I could then compare against.

### Why a function has its own `$1`/`$2`
Inside `validate_args()`, `$1` does NOT mean the script's original first argument — it means whatever was passed into `validate_args` when it was called. This tripped me up hard: I tried comparing `$actual` (which held `$#`, a number) against `"-h"` (a string) and couldn't figure out why it never matched. The fix was realizing the `-h`/`--help` check needed to happen at the script level, using the script's own `$1`, completely separate from `validate_args()`.

### What `set -euo pipefail` actually does for this script
- `set -e` — stops the script the instant any command fails
- `set -u` — stops the script if I reference a variable that was never set (this is what made `${1:-}` necessary in the first place)
- `set -o pipefail` — makes a pipeline report failure if *any* command in it fails, not just the last one

### Why the script needs both an `ERR` trap and an `EXIT` trap
- `ERR` fires the moment something fails, and logs which line it happened on — it's the "what broke" trap
- `EXIT` fires no matter how the script ends — success, `exit 1`, `exit 2`, anything — and is the one thing I can guarantee will always run, so it's where the final summary line belongs

### Why WARNING doesn't count as a failure for the exit code
Per the design, only `DOWN` servers should cause `exit 1` — a server running hot (WARNING) is still up and serving traffic, so it shouldn't be treated the same as one that's completely down. This matches how a real on-call engineer would triage: DOWN is the thing that pages someone, WARNING is the thing you keep an eye on.

---

## Commands Used

```bash
mkdir -p server-health-check/{data,scripts,reports,errors}
nano data/servers.txt
touch scripts/health-check.sh
chmod +x scripts/health-check.sh
nano scripts/health-check.sh
./scripts/health-check.sh
./scripts/health-check.sh data/servers.txt
./scripts/health-check.sh -h
echo $?
cat reports/health-check-report-*.log
cat errors/health-check-error-*.log
shellcheck scripts/health-check.sh
```

---

## Problems Encountered

### Problem 1 — Testing a variable outside the script that ran it
**What happened:** ran `./health-check.sh; echo "$fleet_file"` expecting to see the value `fleet_file` was set to inside the script — got nothing.

**Why it happened:** `./health-check.sh` runs as a separate process (subshell). Any variable set inside it dies with that process the moment the script finishes. My own terminal's shell never had that variable in the first place.

**How I found it:** by testing it directly and getting empty output every time, no matter how I changed the argument.

---

### Problem 2 — Scope: counters resetting
**What happened:** built `count_healthy`/`count_warning`/`count_down` incorrectly twice — first inside `is_healthy()` itself, then inside the `while` loop — before finally getting them right outside the loop.

**Why it happened:** I didn't yet have a solid instinct for "does this need to survive across repeated calls/iterations, or is it fine to reset each time." Anything meant to accumulate has to live outside the thing that repeats.

**How I found it:** it was pointed out and traced through server-by-server (web01 → web02 → web03) to show the counter getting wiped back to `0` every single iteration.

---

### Problem 3 — Function-local `$1` shadowing the script's `$1`
**What happened:** tried to check for `-h`/`--help` inside `validate_args()` by comparing `$actual` (which was actually `$#`, a number) against the string `-h` — it never matched, and I couldn't understand why.

**Why it happened:** didn't realize a function's `$1`/`$2` are entirely its own, based on what's passed in when it's called — not automatically inherited from the script.

**How I found it:** moved the `-h`/`--help` check out of the function entirely and did it at the script level instead, where `$1` still meant what I expected.

---

### Problem 4 — Dead code after `exit`
**What happened:** placed the final `if [ "$count_down" -gt 0 ]; then exit 1; else exit 0; fi` block *before* the three `echo ... >> "$report_file"` lines that write the final counts into the report.

**Why it happened:** didn't trace top-to-bottom that `exit` stops the script immediately — anything after it in either branch never runs.

**How I found it:** re-reading the full script end to end and asking "does this actually run" line by line.

---

## Fixes Applied

- Moved variable-verification `echo` statements *inside* the script itself, not in the outer terminal
- Moved all three counters (`count_healthy`, `count_warning`, `count_down`) to before the `while` loop, initialized once
- Removed the `-h`/`--help` check from `validate_args()` entirely; handled it as a separate `if` at the script level using the script's own `$1`
- Replaced `if is_healthy ...` with `health=$(is_healthy ...)` to actually capture the classification result
- Reordered the script so `validate_args "$#" 1` runs before the `-h` check and file-existence check
- Removed the redundant `-f` re-check before the empty-file test, since the file-existence check earlier already guarantees the file exists by that point
- Moved the final exit-code `if` block to the very end of the script, after the three summary `echo` lines, so they actually execute
- Fixed multiple small syntax bugs: missing spaces before `]`, mismatched quotes in `echo` strings, a missing `then`, `report/` → `reports/` typo, missing `$` on two trap variables

---

## Open Questions / Things I'm Still Unsure About

- Whether the `ERR` trap would still catch a failure that happens *inside* a function call, or only top-level script commands
- Whether `set -e` behaves differently inside the `while` loop if a command inside it fails vs the pipeline feeding the loop (`done < "$fleet_file"`)
- What happens if `shellcheck` flags something in the trap syntax specifically — haven't run it yet