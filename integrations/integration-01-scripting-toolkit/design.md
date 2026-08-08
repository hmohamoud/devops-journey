# Design — Integration 1: Scripting Toolkit

## Architecture

```text
integration-01-scripting-toolkit/
├── project-brief.md
├── design.md
├── instructions.md
├── notes.md
├── evidence.md
├── challenge.md
├── README.md
├── config/
│   └── toolkit.conf
├── lib/
│   └── common.sh
├── data/
│   ├── servers.txt
│   └── sample-logs/
│       └── app.log
├── scripts/
│   ├── toolkit.sh
│   ├── system-audit.sh
│   ├── log-scanner.sh
│   └── health-check.sh
├── reports/
├── errors/
└── logs/
```

**Rule that defines this whole project:** if two scripts need the same value or the same small piece of logic, it lives in `config/toolkit.conf` or `lib/common.sh` — never copy-pasted into both scripts. A script that duplicates something already in the shared layer is a bug, not a stylistic choice.

---

## Shared Configuration — `config/toolkit.conf`

Sourced by every component script, near the top, right after `set -euo pipefail`.

Must define:

```bash
FLEET_FILE="${FLEET_FILE:-data/servers.txt}"
LOG_FILE="${LOG_FILE:-data/sample-logs/app.log}"
REPORT_DIR="${REPORT_DIR:-reports}"
ERROR_DIR="${ERROR_DIR:-errors}"
LOG_DIR="${LOG_DIR:-logs}"
TIMESTAMP_FORMAT="+%Y-%m-%d_%H-%M-%S"
CPU_WARNING_THRESHOLD=80
```

Each value uses `${VAR:-default}` so an environment variable can override it without editing the file — this is the Lab 08 default-value pattern applied at the config level, not just inside individual scripts.

---

## Shared Function Library — `lib/common.sh`

Sourced by every component script, immediately after `config/toolkit.conf`.

Must define:

