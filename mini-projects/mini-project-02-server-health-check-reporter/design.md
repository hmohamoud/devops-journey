# Design

## Input
The script reads a fleet inventory file, defaulting to `data/servers.txt` if no argument is given.

Each line has 7 comma-separated fields:

```text
name,ip,status,port,service,cpu_load,uptime_days
```

Example:

```text
web01,192.168.1.10,running,8080,nginx,42,120
web03,192.168.1.12,stopped,8080,nginx,0,0
cache02,192.168.1.31,running,6379,redis,97,90
```

## Process
1. `set -euo pipefail` immediately after the shebang.
2. Set a `trap` on `EXIT` that always prints a final summary line, no matter how the script ends.
3. Set a `trap` on `ERR` that logs the failing line number to a file in `errors/`.
4. Determine the input file: use `$1` if given, otherwise default to `data/servers.txt` using a default-value expansion.
5. Confirm the file exists (`-f` test) and is not empty (`-s` test); if either fails, write a specific error to `errors/` and exit `1`.
6. Read the file line by line with `while IFS=, read -r name ip status port service cpu_load uptime_days`.
7. For each line, confirm it split into exactly 7 non-empty fields; if not, log it as a malformed-line error and skip that record rather than crashing.
8. Pass `status` and `cpu_load` into a `classify_health()` function that returns `HEALTHY`, `WARNING`, or `DOWN` via a `local`-scoped variable.
9. Print one line per server into the report buffer: `name | status | cpu_load% | HEALTH`.
10. Keep running counters for total servers processed, and how many are HEALTHY, WARNING, and DOWN.
11. If zero valid server lines were found, write "No servers found in input file" into the report instead of an empty table.
12. Write the timestamp, the per-server table, and the counts into a report file named with a timestamp, inside `reports/`.
13. Determine the final exit code based on the counts (see Error Handling below) and let the `EXIT` trap print the summary before the script actually exits.

## Output
The script creates a report file in `reports/` named `health-report-YYYY-MM-DD_HH-MM-SS.txt`.

The report should include:
1. Report title
2. Timestamp
3. Which input file was scanned
4. One line per server: name, status, cpu_load, health classification
5. Total servers processed
6. Count of HEALTHY servers
7. Count of WARNING servers
8. Count of DOWN servers
9. A final overall summary line (e.g. "Fleet status: 2 servers DOWN — action required" or "Fleet status: all healthy")
10. A "No servers found" message if the input file had zero valid records

## Error Handling
- No argument passed → default to `data/servers.txt` (not an error by itself)
- File doesn't exist → write specific error to `errors/`, exit `1`
- File exists but is empty → write specific error to `errors/`, exit `1`
- A line doesn't split into 7 fields → log the malformed line to `errors/`, skip it, continue processing the rest of the file (don't let one bad line kill the whole report)
- Any unexpected command failure → caught by the `ERR` trap, logged with the failing line number to `errors/`
- Script exits for any reason → `EXIT` trap always fires, always prints a final summary to the terminal, regardless of success or failure

## Exit Code Plan
- `0` — file processed successfully, zero DOWN servers (WARNING servers alone don't fail the run)
- `1` — input file missing, empty, or at least one DOWN server found
- `2` — invalid usage (e.g. too many arguments, `-h`/`--help` misuse)

## Testing Plan
1. Run the script with no argument and confirm it defaults to `data/servers.txt` and works normally
2. Run the script with a valid file and confirm a report is created in `reports/`
3. Manually count HEALTHY/WARNING/DOWN servers in the input file and confirm the report's counts match
4. Confirm `cache02`-style servers (running, cpu_load ≥ 80) are correctly classified WARNING, not HEALTHY or DOWN
5. Confirm `stopped`/`failed` servers are correctly classified DOWN
6. Run the script against a missing file path and confirm exit `1`, a message in `errors/`, and that the `EXIT` trap still prints a summary
7. Run the script against an empty file and confirm the "No servers found" path
8. Add a deliberately malformed line (missing a field) and confirm it's logged to `errors/` and skipped, without crashing the rest of the run
9. Run the script twice in a row and confirm both report files exist in `reports/` with different timestamps, neither overwritten
10. Run `shellcheck` against the finished script and resolve every warning