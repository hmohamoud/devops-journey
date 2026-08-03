# Lab 10 — Challenge (Mastery Check)

Matches `instructions.md` — Tasks 1–7 plus the Capstone. No notes, nothing looked up. If you can do all of this cleanly, cold, you've actually mastered `set -euo pipefail`, `trap`, command chaining, and `shellcheck` — not just watched them work once.

---

## Part A — Predict, Then Run (10 questions)

For each one: write down what you think will happen *before* you run it, then run it and check yourself. Don't skip the prediction — that's the actual test.

1. What happens when this runs with zero arguments?
   ```bash
   set -u
   echo "First arg: $1"
   ```

2. What does this print, and does the script keep running afterward?
   ```bash
   set -e
   ls /this/does/not/exist
   echo "after"
   ```

3. What does this print, and does the script keep running afterward — and why is the answer different from question 2?
   ```bash
   set -e
   ls /this/does/not/exist || true
   echo "after"
   ```

4. What does `echo $?` show right after this line runs, under `set -o pipefail`?
   ```bash
   set -o pipefail
   cat /nonexistent/file | grep "x" | wc -l
   ```

5. What does `echo $?` show for the same line, *without* `set -o pipefail`?

6. What prints, and in what order?
   ```bash
   trap 'echo "EXIT fired"' EXIT
   trap 'echo "ERR fired"' ERR
   set -e
   echo "start"
   false
   echo "never gets here"
   ```

7. Given this script runs successfully start to finish with no errors, does the `EXIT` trap still fire? Predict, then confirm:
   ```bash
   trap 'echo "cleaning up"' EXIT
   echo "doing work"
   ```

8. What's wrong with this chain — under what circumstance does it print the wrong message?
   ```bash
   grep "ERROR" app.log && echo "found errors" || echo "no errors"
   ```

9. Given `count=0` after a successful command that legitimately found zero matches, what happens here under `set -e`, and why?
   ```bash
   set -e
   count=$(grep -c "CRITICAL" app.log)
   echo "Critical count: $count"
   ```

10. `shellcheck` is run against this line. What warning class does it raise, and why?
    ```bash
    for f in $(ls *.log); do
      echo $f
    done
    ```

---

## Part B — Build It

One script: `bash-lab/scripts/health-check-challenge.sh`. No copy-pasting from `instructions.md` — write it from a blank file.

**Requirements:**

1. `#!/bin/bash` then `set -euo pipefail` as line two, unconditionally.
2. Accepts exactly one argument: a path to a server data file.
   - No argument → usage message, exit `2`
   - Argument given but file doesn't exist → distinct message, exit `1`
3. `trap` on `EXIT` that always prints a final summary line (servers checked, servers down) no matter how the script terminates.
4. `trap` on `ERR` that logs the failing line number to `bash-lab/logs/health-check-challenge.log`, using `>>` so previous runs aren't destroyed.
5. Loop through the file, using a `local`-scoped function to classify each server as up/down.
6. Use this exact pattern to create the log file, no `if` involved: `touch "$logfile" 2>/dev/null && echo "Log ready: $logfile" || { echo "Cannot write log file"; exit 1; }`
7. Include this exact line, counting how many servers are down: `down_count=$(grep -c ",stopped\|,failed" "$1") || down_count=0`. Test it against a file with zero down servers and confirm the script does NOT exit early — `down_count` should end up `0`, not kill the script.
8. Create at least one temp file during the run, and prove — by forcing a failure partway through — that it still gets cleaned up.
9. Run `shellcheck` against the finished script and resolve every warning until it's clean.
10. Exit `0` only when every server in the file was checked with no down servers found; otherwise exit a distinct non-zero code.

**Prove it:**
- Run with no argument — capture exit code `2`
- Run with a file that doesn't exist — capture exit code `1`, confirm the `ERR` trap logged it, confirm the `EXIT` trap still printed the summary
- Run with a real file containing at least one `stopped`/`failed` server — capture the correct non-zero code
- Run with a real file where every server is `running` — capture exit code `0`
- `shellcheck bash-lab/scripts/health-check-challenge.sh` → zero warnings

---

## Self-Check

Check nothing off unless you actually ran it and it worked, no notes open.

```
[ ] Predicted and correctly explained all 10 Part A questions
[ ] Explained why set -e didn't stop question 2's script the way you might assume, and what || true actually does differently
[ ] Explained the pipefail vs no-pipefail difference in questions 4 and 5 with the actual exit codes, not just in theory
[ ] Explained the firing order of ERR and EXIT traps in question 6
[ ] Proved question 7's claim — that EXIT fires on success too — by running it, not just answering from memory
[ ] Identified the exact failure condition that breaks question 8's && / || chain
[ ] Explained why question 9's "zero matches" scenario is dangerous under set -e, and how you'd defend against it
[ ] Named the specific shellcheck warning class in question 10 without running it first
[ ] health-check-challenge.sh handles: no argument, missing file, down servers, and all-clear — all four exit codes correct
[ ] ERR trap logs the correct line number when tested against a forced failure
[ ] EXIT trap fires and cleans up temp files even when the script fails partway through
[ ] shellcheck reports zero warnings on the finished script
[ ] I could rebuild this script from scratch tomorrow without looking at today's version
```

If every box is checked honestly — Lab 10 is mastered at the level that actually matters for the job: a script you'd trust running unattended, at 3am, with nobody watching it.