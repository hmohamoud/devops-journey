# Lab 10 — Error Handling & Production Debugging

## Objective

Close the four specific gaps left after Labs 04, 05, 07, 08, 09 — nothing else.

You must be able to:
- turn on Bash's safety net (`set -euo pipefail`) and know exactly what each of the three flags catches
- chain commands directly by exit status (`&&` / `||`) without wrapping every check in an `if`
- use `trap` to run cleanup and error-reporting code automatically, no matter how a script ends
- run `shellcheck` against a script and fix what it flags

Then assemble all four into one production-grade script using the functions, loops, validation, and logging you already know.

---

## Scenario

You're handing a script to someone else to run unattended — a cron job, a CI step, a teammate who won't read the source before running it. It has to fail loudly and safely, clean up after itself no matter what happens, and never silently continue after something has gone wrong. "It worked when I tested it" is not good enough anymore.

---

## Constraints (MANDATORY)

- Every script in this lab starts with `#!/bin/bash` followed immediately by `set -euo pipefail`
- No script is considered done until `shellcheck` reports it clean
- Do NOT guess what a flag does — predict the behavior, run it, confirm the prediction was right
- Every `trap` you write must be tested by actually forcing the condition it's supposed to catch, not just assumed to work
- Record every mistake and fix in `evidence.md`

---

## Environment Setup

```text
bash-lab/
├── data/
│   └── servers.txt
├── scripts/
└── logs/
```

Reuse `servers.txt` from Lab 08/09, or:

```bash
mkdir -p bash-lab/{data,scripts,logs}
cat > bash-lab/data/servers.txt << 'EOF'
web01,192.168.1.10,running
web02,192.168.1.11,stopped
db01,192.168.1.20,running
EOF
```

- [ ] Confirm `shellcheck` is installed: `shellcheck --version`. If missing: `brew install shellcheck`

---

## Task 1 — `set -u`

- [ ] Write a script with no `set` line that echoes an undefined variable (`echo "$undefined_var"`). Run it — note it prints nothing and keeps going.
- [ ] Add `set -u` at the top. Run again — note it now exits immediately, naming the unbound variable.
- [ ] Reference `$1` in a script with `set -u`, then run the script with zero arguments — confirm it exits before doing anything else.
- [ ] Fix that same script using `${1:-}` so it no longer crashes on a missing `$1`. Then add: `if [ -z "${1:-}" ]; then echo "Usage: $0 <arg>"; exit 2; fi`. Run it with zero args and confirm it prints the usage line and exits `2` — not a raw unbound-variable error.

Answer:
→ why does `set -u` catch bugs that would otherwise hide silently for weeks

---

## Task 2 — `set -e`

