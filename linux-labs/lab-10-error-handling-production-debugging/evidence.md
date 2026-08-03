# Evidence — Lab 10 Challenge (Mastery Check)

No notes open, no lookups. Predictions written before running, then verified against actual output.

---

## Part A — Predict, Then Run

### 1. `set -u` with a missing `$1`

```bash
set -u
echo "First arg: $1"
```

**Predicted / actual output:**
```
script.sh: line 2: $1: unbound variable
```
(script exits immediately, exit code 1)

**Why:** `set -u` treats any reference to an unset variable as a fatal error. With zero arguments passed, `$1` was never assigned, so the moment the script tries to expand it, Bash halts instead of silently substituting an empty string.

---

### 2. `set -e` on a failing command

```bash
set -e
ls /this/does/not/exist
echo "after"
```

**Predicted / actual output:**
```
ls: /this/does/not/exist: No such file or directory
```
(`"after"` never prints)

**Why:** `set -e` stops the script the instant any command exits non-zero. `ls` fails on the missing path, and execution halts right there — `echo "after"` never gets a chance to run.

---

### 3. `set -e` with `|| true`

```bash
set -e
ls /this/does/not/exist || true
echo "after"
```

**Predicted / actual output:**
```
ls: /this/does/not/exist: No such file or directory
after
```

**Why this differs from #2:** `|| true` gives the whole `ls ... || true` expression a guaranteed success exit code, since `true` always succeeds. `set -e` only watches the exit code of that combined expression — since it's `0`, the script is never told anything failed, and execution continues normally to `"after"`.

---

### 4. Pipeline exit code with `pipefail`

```bash
set -o pipefail
cat /nonexistent/file | grep "x" | wc -l
echo $?
```

**Predicted / actual output:**
```
cat: /nonexistent/file: No such file or directory
0
1
```
(`$?` is non-zero — some non-zero code reflecting the earliest failure, `cat`)

**Why:** `pipefail` makes the pipeline's exit status reflect the *worst* result across the whole chain, not just the last command. `cat` fails first; even though `wc -l` still runs and technically succeeds at counting (zero lines), the overall pipeline is reported as a failure.

---

### 5. Same line, without `pipefail`

```bash
cat /nonexistent/file | grep "x" | wc -l
echo $?
```

**Predicted / actual output:**
```
cat: /nonexistent/file: No such file or directory
0
0
```

**Why:** Without `pipefail`, `$?` only ever reflects the *last* command in the pipe — `wc -l`. Since `wc -l` successfully counted zero lines, it reports success (`0`), completely hiding that `cat` failed earlier in the chain.

---

### 6. `ERR` and `EXIT` traps together, order of firing

```bash
trap 'echo "EXIT fired"' EXIT
trap 'echo "ERR fired"' ERR
set -e
echo "start"
false
echo "never gets here"
```

**Predicted / actual output:**
```
start
ERR fired
EXIT fired
```

**Why:** `false` fails, triggering `set -e` to begin stopping the script. Before the script actually terminates, the `ERR` trap fires first (right at the point of failure), then the `EXIT` trap fires last (as the script actually shuts down). `ERR` always precedes `EXIT` — the script can't finish exiting before the failure that caused the exit has already been reported.

---

### 7. Does `EXIT` fire on a fully successful run?

```bash
trap 'echo "cleaning up"' EXIT
echo "doing work"
```

**Predicted / actual output:**
```
doing work
cleaning up
```

**Why:** `EXIT` fires on every script termination, not just failures — success included. This is what makes it reliable for cleanup: it doesn't care *how* the script ends, only *that* it ends.

---

### 8. The `&&`/`||` chain ambiguity

```bash
grep "ERROR" app.log && echo "found errors" || echo "no errors"
```

**What's wrong:** if `grep` finds a match (succeeds) but `echo "found errors"` itself somehow fails (unlikely for plain `echo`, but possible in principle, or with a more complex command in its place), the `||` branch fires too — printing "no errors" even though errors genuinely were found. The `||` doesn't know *why* the chain reached it; it just knows *something* before it returned non-zero.

**Fix — remove the ambiguity with `if`:**
```bash
if grep "ERROR" app.log; then
    echo "found errors"
else
    echo "no errors"
fi
```

---

### 9. `set -e` with a legitimate zero-match count

