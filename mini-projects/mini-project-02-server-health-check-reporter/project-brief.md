# Mini Project 2: Server Health Check Reporter

## Problem
When you're responsible for a fleet of servers, checking each one's status by hand — is it running, is CPU too high, has it been up long enough to trust — is slow and easy to get wrong under pressure. Nobody wants to manually eyeball a spreadsheet of servers during an incident.

## Why This Matters
Saves time. A DevOps/SRE/platform engineer shouldn't have to manually read through a server list to figure out what's healthy and what isn't. Automating the check means the engineer only has to look at the servers that actually need attention, instead of scanning everything by hand every time something might be wrong.

## User
A junior DevOps, SRE, cloud, or platform engineer who needs a fast, repeatable way to check fleet health without opening a dashboard or SSHing into every box individually.

## Health Definition
A server's health is determined from three fields in its record: `status`, `cpu_load`, and `uptime_days`.

- **DOWN** — `status` is `stopped` or `failed`
- **WARNING** — `status` is `running` but `cpu_load` is `80` or higher
- **HEALTHY** — `status` is `running` and `cpu_load` is below `80`

This check is field-based, not live — it reads a fleet inventory file rather than connecting to real servers, matching the skills built in Labs 1–10. It could be extended later (Phase 4 — Networking & Remote Ops) to run real remote checks over SSH instead of reading a static file.

## Goal
Build a Bash script that reads a fleet inventory file, classifies every server as HEALTHY / WARNING / DOWN, and generates a clean, readable report — with correct exit codes and safe error handling, so it's trustworthy enough to run unattended (e.g. from cron or CI).

## Inputs
The script reads one server inventory file:

- `data/servers.txt`

Format: `name,ip,status,port,service,cpu_load,uptime_days`

## Outputs
The tool creates a report file inside the `reports/` directory.

The report should contain:
- the time the report was generated
- every server's name, status, cpu_load, and computed health classification
- counts of HEALTHY, WARNING, and DOWN servers
- a clear final summary line stating whether the fleet is fully healthy or not
- a message if the input file has zero servers in it

Script errors (missing argument, missing file, malformed line) should be written to the `errors/` directory, and the script should still produce a final summary even when it exits early due to an error (via a trap).

## Skills From Labs
Navigation, permissions, text processing (`grep`, `wc`), pipes, stdout/stderr redirection, script anatomy and debugging, process/exit-code discipline, Bash data types and arrays (Lab 08), loops/functions/conditionals (Lab 09), and `set -euo pipefail` / `trap` / `shellcheck` error handling (Lab 10).

## Success Criteria
The project works if it creates a report file in `reports/` that correctly classifies every server, includes accurate HEALTHY/WARNING/DOWN counts, includes a timestamp, and returns a distinct, correct exit code for: missing argument, missing file, fleet with at least one DOWN server, and a fully healthy fleet. Script errors are written to `errors/`, not lost, and the script never crashes with a raw Bash error — only its own clear messages.