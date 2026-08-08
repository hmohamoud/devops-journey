# Scripting Toolkit — Integration 1

## Purpose

A small, integrated Bash toolkit combining ten labs' worth of Linux and Bash scripting skills into one dependable system: shared configuration, shared functions, and three component scripts routed through a single dispatcher.

This isn't three unrelated scripts sitting in the same folder — it's a real toolkit, in the sense that changing one value in a single config file correctly changes the behavior of every component that depends on it, without editing any script's code.

**Components:**
- `system-audit.sh` — checks the toolkit's own directory structure, script permissions, and file inventory (Labs 01, 02, 03, 06)
- `log-scanner.sh` — scans a log file for ERROR/WARNING incidents and ranks the most common ones (Labs 03, 04, 07)
- `health-check.sh` — classifies a fleet of servers as HEALTHY/WARNING/DOWN (Labs 08, 09, 10, built on Mini Project 2)
- `toolkit.sh` — the single entry point that dispatches to whichever component you need

---

## Installation / Setup

No dependencies beyond Bash and `shellcheck` (used for validation during development).

```bash
git clone <your-repo-url>
cd integration-01-scripting-toolkit
chmod +x scripts/*.sh
```

Directory structure:

```text
integration-01-scripting-toolkit/
├── config/
│   └── toolkit.conf       # shared paths, timestamp format, thresholds
├── lib/
│   └── common.sh          # shared functions — sourced by every script
├── data/
│   ├── servers.txt         # fleet inventory (health-check input)
│   └── sample-logs/
│       └── app.log         # log data (log-scanner input)
├── scripts/
│   ├── toolkit.sh          # dispatcher — start here
│   ├── system-audit.sh
│   ├── log-scanner.sh
│   └── health-check.sh
├── reports/                 # generated reports, timestamped, never overwritten
├── errors/                  # generated errors, timestamped, consistent format
└── logs/
```

---

## Usage

Everything runs through the dispatcher:

```bash
./scripts/toolkit.sh audit    # check directory structure, permissions, file inventory
./scripts/toolkit.sh logs     # scan the configured log file for incidents
./scripts/toolkit.sh health   # classify the configured fleet's health
```

Each component can also be run directly — behavior is identical either way, since the dispatcher only routes, it never alters what a component does:

```bash
./scripts/health-check.sh
```

Check the exit code (useful for cron/CI):

```bash
./scripts/toolkit.sh health
echo $?
```

| Exit Code | Meaning (consistent across every component) |
|---|---|
| `0` | Ran successfully, nothing wrong found |
| `1` | Operational failure — missing/empty input, at least one DOWN server, structure problem found |
| `2` | Invalid usage — bad subcommand, wrong argument count |

### Reconfiguring the toolkit

Everything path- and threshold-related lives in one place:

```bash
# config/toolkit.conf
FLEET_FILE="${FLEET_FILE:-data/servers.txt}"
LOG_FILE="${LOG_FILE:-data/sample-logs/app.log}"
REPORT_DIR="${REPORT_DIR:-reports}"
ERROR_DIR="${ERROR_DIR:-errors}"
CPU_WARNING_THRESHOLD=80
```

Change a value here and every component picks it up automatically — no script needs editing. You can also override any of these at runtime without touching the file at all:

```bash
CPU_WARNING_THRESHOLD=90 ./scripts/toolkit.sh health
```

---

## Features

- **One shared config file** — default paths and thresholds defined once, overridable via environment variables, never hardcoded per-script
- **One shared function library** — argument validation, file/directory checks, timestamped error logging, all written once and reused by all three components
- **Consistent exit codes and error format across every script** — a missing input file produces the same error shape whether it's the fleet file or the log file
- **Single dispatcher entry point** with its own usage/validation, transparent pass-through to whichever component is selected
- **Every component individually production-safe**: `set -euo pipefail`, both `EXIT` and `ERR` traps, malformed/empty-input handling, `shellcheck`-clean
- **Self-healing output directories** — `reports/`, `errors/`, `logs/` are created automatically if missing, rather than treated as a hard failure

---

## Examples

**Directory/permission audit:**

```bash
./scripts/toolkit.sh audit
```
```text
System Audit Report 2026-08-06_10-00-00
Directory check: config/ OK, lib/ OK, data/ OK, scripts/ OK, reports/ OK, errors/ OK, logs/ OK
Permission check: all scripts executable
File inventory: 4 scripts, 1 config, 1 fleet file, 1 log file
```

**Log scan:**

```bash
./scripts/toolkit.sh logs
```
```text
Log Scan Report 2026-08-06_10-01-00
File scanned: data/sample-logs/app.log
ERROR count: 2
WARNING count: 1
Most common: Database connection failed (2)
```

**Health check:**

```bash
./scripts/toolkit.sh health
echo $?
```
```text
Health check complete. Healthy: 7, Warning: 1, Down: 2
```
```text
1
```

**Reconfiguring and re-running without editing any script:**

```bash
REPORT_DIR="reports-2026-audit" ./scripts/toolkit.sh audit
ls reports-2026-audit/
```

---

## What Makes This an Integration, Not Just Three Scripts

The real proof isn't that `audit`, `logs`, and `health` each work — it's that they share the same foundation:

- Change `REPORT_DIR` once in `config/toolkit.conf`, and all three components write to the new location, with zero code changes
- A missing input file produces the exact same error shape, from the exact same `require_file()` function, whether it's `health-check.sh` looking for the fleet file or `log-scanner.sh` looking for the log file
- Every component follows the identical `0`/`1`/`2` exit-code contract, so anything scripting against this toolkit (cron, CI, another script) only has to learn the pattern once

Full architecture details are in `design.md`. The complete build history — every bug hit while wiring the shared library together and refactoring `health-check.sh` out of Mini Project 2 — is in `evidence.md`.