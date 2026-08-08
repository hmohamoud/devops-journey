# Integration 1 — Scripting Toolkit

## Problem

Ten labs' worth of Bash skills — navigation, permissions, text processing, redirection, script anatomy, process awareness, data types, loops/functions/conditionals, and production error handling — currently exist as separate, disconnected exercises. In a real job, nobody hands you "a Lab 03 problem" or "a Lab 08 problem." They hand you a system that's broken in some combination of ways, and you're expected to reach for whatever tool fits, using scripts that share config, share logic, and don't force you to solve the same problem (like "does this file exist" or "log this error") a different way every time.

## Why This Matters

A junior engineer who can only solve isolated lab exercises isn't automation-ready. A junior engineer who can build a small toolkit — multiple scripts, one shared configuration, one shared function library, consistent error handling and exit codes across all of them — is demonstrating the actual shape of production tooling. This is the difference between "I completed 10 labs" and "I can build something a team would actually keep using."

## User

A junior DevOps, SRE, cloud, or platform engineer who needs a single, small, dependable toolkit to audit a system's structure, scan logs for incidents, and check fleet health — without maintaining three unrelated scripts that each reinvent their own argument validation, error logging, and exit code scheme.

## Toolkit Definition

The Scripting Toolkit is not one script. It is:

- **One shared configuration file** (`config/toolkit.conf`) — default paths, timestamp format, and thresholds defined once, sourced everywhere
- **One shared function library** (`lib/common.sh`) — argument validation, file/directory checks, and error logging, written once, reused by every component
- **Three component scripts**, each covering a distinct cluster of lab skills:
  - `system-audit.sh` — Labs 01, 02, 03, 06 (navigation, permissions, discovery, lightweight process check)
  - `log-scanner.sh` — Labs 03, 04, 07 (log inspection, redirection, pattern ranking)
  - `health-check.sh` — Labs 08, 09, 10 (data types, arrays, functions, loops, `set -euo pipefail`, traps) — this is Mini Project 2, refactored to use the shared library instead of standing alone
- **One dispatcher** (`toolkit.sh`) — a single entry point that routes to the correct component based on a subcommand

## Goal

Build a working, integrated Bash toolkit where changing a single value in `config/toolkit.conf` correctly affects every component script without editing any script's internal code — and where every component follows the same exit-code scheme, the same error-logging destination, and the same `set -euo pipefail` + trap discipline established in Lab 10.

## Inputs

- `data/servers.txt` — fleet inventory (reused from Lab 08/09/MP2 format: `name,ip,status,port,service,cpu_load,uptime_days`)
- `data/sample-logs/app.log` — sample application log (reused from Lab 03/04/07/MP1 format)
- `config/toolkit.conf` — shared configuration values

## Outputs

- Timestamped reports written to `reports/`, one per component run, never overwritten
- Timestamped errors written to `errors/`, in a consistent format regardless of which component triggered them
- A terminal summary line from every component's `EXIT` trap, confirming completion regardless of success or failure

## Skills From Labs

Labs 01–10 in full, plus Mini Project 2 (`health-check.sh`'s foundation). Specifically: navigation and absolute/relative paths (01), permissions and `chmod` (02), text processing and pattern ranking (03), redirection and command substitution (04), script anatomy and exit codes (05), lightweight process awareness (06), advanced text processing and config-safe editing patterns (07), data types/arrays/string manipulation (08), loops/functions/conditionals (09), and `set -euo pipefail`/`trap`/`shellcheck` production discipline (10).

## Success Criteria

The toolkit works if:
- `./scripts/toolkit.sh audit`, `./scripts/toolkit.sh logs`, and `./scripts/toolkit.sh health` all run correctly through the dispatcher
- All three component scripts source `config/toolkit.conf` and `lib/common.sh` — no duplicated argument-validation or error-logging logic across scripts
- Changing one path or threshold in `config/toolkit.conf` correctly changes the behavior of every component that uses it, without touching any script's code
- Every component uses the same exit-code scheme (`0` clean, `1` operational failure, `2` bad usage), the same `errors/` logging format, and `set -euo pipefail` with both `EXIT` and `ERR` traps
- `shellcheck` reports zero warnings on every script in `scripts/` and `lib/`
- I can explain the architecture — what's shared, what's per-component, and why — without notes