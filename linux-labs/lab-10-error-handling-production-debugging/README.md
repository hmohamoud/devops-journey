# Lab 10 — Error Handling & Production Debugging

**Environment:** macOS Sequoia | Zsh | VS Code Terminal | Apple Silicon (M-series)

---

## Problem

> "You're handing a script to someone else to run unattended — a cron job, a CI step, a teammate who won't read the source before running it. It has to fail loudly and safely, clean up after itself no matter what happens, and never silently continue after something has gone wrong. 'It worked when I tested it' is not good enough anymore."

Every script in this lab starts with `#!/bin/bash` followed immediately by `set -euo pipefail`. No script is considered done until `shellcheck` reports it clean. Every `trap` has to be proven by actually forcing the failure it's meant to catch, not assumed to work.

Needed to close four specific gaps left after Labs 04, 05, 07, 08, and 09:

- Bash's safety net (`set -euo pipefail`) and exactly what each of the three flags catches
- chaining commands directly by exit status (`&&` / `||`) without wrapping every check in an `if`
- `trap` for cleanup and error-reporting that runs automatically, no matter how a script ends
- `shellcheck`, run against a script to catch what a human eye misses

Then assembling all four into one production-grade script using the functions, loops, validation, and logging already built in earlier labs.

---

## What I Built

```text
bash-lab/
├── data/
│   └── servers.txt
├── scripts/
│   ├── trap-demo.sh
│   ├── health-check.sh
│   └── health-check-challenge.sh
├── logs/
├── notes.md
├── evidence.md
└── README.md
```

Worked through `set -u`, `set -e`, and `set -o pipefail` in isolation first — proving each one's specific failure mode by deliberately triggering it before and after the flag was active — then `trap ... EXIT` and `trap ... ERR` together, then closed with a from-scratch, closed-book capstone (`health-check-challenge.sh`) combining everything.

---

## How I Solved It

**`set -u` (Task 1):** Confirmed an unset variable silently prints nothing and lets the script keep running with no `set` line active. Added `set -u` and watched the exact same script die immediately, naming the unbound variable. Applied this specifically to a missing `$1`, then fixed the crash using `${1:-}` combined with an explicit `-z` check — proving the difference between "the script crashes" and "the script fails cleanly with a usage message."

**`set -e` (Task 2):** Proved a failing command (`ls /nonexistent`) doesn't stop a script by default — execution just continues to whatever comes next. Adding `set -e` changed that immediately. Then deliberately hit the opposite problem: a command whose non-zero exit is *expected*, not a bug (`grep` finding no match), and confirmed `set -e` kills the script over it anyway unless explicitly told not to, via `|| true` or an `if`.

**`set -o pipefail` (Task 3):** Built a pipeline where the first command fails but the last succeeds (`ls /nonexistent | wc -l`), and confirmed `$?` reports success — completely hiding the real failure — without `pipefail`. Adding it changed `$?` to correctly reflect the earlier failure. Locked in `set -euo pipefail` as the standard first line for every remaining script in the lab.

**Command chaining (`&&`/`||`):** Rewrote an `if`/`else` file check as a one-line `&&`/`||` chain and confirmed identical behavior and exit codes against a missing file. Then deliberately tried to force a genuine three-outcome check (running/stopped/failed) into a chain with no `if` at all, and confirmed it becomes unreadable or breaks — the concrete proof behind "chains are for two outcomes max."

**`trap ... EXIT` (Task 5):** Proved the trap fires on a completely normal, successful run — not just failures. Then forced an early `exit 1` partway through and confirmed the trap *still* fired. Built the real use case: a temp file created with `mktemp`, a trap set immediately after to remove it, and a forced failure afterward — confirmed the file was gone even though the script never reached its natural end.

**`trap ... ERR`:** Combined `set -e` with an `ERR` trap using `$LINENO`, forced a failure partway through a script, and confirmed the `ERR` trap fired at the exact point of failure — before the script actually exited. Ran both an `ERR` and `EXIT` trap together and confirmed the firing order is fixed: `ERR` always first, `EXIT` always last, because the script can't finish exiting before the failure that triggered it has already happened.

**`shellcheck`:** Ran it against an existing script from an earlier lab that had never been linted, and read through what it flagged. Deliberately wrote a small script with an unquoted loop variable (`for f in $files`) and confirmed `shellcheck` catches the exact mistake already learned the hard way in Labs 08/09. Took one real script and iterated on it until `shellcheck` reported zero warnings.

