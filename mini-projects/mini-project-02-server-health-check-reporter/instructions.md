# Mini Project 2: Server Health Check Reporter

## What I'm Building

I am building a Bash health-check script that reads a fleet inventory file, classifies every server as HEALTHY, WARNING, or DOWN, and generates a readable health report with correct exit codes.
The project uses `data/servers.txt` as input and creates a report inside `reports/` as output.

## Why

Manually reading through a list of servers to figure out what's healthy is slow and error-prone, especially under pressure. This project practises how a junior DevOps, SRE, cloud, or platform engineer would use Bash — arrays, functions, loops, conditionals, and production-grade error handling — to automate a fleet health check that's safe to run unattended.

## Rules

- Use Bash only.
- Use only commands and skills learned from the completed Linux labs (through Lab 10).
- Do not use Python, Docker, AWS, Terraform, Kubernetes, or external tools.
- No `awk` for core field-splitting logic — pure Bash (`while IFS=, read -r ...`), consistent with Lab 08/09.
- Every script starts with `#!/bin/bash` followed by `set -euo pipefail`, per Lab 10.
- Design the project before writing the script.
- Test commands manually before adding them to the script.
- Document mistakes, tests, and fixes in `evidence.md`.
- Write `README.md` last, after the project works.
- `data/servers.txt` is the input; `reports/` and `errors/` are output locations only.
- Do not manually create the final report file — the script creates it.
- The finished script must pass `shellcheck` with zero warnings.

## Requirements

- [ ] Accept a server data file path as an argument, with `data/servers.txt` as the default if none is given (default-value expansion, Lab 08)
- [ ] Print usage and exit `2` if the argument is malformed / help is requested incorrectly
- [ ] Exit `1` with a clear message (and log it to `errors/`) if the given file doesn't exist
- [ ] Read the file line by line and split each record into its 7 fields (pure Bash, no `awk`)
- [ ] Classify each server as HEALTHY, WARNING, or DOWN using a function with a `local`-scoped result variable
- [ ] Loop through every server and print one line per server to the report: name, status, cpu_load, health classification
- [ ] Count total HEALTHY, WARNING, and DOWN servers
- [ ] Include a timestamp in the report filename and inside the report itself
- [ ] Save the report inside the `reports/` directory
- [ ] Send script-related errors (missing file, missing argument, malformed line) to the `errors/` directory
- [ ] Handle the case where the input file exists but has zero server lines in it
- [ ] Use a `trap` on `EXIT` that always prints a final summary line, even if the script exits early due to an error
- [ ] Use a `trap` on `ERR` that logs the failing line to `errors/`
- [ ] Return a distinct, correct exit code for: missing argument, missing file, at least one DOWN server, fleet fully healthy
- [ ] Test what happens when the input file is missing
- [ ] Test what happens when the input file has malformed lines (fewer than 7 fields)
- [ ] Test what happens when the script is run more than once (report files shouldn't overwrite each other)
- [ ] Run `shellcheck` against the finished script and resolve every warning

## Success Criteria

The project is complete when:

- The script can read `data/servers.txt` (or any file passed as an argument) and correctly classify every server
- The script creates a readable, timestamped health report in `reports/`
- The report includes accurate HEALTHY/WARNING/DOWN counts and a clear overall summary
- The report includes a timestamp showing when it was generated
- The script handles missing arguments, missing files, and malformed data without a raw Bash crash
- Exit codes are correct and distinct for every tested scenario
- `shellcheck` reports zero warnings on the finished script
- I can explain how the project works, and rebuild it from scratch, without copying anyone else's answer