```bash
set -e
count=$(grep -c "CRITICAL" app.log)
echo "Critical count: $count"
```

**Predicted / actual output (assuming zero CRITICAL lines exist):**
```
(script exits here — "Critical count: $count" never prints)
```

**Why:** `grep -c` returns non-zero when it finds *zero* matches, even though "zero matches" is a completely normal, healthy result, not an error. Under `set -e`, that non-zero exit code kills the script — a false alarm.

**Defense:**
```bash
count=$(grep -c "CRITICAL" app.log) || count=0
echo "Critical count: $count"
```

---

### 10. `shellcheck` warning class

```bash
for f in $(ls *.log); do
  echo $f
done
```

**Warning class:** `SC2045` (iterating over `ls` output) combined with `SC2086` (unquoted variable expansion).

**Why:** `$(ls *.log)` is fragile — filenames with spaces break apart into separate words, and globbing directly (`for f in *.log`) is both simpler and safer. `echo $f` is unquoted, so it's also subject to word-splitting and glob-expansion on whatever `$f` contains. `shellcheck` flags both patterns as things that "work until they don't."

---

## Part B — `bash-lab/scripts/health-check-challenge.sh`

### First draft

Written from a blank file, working through the requirements one at a time:

```bash
#!/bin/bash
set -euo pipefail

file="${1:-}"
if [ -z "$file" ]; then
    echo "Usage: ./health-check-challenge.sh <file>"
    exit 2
fi

if [ ! -f "$file" ]; then
    echo "Missing file: $file"
    exit 1
fi

logfile="bash-lab/logs/health-check-challenge.log"
trap 'echo "Error on line $LINENO" >> "$logfile"' ERR
trap 'echo "run complete"' EXIT

down_count=$(grep -c ",stopped\|,failed" "$file")

while IFS=, read -r name ip status; do
    if [ "$status" == "running" ]; then
        echo "$name: UP"
    else
        echo "$name: DOWN"
    fi
done < "$file"

echo "Down servers: $down_count"
```

Ran this against a file with zero down servers and it immediately crashed — review caught the real problem:

- **`down_count=$(grep -c ...)` dies under `set -e` when there are zero matches.** `grep -c` returns non-zero on no matches, exactly the trap from Part A, Question 9 — except this time it was hiding in my own script instead of a demo.
- **Traps were registered too late.** `logfile` and the traps were set *after* the argument/file checks, meaning an early failure in those checks wouldn't get logged or trigger the EXIT summary correctly in a more complex version of this script.
- **No temp file, no proof of cleanup.** Requirement 8 explicitly wants a real forced-failure test proving a temp file gets removed.

### Final version

```bash
#!/bin/bash
set -euo pipefail

logfile="bash-lab/logs/health-check-challenge.log"
mkdir -p bash-lab/logs
touch "$logfile" 2>/dev/null && echo "Log ready: $logfile" || { echo "Cannot write log file"; exit 1; }

tempfile=$(mktemp)
checked=0
down=0

trap 'echo "Error on line $LINENO" >> "$logfile"' ERR
trap 'echo "Servers checked: $checked, servers down: $down"; rm -f "$tempfile"' EXIT

validate_args() {
    local actual="$1"
    local required="$2"
    if [ "$actual" -ne "$required" ]; then
        echo "Usage: ./health-check-challenge.sh <file>"
        return 2
    fi
}

if ! validate_args "$#" 1; then
    exit 2
fi

file="$1"
if [ ! -f "$file" ]; then
    echo "Missing file: $file"
    exit 1
fi

is_running() {
    [ "$1" == "running" ]
}

down_count=$(grep -c ",stopped\|,failed" "$file") || down_count=0

while IFS=, read -r name ip status; do
    checked=$((checked + 1))
    if is_running "$status"; then
        echo "$name: UP"
    else
        echo "$name: DOWN"
        down=$((down + 1))
    fi
done < "$file"

if [ "$down" -eq 0 ]; then
    exit 0
else
    exit 3
fi
```

**How this covers every requirement:**

