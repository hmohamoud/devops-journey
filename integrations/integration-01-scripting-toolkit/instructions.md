# Integration 1: Scripting Toolkit

## What I'm Building

A multi-script Bash toolkit combining Labs 01–10 and Mini Project 2: three component scripts (`system-audit.sh`, `log-scanner.sh`, `health-check.sh`) that share one configuration file and one function library, all routed through a single dispatcher (`toolkit.sh`).

## Why

Real automation tooling isn't one script solving one problem in isolation — it's several scripts that agree on configuration, error handling, and exit codes, so a team can maintain and extend them without relearning a new pattern for every file. This project proves I can build that, not just complete individual lab exercises.

## Rules

- Use Bash only.
- Use only commands and skills learned from Labs 01–10 and Mini Project 2.
- Do not use Python, Docker, AWS, Terraform, Kubernetes, or external tools.
- No duplicated logic: if two scripts need the same function or value, it belongs in `lib/common.sh` or `config/toolkit.conf`, not copy-pasted into both.
- Every script starts with `#!/bin/bash` then `set -euo pipefail`, no exceptions.
- Every script sources `config/toolkit.conf` and `lib/common.sh` before any other logic.
- Every script uses the same exit-code scheme: `0` clean, `1` operational failure, `2` bad usage.
- Design the project before writing any script.
- Test each component individually before wiring it into the dispatcher.
- Document mistakes, tests, and fixes in `evidence.md`.
- Write `README.md` last, after the whole toolkit works.
- The finished toolkit must pass `shellcheck` with zero warnings on every script.

---

## Shared / Global Requirements

### `config/toolkit.conf`

- [ ] Defines exactly these 7 variables, in this order, each using `${VAR:-default}`:

```bash
FLEET_FILE="${FLEET_FILE:-data/servers.txt}"
LOG_FILE="${LOG_FILE:-data/sample-logs/app.log}"
REPORT_DIR="${REPORT_DIR:-reports}"
ERROR_DIR="${ERROR_DIR:-errors}"
LOG_DIR="${LOG_DIR:-logs}"
TIMESTAMP_FORMAT="${TIMESTAMP_FORMAT:-+%Y-%m-%d_%H-%M-%S}"
CPU_WARNING_THRESHOLD="${CPU_WARNING_THRESHOLD:-80}"
```

- [ ] This file contains **only** variable assignments — no functions, no `echo`, no logic. It is sourced, never executed directly.
- [ ] Prove overridability: run `CPU_WARNING_THRESHOLD=90 bash -c 'source config/toolkit.conf; echo "$CPU_WARNING_THRESHOLD"'` and confirm it prints `90`, not `80`.

### `lib/common.sh`

- [ ] Defines exactly these 6 functions. Each signature, parameters, and return behavior below is exact — not a suggestion:

**`timestamp()`**
- Takes no arguments
- Returns (via `echo`) the output of `date "$TIMESTAMP_FORMAT"`
- Usage: `now=$(timestamp)`

**`log_error(message)`**
- Takes exactly one argument: `$1` = the error message text
- Writes one line to `"$ERROR_DIR/toolkit-error-$(timestamp).log"` in this exact format: `"[$(timestamp)] $1"`
- Uses `>>` (append), never `>`
- Calls `require_dir "$ERROR_DIR"` internally first, so it never fails because the directory doesn't exist yet
- Does not exit or return a non-zero code itself — logging an error is not the same as handling one; the caller decides what happens next

**`log_info(message)`**
- Takes exactly one argument: `$1` = the message text
- Prints one line to the terminal (not a file) in this exact format: `"[$(timestamp)] $1"`

**`validate_arg_count(actual, required)`**
- Takes exactly two arguments: `$1` = actual count (you will always pass `"$#"` from the calling script), `$2` = required count
- If `$1 -ne $2`: calls `log_error` with a message naming which script failed validation, then the caller must `exit 2` — this function does **not** call `exit` itself, because `exit` inside a sourced function still exits the *whole calling script*, which is correct here, but making that explicit avoids confusion about where the exit actually happens
- Returns `0` (does nothing else) if the count matches

**`require_file(path)`**
- Takes exactly one argument: `$1` = file path to check
- If `[ ! -f "$1" ]`: calls `log_error` with the message `"Required file not found: $1"`, then `return 1`
- If the file exists: `return 0`
- Does **not** exit the script itself — the caller checks the return code and decides whether to `exit 1`

**`require_dir(path)`**
- Takes exactly one argument: `$1` = directory path to check
- If `[ ! -d "$1" ]`: creates it with `mkdir -p "$1"`, then calls `log_info` confirming it was created
- Never fails or logs an error — a missing output directory is expected and self-healing, not a problem
- Returns `0` always

