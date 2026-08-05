# Server Health Check Reporter

## Purpose

A Bash tool that reads a fleet inventory file, classifies every server as **HEALTHY**, **WARNING**, or **DOWN**, and generates a timestamped, readable health report — safe enough to run unattended (cron, CI, or on demand) because it handles missing arguments, missing files, empty input, and malformed data without ever crashing with a raw Bash error.

Built as Mini Project 2, combining Labs 1 through 10: navigation, permissions, text processing, redirection, script anatomy, Bash data types and arrays (Lab 08), loops/functions/conditionals (Lab 09), and production-grade error handling — `set -euo pipefail`, `trap`, distinct exit codes (Lab 10).

---

## Installation / Setup

No dependencies beyond Bash and `shellcheck` (used to validate the script during development, not required at runtime).

```bash
git clone <your-repo-url>
cd server-health-check
chmod +x scripts/health-check.sh
```

Directory structure:

```text
server-health-check/
├── data/
│   └── servers.txt       # input — fleet inventory
├── scripts/
│   └── health-check.sh   # the tool
├── reports/               # generated reports land here, timestamped
└── errors/                # script errors land here, timestamped
```

---

## Usage

Run against the default inventory file:

```bash
./scripts/health-check.sh
```

Run against a specific file:

```bash
./scripts/health-check.sh data/servers.txt
```

Check help text:

```bash
./scripts/health-check.sh -h
```

Check the exit code (useful for cron/CI):

```bash
./scripts/health-check.sh data/servers.txt
echo $?
```

| Exit Code | Meaning |
|---|---|
| `0` | Ran successfully, zero servers DOWN |
| `1` | Input file missing, empty, or at least one server DOWN |
| `2` | Invalid usage (too many arguments, or `-h`/`--help`) |

---

## Features

- Reads a comma-separated fleet inventory file (`name,ip,status,port,service,cpu_load,uptime_days`) — pure Bash parsing, no `awk`
- Classifies every server as HEALTHY / WARNING / DOWN based on `status` and `cpu_load`
- Generates a timestamped report in `reports/` on every run — previous reports are never overwritten
- Detects and skips malformed lines (fewer than 7 fields), logging them to `errors/` instead of crashing
- Handles an empty input file cleanly instead of producing a blank, confusing report
- Logs missing-argument and missing-file errors to `errors/`
- `EXIT` trap always prints a completion summary to the terminal, no matter how the script ends
- `ERR` trap logs the failing line number to `errors/` the moment something breaks
- Distinct, predictable exit codes for automation (cron/CI-safe): `0` clean, `1` failure/DOWN servers, `2` bad usage
- Passes `shellcheck` with zero warnings

---

## Examples

**Input** (`data/servers.txt`):

```text
web01,192.168.1.10,running,8080,nginx,42,120
web03,192.168.1.12,stopped,8080,nginx,0,0
cache02,192.168.1.31,running,6379,redis,97,90
```

**Command:**

```bash
./scripts/health-check.sh data/servers.txt
```

**Terminal output (from the EXIT trap):**

```text
Health check complete. Healthy: 1, Warning: 1, Down: 1
```

```bash
echo $?
# 1
```

**Sample report** (`reports/health-check-report-2026-08-05_14-30-00.log`):

```text
Server Health Check Report 2026-08-05_14-30-00
web01 | running | 42 | HEALTHY
web03 | stopped | 0 | DOWN
cache02 | running | 97 | WARNING
Healthy: 1
Warning: 1
DOWN: 1
```

**Missing file:**

```bash
./scripts/health-check.sh data/nonexistent.txt
echo $?
# 1
cat errors/health-check-error-*.log
# data/nonexistent.txt - doesn't exist
```

**Malformed line inside a data file** (e.g. `web09,192.168.1.99,running` — only 3 fields instead of 7):

```text
# logged to errors/, not the report:
Malformed line skipped: web09,192.168.1.99,running,,,,
```
The rest of the file is still processed normally — one bad line doesn't stop the whole run.

---

## What This Project Actually Taught

Beyond the working script, the real value of this build was hitting — and fixing — the same handful of Bash mistakes repeatedly, until they stopped happening:

- **Variable scope** was the single biggest recurring struggle: counters were first built inside the classify function, then inside the loop, before landing in the right place — outside the loop, initialized once. This came up in more than one form throughout the build (see `evidence.md` for every instance).
- **A function's `$1`/`$2` belong to the function, not the script** — trying to check for `-h`/`--help` from inside `validate_args()` failed because the function only ever sees what's explicitly passed into it.
- **Checking a function's exit status is not the same as capturing its output** — `if is_healthy ...` looked reasonable but could never actually branch correctly; command substitution (`health=$(is_healthy ...)`) was the fix.
- **Code placed after `exit` never runs** — the final summary lines were briefly written after the exit-code decision instead of before it, silently making them dead code.

Full details of every bug, in the order they were actually found and fixed, are in `evidence.md`. The reasoning behind each concept is in `notes.md`.