- [ ] Write a script with no `set -e` where a command fails partway through (`ls /nonexistent`), followed by `echo "still running"`. Run it — confirm execution continues past the failure.
- [ ] Add `set -e`. Run again — confirm the script now stops the instant that command fails, and the later `echo` never runs.
- [ ] Write a command you *expect* to sometimes return non-zero on purpose (e.g. `grep "pattern" file.txt` where the pattern isn't present) inside a `set -e` script. Run it — confirm the whole script exits even though this "failure" was expected, not a bug.
- [ ] Fix that specific line so an expected non-zero result doesn't kill the script, using `|| true` or an explicit `if`.

Answer:
→ name one real command whose normal, correct behavior is a non-zero exit code, and explain why blindly wrapping every command in `set -e` without exceptions is dangerous

---

## Task 3 — `set -o pipefail`

- [ ] Write a pipeline where the *first* command fails but the *last* command succeeds (e.g. `ls /nonexistent | wc -l`). Check `$?` immediately after — confirm it reports the last command's status (0), hiding the real failure.
- [ ] Add `set -o pipefail`. Run the same pipeline again — confirm `$?` now correctly reflects the earlier failure.
- [ ] Combine all three flags as `set -euo pipefail` on one line at the top of a script. Confirm this is now your default first line, right after the shebang, for every remaining script in this lab.

Answer:
→ in your own words, what does each of the three letters/words in `-euo` actually catch, and what does `pipefail` catch that the other two don't

---

## Task 5 — `trap ... EXIT`

Build `bash-lab/scripts/trap-demo.sh`.

- [ ] Build the real use case: create a temp file (`tempfile=$(mktemp)`), set trap 'rm -f "$tempfile"' EXIT right after, then force the script to exit 1 partway through. Check afterward with ls -l "$tempfile" and confirm the file is gone — cleaned up automatically, even on a forced early exit.

Answer:
→ why is `trap ... EXIT` more reliable for cleanup than putting the cleanup command at the bottom of the script

---

## Capstone — Production-Grade Health Check Script

Build `bash-lab/scripts/health-check.sh`. This is where the four new topics combine with functions, loops, validation, and logging from Labs 05–09.

**Requirements:**

1. Shebang, then `set -euo pipefail` as line two — no exceptions.
2. `trap` on both `ERR` and `EXIT`:
   - `ERR` trap logs which line failed to a timestamped log file
   - `EXIT` trap always prints a final "run complete" line and removes any temp files, regardless of how the script ends
3. `validate_args()` (Lab 09 pattern) checks argument count before anything else runs.
4. Confirm the input file exists (`-f` test, Lab 05 pattern) before reading it — exit with a specific, distinct code if it's missing.
5. Loop through `servers.txt`, classify each server as up/down using `is_running()`-style logic (Lab 09).
6. Log every result — success and failure lines both — to a timestamped file under `bash-lab/logs/` using `>>`.
7. Use this exact pattern for creating the log directory, with no `if` involved: `mkdir -p bash-lab/logs && logfile="bash-lab/logs/health-check-$(date +%Y%m%d-%H%M%S).log" || { echo "Cannot create log directory"; exit 1; }`
8. Run `shellcheck` against the finished script and get it to report completely clean.
9. Distinct, non-zero exit codes for: missing argument, missing file, and any server check failure. Exit `0` only on a fully clean run.

**Confirm:**
- Deliberately pointing the script at a missing file triggers the `ERR` trap, logs the failure, and the `EXIT` trap still fires and cleans up
- `shellcheck bash-lab/scripts/health-check.sh` reports zero warnings
- `echo $?` shows the correct, distinct code for at least three different scenarios you test by hand

---

## Break/Fix Tasks

### Break/Fix 1
```bash
set -u
echo "$1"
```
Run with no arguments. Explain what happens and fix it so a missing `$1` is handled instead of crashing the script outright.

### Break/Fix 2
```bash
set -e
result=$(some_command_that_fails)
echo "still runs"
```
`set -e` doesn't stop this script even though the command fails. Explain why, and fix it so the script actually exits.

### Break/Fix 3
```bash
grep "pattern" file.txt && echo "found" || echo "not found"
```
This has a subtle trap: if `echo "found"` itself ever failed, the `||` branch would *also* fire, printing the wrong message. Rewrite this using `if` to remove the ambiguity.

### Break/Fix 4
```bash
#!/bin/bash
set -euo pipefail
count=$(grep -c "ERROR" logs/app.log)
echo "Errors: $count"
```
This fails the entire script whenever there happen to be zero errors in the log — which should be a normal, healthy outcome, not a crash. Explain why `set -e` triggers here, and fix it.

### Break/Fix 5
```bash
trap 'echo "cleanup"' EXIT
some_command_that_might_fail
echo "done"
```
Someone claims the `EXIT` trap "only works if the script finishes normally." Prove that claim wrong with a concrete test, and explain what actually determines when an `EXIT` trap fires.

---

## Verification Checkpoints

You must be able to, without notes:

- [ ] Explain exactly what each of `-e`, `-u`, and `-o pipefail` catches, with a real example of each
- [ ] Write a safe fallback for a possibly-unset variable under `set -u`
- [ ] Identify and correctly handle a command whose normal behavior is a non-zero exit code, under `set -e`
- [ ] Chain commands with `&&`/`||` directly, and explain when that's clearer than an `if` and when it isn't
- [ ] Set both an `ERR` and an `EXIT` trap in the same script and explain the order and conditions under which each fires
- [ ] Use a trap to guarantee cleanup runs even when a script fails partway through
- [ ] Run `shellcheck` against a script and resolve every warning it raises
- [ ] Explain, out loud, why each of these four things specifically is what separates a script that works on your machine from one that's safe to hand to someone else

---

## Success Criteria

You are successful when:

- Every script you write in this lab starts with `set -euo pipefail` by default, without being told to
- You can predict, before running, whether a given command's failure will actually stop the script
- Every `trap` you write is proven by forcing the failure it's meant to catch — not assumed to work
- `shellcheck` reports zero warnings on every script you consider "done"
- You can explain the difference between this lab and everything before it in one sentence: prior labs taught you to detect and react to failure manually; this lab teaches Bash to enforce that discipline automatically

---

## Coverage Map

| Checklist Item | Covered In |
|---|---|
| `set -u` and safe unset-variable handling | Task 1, Break/Fix 1 |
| `set -e` and its exceptions | Task 2, Break/Fix 2, Break/Fix 4 |
| `set -o pipefail` | Task 3 |
| `set -euo pipefail` as a standard first line | Task 3, Capstone |
| `&&` / `||` command chaining | Task 4, Break/Fix 3 |
| `trap ... EXIT` | Task 5, Break/Fix 5 |
| `trap ... ERR` | Task 6 |
| `shellcheck` usage and remediation | Task 7 |
| Full production script assembly | Capstone |

---

## Already Covered — Not Repeated Here

- Exit codes, `$?`, `exit N` → Lab 05
- `if`/`elif`/`else`, `!`, `&&` *inside* a condition → Labs 05, 09
- `bash -x`, `set -x` / `set +x` → Lab 05
- stdout/stderr, `>`,x `>>`, `2>`, `2>&1` → Lab 04
- File/directory existence checks → Labs 05, 08
- Timestamped logging with `tee -a` → Labs 04, 07
- Functions, `local` scoping, loops, `case` → Lab 09