**Capstone (`health-check.sh` / `health-check-challenge.sh`):** Combined every piece — `set -euo pipefail`, `validate_args()` from Lab 09, an `-f` file-existence check from Lab 05, `ERR`/`EXIT` traps (log + cleanup + summary), a `local`-scoped `is_running()` classification function, `>>`-appended timestamped logging, and distinct exit codes for missing args, missing file, servers down, and a fully clean run. Full write-up and both drafts (first attempt + corrected final) are in `evidence.md`.

---

## Break/Fix Summary

| Issue | Cause | Fix |
|---|---|---|
| `set -u` script crashed with "unbound variable" on `$1` | zero arguments passed, `$1` never assigned | `${1:-}` combined with an explicit `-z` usage check |
| `set -e` script didn't stop after a failing command | the failing command was hidden inside a captured `$(...)` in a way that masked the exit status in an early draft | isolate the command, check its exit status directly |
| Script died on a legitimate zero-match `grep -c` | `grep -c` returns non-zero when it finds nothing, and `set -e` treats that as a real failure | `count=$(grep -c ...) || count=0` |
| `&&`/`||` chain printed the wrong branch under an edge case | the chain can't distinguish "the first command failed" from "the second command failed" | rewrite with explicit `if`/`else` |
| Pipeline reported success despite an early failure | no `pipefail`, so `$?` only reflected the last command in the chain | `set -o pipefail` |
| Cleanup code at the bottom of a script never ran on a forced early exit | it was just a plain line, only reached if execution got there | `trap 'rm -f "$tempfile"' EXIT`, registered immediately after the temp file is created |
| Traps registered too late in a draft script | validation/setup logic ran before the traps were set, so an early failure in that logic wouldn't be caught | move `trap` registration to immediately after creating whatever needs tracking/cleanup |

---

## Key Snippets

```bash
# the standard first line, every script, no exceptions
#!/bin/bash
set -euo pipefail

# safe fallback for a possibly-unset variable
name="${1:-}"
if [ -z "$name" ]; then
    echo "Usage: $0 <arg>"
    exit 2
fi

# defending against an expected non-zero result under set -e
count=$(grep -c "pattern" file.txt) || count=0

# guaranteed cleanup, armed before anything risky runs
tempfile=$(mktemp)
trap 'rm -f "$tempfile"' EXIT

# catching the exact failing line, before the script exits
trap 'echo "Error on line $LINENO" >> "$logfile"' ERR

# creating a log directory with no if involved
mkdir -p bash-lab/logs && logfile="bash-lab/logs/health-check-$(date +%Y%m%d-%H%M%S).log" || { echo "Cannot create log directory"; exit 1; }
```

---

## Improvements After Completion

- Learned that Bash's default behavior is to keep running after almost any failure — `set -e`, `set -u`, and `pipefail` all exist to convert that silent default into an immediate, loud stop, and none of them are optional for a script anyone else will run unattended.
- Learned that `set -e` has real, necessary exceptions — a command whose normal, correct behavior includes a non-zero exit code (like `grep` finding nothing) has to be deliberately exempted, or the script becomes unreliable in exactly the situations it was supposed to handle gracefully.
- Learned that `&&`/`||` chaining is genuinely useful for two-outcome checks but actively misleading once a third outcome enters the picture — the chain can't tell you *which* earlier command failed, only that *something* did.
- Learned that `trap` only protects what happens *after* it's registered — placement matters, and the temptation to set it up last (after the "important" logic) defeats its entire purpose.
- Learned that `shellcheck` catches, mechanically and instantly, an entire category of mistakes that took multiple labs' worth of break/fix exercises to learn by hand — it's not a replacement for understanding the bugs, but it's a permanent safety net once you do.

---

## Key Takeaway

Before this lab, I could write a script that correctly detected and reacted to failure — but only if I remembered to check for it, every single time, by hand.

After this lab, Bash itself enforces that discipline automatically: a failing command, an unset variable, a masked pipeline failure, or a script that dies partway through — all of them now get caught and handled correctly by default, not because I remembered to add a check, but because the safety net was already there.

The three questions that mattered on every single task in this lab:

1. If this specific command fails, does the script actually know about it — and does it react correctly?
2. Is this "failure" actually expected/healthy, or a real problem — and have I told the script the difference?
3. If this script dies partway through, unplanned, does everything it's responsible for still end up in a correct, cleaned-up state?

That is the difference between a script that works when you test it, and a script that's safe to hand to someone else to run at 3am with nobody watching.