- [ ] This file contains **only** function definitions — no code runs when it's sourced, only when a function is later called.

### Cross-script consistency

- [ ] All three component scripts (`system-audit.sh`, `log-scanner.sh`, `health-check.sh`) source `config/toolkit.conf` then `lib/common.sh`, in that exact order, as the first two non-comment lines after `set -euo pipefail`
- [ ] Sourcing syntax used consistently: `source "$(dirname "$0")/../config/toolkit.conf"` and `source "$(dirname "$0")/../lib/common.sh"` — using `dirname "$0"` so each script works regardless of which directory it's run from, not just from the project root
- [ ] No component script contains its own `validate_args`, file-check, or error-logging code — every one of those calls goes through `lib/common.sh`
- [ ] No component script hardcodes a literal path or number that already has a variable in `config/toolkit.conf` — e.g. never `"data/servers.txt"` written directly inside `health-check.sh`, only `"$FLEET_FILE"`
- [ ] Exit code meaning is identical everywhere: `0` = ran clean, `1` = an operational check failed (missing file, DOWN server found, missing required item), `2` = the script itself was invoked wrong (bad argument count, invalid subcommand)
- [ ] Every component script sets its own `trap '...' EXIT` and `trap '...' ERR` — each script's traps only cover that script's own execution, they are not inherited from `toolkit.sh`
- [ ] Every script in `scripts/` is executable: `chmod +x scripts/*.sh`
- [ ] `shellcheck scripts/*.sh lib/*.sh` reports zero warnings, run as one combined command against every file at once

---

## `system-audit.sh` Requirements (Labs 01, 02, 03, 06)

Takes **no arguments**. No `$1` is ever read by this script.

Build it in this exact order — each step below is one thing to write, run, and confirm before moving to the next. Nothing is optional and nothing is "e.g." — every value given is the literal value to use.

---

**Step 1 — Header**

```bash
#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/../config/toolkit.conf"
source "$(dirname "$0")/../lib/common.sh"
```

- [ ] These exact four lines are the first four non-blank lines in the file.

---

**Step 2 — Traps (set immediately after sourcing, before any other logic)**

```bash
trap 'echo "System audit complete."' EXIT
trap 'log_error "system-audit.sh failed at line $LINENO"' ERR
```

- [ ] The `EXIT` trap prints the literal text `System audit complete.` to the terminal — not to a file, not to `$REPORT_DIR`.
- [ ] The `ERR` trap calls `log_error`, passing it the exact string `system-audit.sh failed at line $LINENO` — `$LINENO` is a Bash built-in that automatically fills in the actual failing line number when the trap fires; you type `$LINENO` literally, you do not replace it with a number yourself.

---

**Step 3 — The "already running" check (this runs BEFORE anything else, including the directory checks in Step 4)**

- [ ] Run: `pgrep -f "toolkit.sh"`
- [ ] Capture the result: `running_count=$(pgrep -f "toolkit.sh" | wc -l)`
- [ ] Because this script itself might match `toolkit.sh` if it was launched via the dispatcher, check if `running_count` is greater than `1` (not `0` — `1` match is expected to be normal, `2` or more means a second instance is genuinely running)
- [ ] If `running_count -gt 1`: call `log_error "Another toolkit process appears to be running"`, then `exit 1` immediately — do not proceed to Step 4 at all
- [ ] If `running_count` is `1` or `0`: continue to Step 4

---

**Step 4 — Directory existence checks**

- [ ] Check these exact 7 paths, one call to `require_dir()` per path, in this exact order:

```bash
require_dir "config"
require_dir "lib"
require_dir "data"
require_dir "scripts"
require_dir "$REPORT_DIR"
require_dir "$ERROR_DIR"
require_dir "$LOG_DIR"
```

- [ ] The first 4 are typed as literal strings (`"config"`, `"lib"`, `"data"`, `"scripts"`) because these directory names never change.
- [ ] The last 3 are typed as variables (`"$REPORT_DIR"`, `"$ERROR_DIR"`, `"$LOG_DIR"`), never as literal strings like `"reports"`, because these come from `config/toolkit.conf` and must stay changeable from that one file.
- [ ] For each of the 7, store whether it existed *before* `require_dir()` ran (since `require_dir()` self-heals by creating missing directories, you need to record the "before" state to report it accurately — e.g. `if [ -d "config" ]; then config_status="OK"; else config_status="MISSING (created)"; fi`, done once per directory, *before* calling `require_dir()` on it).

---

**Step 5 — One absolute-path check, one relative-path check (separate from Step 4, this is a second, distinct demonstration)**