- **`log_error(message)`** — writes a timestamped line to a file in `$ERROR_DIR`, using the shared `$TIMESTAMP_FORMAT`
- **`log_info(message)`** — prints a timestamped line to the terminal (Lab 09's `log_line` pattern)
- **`validate_arg_count(actual, required)`** — prints usage and returns `2` if the count doesn't match (Lab 08/09 pattern)
- **`require_file(path)`** — `-f` check; calls `log_error` and returns `1` if missing (Lab 05/08 pattern)
- **`require_dir(path)`** — `-d` check; creates the directory with `mkdir -p` if missing rather than failing, since output directories should self-heal
- **`timestamp()`** — returns `$(date "$TIMESTAMP_FORMAT")`, so every script generates timestamps identically

No component script defines its own version of any of these. If `health-check.sh` needs a slightly different file-check message, that's a parameter to `require_file()`, not a reason to write a second function.

---

## Dispatcher — `scripts/toolkit.sh`

**Process:**
1. `set -euo pipefail`
2. Source `config/toolkit.conf`, then `lib/common.sh`
3. `trap` on `EXIT` — prints "Toolkit run complete" regardless of outcome
4. `trap` on `ERR` — logs the failing line via `log_error`
5. Read `$1` as the subcommand
6. No subcommand, or subcommand not in `{audit, logs, health}` → usage message, `exit 2`
7. `case "$1" in audit) exec scripts/system-audit.sh ;; logs) exec scripts/log-scanner.sh ;; health) exec scripts/health-check.sh ;; esac`
8. Whichever component runs determines the final exit code — the dispatcher doesn't swallow or rewrite it

---

## Component 1 — `scripts/system-audit.sh` (Labs 01, 02, 03, 06)

**Input:** the toolkit's own directory structure — no external data file needed.

**Process:**
1. Source config + common lib
2. Confirm every expected top-level directory (`config/`, `lib/`, `data/`, `scripts/`, `reports/`, `errors/`, `logs/`) exists, using `require_dir()` — demonstrate both an absolute-path check and a relative-path check at least once each (Lab 01)
3. For every `.sh` file in `scripts/` and `lib/`, check whether it's executable (`-x`) — flag any that aren't (Lab 02)
4. Use `find` to locate every script, config, and log file in the toolkit and list them (Lab 03, 07)
5. Use `pgrep`/`ps` to confirm no other instance of the toolkit is already mid-run before starting (Lab 06 — kept intentionally small and honest, not forced)

**Output:** a report in `$REPORT_DIR` listing directory status, script permission status, and the file inventory.

**Exit codes:** `0` — structure clean; `1` — a required directory or executable script is missing/wrong.

---

## Component 2 — `scripts/log-scanner.sh` (Labs 03, 04, 07)

**Input:** `$LOG_FILE`

**Process:**
1. Source config + common lib
2. `require_file "$LOG_FILE"`
3. Extract ERROR/WARNING lines case-insensitively (Lab 03/MP1 pattern)
4. Rank the most common message using `sort | uniq -c | sort -nr` (Lab 03, 07)
5. Build the report using command substitution for every dynamic value — no manually typed counts (Lab 04, 05)
6. If zero ERROR/WARNING lines are found, write "No errors or warnings found" instead of an empty section (MP1 pattern, carried forward)

**Output:** a report in `$REPORT_DIR` with counts, the ranked most-common message, and matching lines.

**Exit codes:** `0` — scan completed, regardless of whether incidents were found; `1` — log file missing or empty.

---

## Component 3 — `scripts/health-check.sh` (Labs 08, 09, 10, Mini Project 2)

This is MP2's script, refactored:

- `validate_arg_count`, `require_file`, `log_error` now come from `lib/common.sh` — the versions previously written directly inside this script are deleted
- `$FLEET_FILE`, `$REPORT_DIR`, `$ERROR_DIR`, `$CPU_WARNING_THRESHOLD` now come from `config/toolkit.conf` instead of being hardcoded or passed as `$1`
- `classify_health()` stays local to this script — it's domain-specific logic, not something `system-audit.sh` or `log-scanner.sh` would ever need
- The array-building loop, per-server report lines, HEALTHY/WARNING/DOWN counters, and final exit-code logic (`0` clean, `1` at least one DOWN) are unchanged from MP2
- `set -euo pipefail`, `EXIT` trap, `ERR` trap remain exactly as built in MP2/Lab 10

---

## Error Handling — Consistent Across All Three Components

- Every script starts with `#!/bin/bash` then `set -euo pipefail` as line two, no exceptions
- Every script sources `config/toolkit.conf` then `lib/common.sh` before any other logic
- Every script sets its own `EXIT` and `ERR` traps immediately after sourcing (traps aren't shared across scripts — each script's trap fires for that script's own lifecycle)
- Every error, from any component, lands in `$ERROR_DIR` using `log_error()` — same format, same directory, no exceptions
- Exit code scheme is identical across all three: `0` clean, `1` operational failure (missing/empty file, DOWN servers, missing directories), `2` bad usage (wrong argument count, invalid subcommand)

---

## Integration Points — What Actually Makes This "Integrated"

1. **Shared config test:** change `REPORT_DIR` in `config/toolkit.conf` to a new folder name. Run all three components. Confirm all three write their reports to the new location without any script being edited.
2. **Shared function test:** deliberately point `$FLEET_FILE` at a missing file. Confirm `health-check.sh`'s error message, format, and destination match `log-scanner.sh`'s error message format when `$LOG_FILE` is missing — because both are calling the same `require_file()` function, not two different hand-written checks.
3. **Dispatcher test:** confirm `./scripts/toolkit.sh health` produces identical behavior to running `./scripts/health-check.sh` directly — the dispatcher must not alter behavior, only route to it.

---

## Testing Plan

1. Run `./scripts/toolkit.sh` with no subcommand — confirm usage message and exit `2`
2. Run `./scripts/toolkit.sh badcommand` — confirm usage message and exit `2`
3. Run `./scripts/toolkit.sh audit` — confirm directory/permission/file-inventory report generated
4. Run `./scripts/toolkit.sh logs` — confirm log scan report generated, counts correct
5. Run `./scripts/toolkit.sh health` — confirm health report generated, counts correct, correct exit code
6. Change `REPORT_DIR` in `config/toolkit.conf`, re-run all three, confirm reports land in the new location
7. Rename `data/servers.txt` temporarily, run `./scripts/toolkit.sh health`, confirm the error message/format matches what `log-scanner.sh` produces when its input file is missing
8. Confirm every script's `EXIT` trap fires even when the script exits early due to an error
9. Confirm every script's `ERR` trap correctly logs a failing line number when a command is forced to fail
10. Run `shellcheck` against every file in `scripts/` and `lib/` — resolve every warning