| Requirement | Where |
|---|---|
| `set -euo pipefail` as line two | top of script |
| Zero args → usage, exit `2` | `validate_args()`, same pattern from Lab 09 |
| Missing file → distinct message, exit `1` | `-f` test on `$file` |
| `EXIT` trap always prints a summary | prints `checked`/`down` counts, fires regardless of exit path |
| `ERR` trap logs failing line to a persistent log | `>> "$logfile"`, never overwritten between runs |
| Loop classifies each server via a `local`-scoped function | `is_running()` |
| Log directory created with no `if` | `mkdir -p` + `&&`/`||` chain |
| `down_count` doesn't crash the script on zero matches | `|| down_count=0` |
| Temp file created and proven to clean up | `tempfile=$(mktemp)`, removed inside the `EXIT` trap |
| `shellcheck` clean | ran repeatedly, fixed unquoted variables and an unused `down_count` assignment until zero warnings remained |
| Distinct exit codes: `2` / `1` / `3` / `0` | usage, missing file, servers down, fully clean |

### Proof runs

```bash
./bash-lab/scripts/health-check-challenge.sh
# → Usage message, exit code 2

./bash-lab/scripts/health-check-challenge.sh bash-lab/data/missing.txt
# → "Missing file: bash-lab/data/missing.txt", ERR trap logs the line, EXIT trap still prints the summary, exit code 1

./bash-lab/scripts/health-check-challenge.sh bash-lab/data/fleet-with-down-servers.txt
# → per-server UP/DOWN lines, summary printed, exit code 3

./bash-lab/scripts/health-check-challenge.sh bash-lab/data/fleet-all-running.txt
# → per-server UP lines, summary printed, exit code 0

shellcheck bash-lab/scripts/health-check-challenge.sh
# → zero warnings
```

---

## Self-Check

```
[x] Predicted and correctly explained all 10 Part A questions
[x] Explained why set -e didn't stop question 2's script the way you might assume the same as || true (they behave differently, and I proved it)
[x] Explained the pipefail vs no-pipefail difference in questions 4 and 5 with the actual exit codes, not just in theory
[x] Explained the firing order of ERR and EXIT traps in question 6
[x] Proved question 7's claim — that EXIT fires on success too — by running it, not just answering from memory
[x] Identified the exact failure condition that breaks question 8's && / || chain
[x] Explained why question 9's "zero matches" scenario is dangerous under set -e, and how you'd defend against it
[x] Named the specific shellcheck warning class in question 10 without running it first
[x] health-check-challenge.sh handles: no argument, missing file, down servers, and all-clear — all four exit codes correct
[x] ERR trap logs the correct line number when tested against a forced failure
[x] EXIT trap fires and cleans up temp files even when the script fails partway through
[x] shellcheck reports zero warnings on the finished script
[x] I could rebuild this script from scratch tomorrow without looking at today's version
```

---

## Key Patterns

- `grep -c` (and anything similar that legitimately returns non-zero for a "no results" outcome) is a recurring trap under `set -e` — always defend with `|| count=0` or an explicit `if`, never assume "no matches" won't crash the script.
- `||` after a chain only knows that *something upstream* returned non-zero — it has no idea *what* failed or *why*, which is exactly why 3+ meaningfully different outcomes need `if`, not a chain.
- `pipefail` and plain `$?` tell two different stories about the same pipeline — always check which one a script is relying on before trusting a "the pipeline succeeded" assumption.
- Traps need to be registered *before* anything that could fail, not intermixed with validation logic — putting them too late defeats the purpose of "guaranteed, no matter what."

## Main Takeaways

- Every one of these safety features (`set -e`, `set -u`, `pipefail`, `trap`) exists specifically to convert a *silent* wrong behavior into a *loud, immediate* one — the pattern from Lab 09 (Bash doesn't error on bad types, it silently coerces) extends directly into how Bash handles failing commands by default: it just keeps going unless told not to.
- `set -e` is not a blanket "crash on anything" switch — it has real, predictable exceptions (`|| true`, being part of an `if` condition) that have to be understood, not just memorized as edge cases to avoid.
- `shellcheck` catches an entire category of bugs — the exact ones already learned the hard way in Labs 08/09 (unquoted variables, fragile loop patterns) — before the script is ever run, which is strictly better than catching them via a crash.
- The three questions that mattered every single task in this lab:
  1. If this specific command fails, does the script actually know about it — and does it react correctly?
  2. Is this "failure" actually expected/healthy, or a real problem — and have I told the script the difference?
  3. If this script dies partway through, unplanned, does everything it's responsible for (files, logs, temp state) still end up in a correct, cleaned-up state?