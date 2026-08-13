# Notes — Lab 10: Error Handling & Production Debugging

---

## 1. `set -e`

**`set -e`** — script stops the instant any command fails. Nothing after it runs.

---

## 2. `set -u`

**`set -u`** — script stops the instant it hits an unset/undefined or mistyped variable. Nothing after it runs.

---

## 3. `set -eu` Together

**Both together (`set -eu`)** — script stops on either: first failed command, OR first unset variable, whichever hits first.

---

## 4. `set -o pipefail`

**`set -o pipefail`** - in `cmd1 | cmd2 | cmd3`, `$?` by default shows only whether `cmd3` succeeded or failed, ignoring `cmd1` and `cmd2` completely. With pipefail, `$?` shows failure if `cmd1`, `cmd2`, OR `cmd3` fails — not just `cmd3`.

---

## 5. All Three Together — `set -euo pipefail`

**All three together (`set -euo pipefail`)** — this is the line that goes right below the shebang, in every real script, every time:
- Stops on the first failed command
- Stops on the first unset/undefined variable
- Pipeline exit codes reflect any failure in the chain, not just the last command

---

## 6. Command Chaining — `;`, `&&`, `||`

`cmd1; cmd2` — runs `cmd2` no matter what happened with `cmd1`, success or failure, always.

`cmd1 && cmd2` — only runs `cmd2` if `cmd1` succeeded. If `cmd1` failed, `cmd2` is skipped entirely.

`cmd1 || cmd2` — only runs `cmd2` if `cmd1` failed. If `cmd1` succeeded, `cmd2` is skipped entirely.

---

## 7. `trap ... EXIT` — Guaranteed Cleanup

**The succinct version:** `trap ... EXIT` means *"no matter what happens, do this on the way out."*

It fires every single time the script ends — success, failure, `exit 1`, even Ctrl+C. It's your guaranteed cleanup/summary, because you can't predict every way a script might die, but you can guarantee this one thing always runs.

**The rule:** without `trap`, cleanup only happens if the script actually reaches that line. With `trap`, cleanup happens no matter what — success or failure, anywhere in the script.

**Without trap (works, but only if nothing fails first):**
```bash
tempfile=$(mktemp)
echo "doing work with $tempfile"
rm -f "$tempfile"    # only runs if execution actually gets here
```
File created, used, deleted. Fine — as long as nothing above this line crashes the script.

**With trap (armed early, fires no matter what happens later):**
```bash
tempfile=$(mktemp)                    # 1. temp file created
trap 'rm -f "$tempfile"' EXIT          # 2. trap registered — armed and waiting
ls fakefolder                          # 3. this fails — unrelated to trap
echo "$tempfile"                       # 4. never reached
```
Even though line 3 fails and the script dies right there, the trap still fires and deletes the temp file — because it was already armed before the failure happened.

**The actual question trap answers:** "no matter which later line ends up failing — and I can't predict which one it'll be — will my temp file still get cleaned up?" With `trap`, the answer is always yes, regardless of where in the script something eventually breaks.

---

## 8. `trap ... ERR` — Catches the Failure at the Moment It Happens

**The succinct version:** `trap ... ERR` means *"the moment something goes wrong, do this."*

It fires only when a command actually fails (under `set -e`). It's your failure logger — it catches the exact moment of breakage, before the script even finishes exiting.

**The rule:** `ERR` fires immediately, right when a command fails — before the script has actually finished exiting. It tells you *what broke and where*, not just *that* something ended.

**Basic example:**
```bash
trap 'echo "Error on line $LINENO"' ERR

echo "starting script"
ls /nonexistent                          # this fails
echo "this never runs"
```
The moment `ls /nonexistent` fails, `Error on line 4` prints — right there, before the script actually stops (via `set -e`).

**`ERR` and `EXIT` together, and the order they fire in:**
```bash
trap 'echo "Error on line $LINENO"' ERR
trap 'echo "Script exiting"' EXIT

echo "starting script"
ls /nonexistent
echo "this never runs"
```
Output:
```
starting script
Error on line 4
Script exiting
```
`ERR` always fires first (right at the failure). `EXIT` always fires last (once the script is actually done shutting down). The script can't finish exiting before the failure that caused it happens — so this order is guaranteed, never reversed.

**The actual question `ERR` answers:** "the instant something fails, tell me exactly what broke and on which line — before the script disappears." `$LINENO` gives you the precise line number of the command that failed, which is the whole point — pinpointing the failure, not just knowing a failure happened somewhere.

---

## 9. The Two-Line Summary — Memorize This

- **`EXIT` = "we're leaving, wrap it up."** Fires on the way out, every time, no matter how the script got there.
- **`ERR` = "something just broke, log it."** Fires at the exact moment of failure, before the script has even finished exiting.

Put together: **ERR catches the failure. EXIT closes the door — every time, no matter how you left.**

---

## 10. `set` + `trap` vs `shellcheck`

`set -euo pipefail` and `trap` (both `EXIT` and `ERR`) are the main production safety feature.

ShellCheck is just an additional quality check.

You write `shellcheck` on the terminal when running the script.

---

## Quick-Reference Summary

- `set -e` — stops the instant any command fails.
- `set -u` — stops the instant it hits an unset/undefined or mistyped variable.
- `set -eu` — stops on either, whichever hits first.
- `set -o pipefail` — `$?` reflects failure anywhere in a pipeline, not just the last command.
- `set -euo pipefail` — all three combined, right below the shebang, every script, every time.
- `;` — always runs the next command regardless. `&&` — only runs the next command on success. `||` — only runs the next command on failure.
- `trap ... EXIT` — "no matter what happens, do this on the way out." Guaranteed cleanup/summary, fires no matter how the script ends (success, failure, `exit 1`, even Ctrl+C).
- `trap ... ERR` — "the moment something goes wrong, do this." Fires only on an actual command failure, before `EXIT` fires; always fires before `EXIT`, never after.
- `set`/`trap` = main production safety feature (runtime behavior). `shellcheck` = additional quality check (run from the terminal against the script itself).