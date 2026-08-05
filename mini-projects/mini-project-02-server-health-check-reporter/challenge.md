# Challenge — Server Health Check Reporter

No notes. No copying from `design.md` or `instructions.md`. Build from a blank file, test every path yourself.

---

## Part A — Predict, Then Run (8 questions)

Write your prediction before running each one.

1. What does this print, given `status="running"` and `cpu_load="97"`?
   ```bash
   if [ "$status" == "running" ] && [ "$cpu_load" -ge 80 ]; then
     echo "WARNING"
   elif [ "$status" == "running" ]; then
     echo "HEALTHY"
   else
     echo "DOWN"
   fi
   ```

2. Given no argument was passed to the script, what does `input_file` end up as here?
   ```bash
   input_file="${1:-data/servers.txt}"
   echo "$input_file"
   ```

3. What happens when this line is fed a malformed record with only 5 fields instead of 7?
   ```bash
   IFS=, read -r name ip status port service cpu_load uptime_days <<< "web09,192.168.1.99,running,8080,nginx"
   echo "cpu_load=[$cpu_load] uptime_days=[$uptime_days]"
   ```

4. Under `set -euo pipefail`, what happens here if `grep` finds zero matches?
   ```bash
   set -euo pipefail
   down_count=$(grep -c ",stopped\|,failed" data/servers.txt)
   echo "$down_count"
   ```

5. What's wrong with this trap, and what will actually happen when the script exits normally (no error)?
   ```bash
   trap 'echo "cleaning up after failure"' ERR
   echo "doing work"
   exit 0
   ```

6. Given `healthy=2 warning=1 down=0`, what should the exit code be per this project's design, and why?

7. Given `healthy=0 warning=0 down=0` (empty file, zero valid lines), what should the report say instead of an empty table?

8. Two runs happen back to back with report filenames based on `$(date +%Y-%m-%d_%H-%M-%S)`. What has to be true about the timestamps for neither report to overwrite the other — and what happens if both runs land in the same second?

---

## Part B — Build It Cold

Build `scripts/health-check-challenge.sh` from scratch. Don't open your existing `health-check.sh` while doing this.

**Requirements:**

1. `#!/bin/bash` then `set -euo pipefail`
2. Default the input file to `data/servers.txt` using a default-value expansion if no argument is given
3. Exit `1` with a message logged to `errors/` if the file doesn't exist or is empty
4. Parse each line into its 7 fields using pure Bash (`while IFS=, read -r ...`)
5. Skip and log any line that doesn't produce all 7 non-empty fields — don't crash, don't include it in the report
6. A `classify_health()` function using a `local` result variable, called once per valid server
7. A per-server report line: name, status, cpu_load, classification
8. Running counts of HEALTHY, WARNING, DOWN
9. `trap` on `EXIT` that always prints a one-line summary
10. `trap` on `ERR` that logs the failing line number to `errors/`
11. Correct, distinct exit codes: `0` clean, `1` missing/empty file or any DOWN server, `2` invalid usage
12. `shellcheck scripts/health-check-challenge.sh` reports zero warnings

**Prove it — run all of these and capture the result:**
- No argument, `data/servers.txt` exists and is healthy → exit `0`
- A file path that doesn't exist → exit `1`, error logged, summary still printed
- An empty file → "no servers found" path, exit `1`
- A file with one malformed line and two valid lines → malformed line logged and skipped, two valid lines still processed correctly
- A file with at least one `stopped`/`failed` server → exit `1`, correct DOWN count
- Run it twice back to back → two separate report files, both present, correctly timestamped

---

## Self-Check

```
[ ] Predicted and correctly explained all 8 Part A questions
[ ] Explained why question 4's grep -c with zero matches is dangerous under set -e, and how the real script defends against it
[ ] Explained why question 5's trap doesn't do what it looks like it does
[ ] health-check-challenge.sh built cold, no reference to the original script
[ ] All 6 Part B proof scenarios captured with correct exit codes
[ ] Malformed-line handling proven, not just assumed
[ ] EXIT trap proven to fire on both success and forced failure
[ ] shellcheck reports zero warnings
[ ] I could rebuild this again tomorrow from a blank file, no notes
```

If every box is checked honestly, Mini Project 2 is done at the level that actually matters — a script you'd trust running unattended.