- [ ] Absolute: `if [ -d "$(pwd)/scripts" ]; then echo "Absolute path check: OK"; fi`
- [ ] Relative: `if [ -d "./scripts" ]; then echo "Relative path check: OK"; fi`
- [ ] Both of these check the same physical directory (`scripts/`) two different ways, purely to demonstrate you can address a path both ways — this is not a new directory being validated, it's proof of the Lab 01 skill.

---

**Step 6 — Executable-permission check on every script**

- [ ] Loop: `for f in scripts/*.sh lib/*.sh; do ... done`
- [ ] Inside the loop, for each `$f`: `if [ ! -x "$f" ]; then not_executable+=("$f"); fi` — where `not_executable` is an array, declared and initialized as `not_executable=()` *before* the loop starts (same scoping rule as MP2's counters — an accumulating array must exist before the loop, not be reset inside it)
- [ ] This loop does not `exit` or crash on a non-executable file — it only collects the filenames into the array. Nothing about permission failures stops the audit from continuing.

---

**Step 7 — File inventory**

- [ ] Run: `find . -name "*.sh" -o -name "*.conf" -o -name "*.log"`
- [ ] Capture it into a variable: `file_inventory=$(find . -name "*.sh" -o -name "*.conf" -o -name "*.log")`

---

**Step 8 — Write the report**

- [ ] Report path: `"$REPORT_DIR/system-audit-report-$(timestamp).log"`
- [ ] Report content, written in this exact order, nothing added, nothing skipped:
  1. Title line: `System Audit Report`
  2. Timestamp line: `Generated: $(timestamp)`
  3. Seven directory-check lines, one per directory from Step 4, each showing the directory name and its recorded status (`OK` or `MISSING (created)`)
  4. A blank line, then either:
     - If the `not_executable` array from Step 6 is empty: the literal line `All scripts executable`
     - If it is not empty: the heading `NOT EXECUTABLE:` followed by one line per path in the array
  5. A blank line, then the heading `File Inventory:` followed by `$file_inventory`

---

**Step 9 — Final exit code (the very last thing this script does)**

- [ ] Determine if anything failed: the audit "failed" if any of the 7 directories from Step 4 were originally `MISSING`, OR the `not_executable` array from Step 6 has 1 or more entries
- [ ] If nothing failed: `exit 0`
- [ ] If either condition failed: `exit 1`
- [ ] This `if`/`exit` block goes **after** Step 8's report-writing lines, never before — same lesson as MP2's dead-code bug: nothing after `exit` runs, so the report must be fully written first.

---

## `log-scanner.sh` Requirements (Labs 03, 04, 07)

Takes **no arguments** (reads `$LOG_FILE` from config, same pattern as `health-check.sh` defaulting `$FLEET_FILE`).

- [ ] Sources config + common lib as specified above
- [ ] Sets `EXIT` trap: prints `"Log scan complete. Errors: $error_count, Warnings: $warning_count"` — same pattern as `health-check.sh`'s summary trap, meaning `error_count` and `warning_count` must be declared and initialized to `0` before any exit path can be reached, exactly like the counter-scoping lesson from MP2
- [ ] Sets `ERR` trap: calls `log_error` with `"log-scanner.sh failed at line $LINENO"`
- [ ] Calls `require_file "$LOG_FILE"`; if it returns non-zero, exits `1` (the calling script decides to exit, per how `require_file` is defined above)
- [ ] Extracts ERROR lines: `grep -i "ERROR" "$LOG_FILE"`
- [ ] Extracts WARNING lines: `grep -i "WARNING" "$LOG_FILE"`
- [ ] `error_count=$(grep -ic "ERROR" "$LOG_FILE")` and `warning_count=$(grep -ic "WARNING" "$LOG_FILE")` — declared before the `EXIT` trap can fire, same scoping rule as MP2
- [ ] Ranks the single most common message across both ERROR and WARNING lines combined: `grep -iE "ERROR|WARNING" "$LOG_FILE" | sort | uniq -c | sort -nr | head -1`
- [ ] If `error_count` and `warning_count` are both `0`, the report body contains the exact line `"No errors or warnings found"` instead of empty ERROR/WARNING sections
- [ ] Writes the report to `"$REPORT_DIR/log-scan-report-$(timestamp).log"`, containing, in this order: report title, timestamp, file scanned (`$LOG_FILE`), ERROR count, WARNING count, most common message, then the full list of matching lines (or the "No errors or warnings found" line)
- [ ] Every count printed in the report comes from a captured `$(...)` command substitution — never a manually typed number
- [ ] Exits `0` after a completed scan regardless of whether incidents were found (finding zero incidents is a successful, healthy scan, not a failure); exits `1` only if `$LOG_FILE` was missing or empty

---

## `health-check.sh` Requirements (Labs 08, 09, 10, Mini Project 2)

Takes **no arguments** (reads `$FLEET_FILE` from config — this is a change from MP2, where the file path came from `$1`; here it comes from `config/toolkit.conf` instead, consistent with `log-scanner.sh`).

- [ ] Sources config + common lib as specified above, in place of the standalone argument-default logic MP2 used
- [ ] Sets `EXIT` trap exactly as built in MP2: `"Health check complete. Healthy: $count_healthy, Warning: $count_warning, Down: $count_down"`
- [ ] Sets `ERR` trap: calls `log_error` with `"health-check.sh failed at line $LINENO"` (this replaces the standalone `trap '...' ERR` line from MP2, but the behavior is identical — it now just calls the shared function instead of an inline `echo`)
- [ ] Calls `require_file "$FLEET_FILE"`; if it returns non-zero, exits `1`
- [ ] Empty-file check unchanged from MP2: `zero_lines=$(wc -l < "$FLEET_FILE")`, if `0` then `log_error "File was empty - No servers found"` and exit `1`
- [ ] `classify_health()` function is **unchanged** from MP2 — same `local result`, same DOWN/WARNING/HEALTHY branching — except the hardcoded `80` threshold is replaced with `"$CPU_WARNING_THRESHOLD"` from config
- [ ] Array-building loop unchanged from MP2: `while IFS=, read -r name ip status port service cpu uptime`, malformed-line detection via `-z` checks on all 7 fields, `continue` on malformed
- [ ] Counters (`count_healthy`, `count_warning`, `count_down`) declared and initialized to `0` before the loop, exactly as fixed in MP2 — this is the single most important scoping rule carried over from that project
- [ ] Report line format per server unchanged: `"$name | $status | $cpu | $health"`
- [ ] Writes the report to `"$REPORT_DIR/health-check-report-$(timestamp).log"` (uses `$REPORT_DIR` from config now, not a locally-built variable)
- [ ] Errors write to `"$ERROR_DIR"` via `log_error`, not a locally-built `$error_file` variable
- [ ] Final exit-code block unchanged from MP2: three summary `echo` lines written to the report **first**, then `if [ "$count_down" -gt 0 ]; then exit 1; else exit 0; fi` **last** — this exact ordering matters, since MP2 already proved what happens when this order is reversed

---

## `toolkit.sh` (Dispatcher) Requirements

Takes **exactly one argument**: the subcommand.

- [ ] Sources config + common lib once, before any dispatch logic
- [ ] Sets `EXIT` trap: prints `"Toolkit run complete."`
- [ ] Sets `ERR` trap: calls `log_error` with `"toolkit.sh failed at line $LINENO"`
- [ ] Reads `$1` into a variable, e.g. `subcommand="${1:-}"` — using the default-value pattern so zero arguments doesn't crash under `set -u`
- [ ] Valid values for `subcommand` are exactly: `audit`, `logs`, `health` — nothing else
- [ ] If `subcommand` is empty or not one of those three exact values: print `"Usage: ./toolkit.sh {audit|logs|health}"`, exit `2`
- [ ] Dispatch logic uses a `case` statement:
```bash
case "$subcommand" in
  audit)  exec "$(dirname "$0")/system-audit.sh" ;;
  logs)   exec "$(dirname "$0")/log-scanner.sh" ;;
  health) exec "$(dirname "$0")/health-check.sh" ;;
  *)      echo "Usage: ./toolkit.sh {audit|logs|health}"; exit 2 ;;
esac
```
- [ ] Uses `exec`, not a plain call — `exec` replaces the current process with the component script rather than spawning a child process, meaning the component's exit code becomes the dispatcher's exit code directly, with nothing in between to accidentally rewrite it
- [ ] If `$#` is greater than `1` (extra arguments passed alongside the subcommand), this is also invalid usage — print the same usage message, exit `2`, checked before the `case` statement runs

---

## Success Criteria

The project is complete when:

- All three components run correctly both directly (`./scripts/health-check.sh`) and through the dispatcher (`./scripts/toolkit.sh health`), producing identical output and exit codes either way
- No logic is duplicated across scripts — every shared function has exactly one definition, in `lib/common.sh`, and every shared value has exactly one definition, in `config/toolkit.conf`
- Changing `REPORT_DIR` (or any other config value) in one place correctly changes where every component writes its report, without editing any script
- Every script follows the identical exit-code scheme (`0`/`1`/`2` meaning the same thing everywhere) and the identical error-logging format (`"[$(timestamp)] $message"` in `"$ERROR_DIR"`)
- `shellcheck scripts/*.sh lib/*.sh` reports zero warnings in one combined run
- I can state, from memory, the exact signature of all 6 functions in `lib/common.sh` and the exact 7 variables in `config/toolkit.conf`