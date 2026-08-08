# Challenge — Integration 1: Scripting Toolkit

No notes. No copying from `design.md` or your working toolkit. This challenge has two parts: rebuild the shared foundation cold, then prove the whole toolkit actually integrates, not just runs three scripts side by side.

---

## Part A — Rebuild the Shared Foundation Cold

From a blank file, no reference to your working `lib/common.sh` or `config/toolkit.conf`.

### `config/toolkit.conf`

- [ ] Define `FLEET_FILE`, `LOG_FILE`, `REPORT_DIR`, `ERROR_DIR`, `LOG_DIR`, `TIMESTAMP_FORMAT`, `CPU_WARNING_THRESHOLD`, each using `${VAR:-default}`
- [ ] Prove that setting an environment variable before sourcing this file overrides the default, without editing the file

### `lib/common.sh`

- [ ] `timestamp()` — returns a formatted timestamp using `$TIMESTAMP_FORMAT`
- [ ] `log_error(message)` — writes a timestamped line to a file in `$ERROR_DIR`
- [ ] `log_info(message)` — prints a timestamped line to the terminal
- [ ] `validate_arg_count(actual, required)` — prints usage and returns `2` on mismatch
- [ ] `require_file(path)` — logs an error and returns `1` if the file is missing
- [ ] `require_dir(path)` — creates the directory if missing, doesn't fail

**Prove it:** write a 10-line throwaway test script that sources both files and calls every function above at least once — confirm each one behaves correctly in isolation before touching any component script.

---

## Part B — Predict, Then Run (8 questions)

Write your prediction before running each one.

1. Two scripts both source `config/toolkit.conf`. Script A runs first and does `REPORT_DIR="/tmp/override"` *after* sourcing. Does script B (run separately, in its own process) see the override?

2. `system-audit.sh` calls `require_dir("reports")` and the directory doesn't exist yet. What does the function do, and does the script continue or exit?

3. `health-check.sh` calls `require_file("$FLEET_FILE")` and the file is missing. Compare the exact error message this produces against what `log-scanner.sh` produces when `require_file("$LOG_FILE")` fails. Should these two messages differ in wording, or only in which file/variable they reference?

4. `toolkit.sh` is run as `./scripts/toolkit.sh health extra-argument`. What should happen, and where in the script does that get caught?

5. Given `config/toolkit.conf` sets `CPU_WARNING_THRESHOLD=80`, and you export `CPU_WARNING_THRESHOLD=90` before running `./scripts/toolkit.sh health` — which value does `health-check.sh` actually use, and why?

6. `EXIT` traps are set independently in each of the three component scripts, not shared from one central place. If `toolkit.sh` dispatches to `health-check.sh` using `exec`, does `toolkit.sh`'s own `EXIT` trap still fire, or does `health-check.sh`'s trap take over entirely? (Hint: think about what `exec` actually does to the running process.)

7. You delete a function from `lib/common.sh` that `log-scanner.sh` depends on, but forget to remove the call to it. What happens when you run `log-scanner.sh` directly, under `set -euo pipefail`?

8. `shellcheck` is run against `lib/common.sh` on its own (not sourced by anything). It may raise warnings about variables that look "unused" or "undefined." Why might that happen even though the functions are correct, and how do you tell `shellcheck` this file is a library, not a standalone script?

---

## Part C — End-to-End Integration Proof

This is the real test — not whether each script works, but whether the toolkit is actually integrated.

1. **The config-propagation test:** change `REPORT_DIR` in `config/toolkit.conf` to `reports-test/`. Run all three subcommands (`audit`, `logs`, `health`) through the dispatcher. Confirm all three reports land in `reports-test/`, with zero script edits. Revert the change afterward.

2. **The consistent-error test:** rename `data/servers.txt` and `data/sample-logs/app.log` temporarily (both missing at once). Run `./scripts/toolkit.sh health` and `./scripts/toolkit.sh logs` back to back. Confirm both errors land in `$ERROR_DIR`, in the same format, both produced by the same `require_file()` function — not two different hand-written checks that happen to look similar.

3. **The dispatcher-transparency test:** run `./scripts/health-check.sh` directly, capture its exact output and exit code. Then run `./scripts/toolkit.sh health`, capture its output and exit code. Confirm they're identical (aside from the dispatcher's own `EXIT` trap message, if it still fires per your answer to Part B, question 6).

4. **The permission-audit test:** temporarily `chmod -x` one script in `scripts/`. Run `./scripts/toolkit.sh audit`. Confirm `system-audit.sh` actually catches and reports the non-executable script, rather than silently ignoring it. Restore the permission afterward.

5. **The shellcheck sweep:** run `shellcheck` against every single file in `scripts/` and `lib/` in one pass (`shellcheck scripts/*.sh lib/*.sh`). Zero warnings, across all four files, at once — not fixed one at a time and never re-checked together.

---

## Self-Check

Check nothing off unless you actually ran it and it worked, no notes open.

```
Shared Foundation
[ ] Rebuilt config/toolkit.conf cold, with default-value overrides proven
[ ] Rebuilt lib/common.sh cold, all 6 functions tested in isolation

Integration Understanding
[ ] Correctly predicted and explained all 8 Part B questions
[ ] Correctly explained why config changes don't cross process boundaries (Q1)
[ ] Correctly explained exec's effect on trap ownership (Q6)
[ ] Correctly explained shellcheck's library-file warning behavior (Q8)

End-to-End Proof
[ ] Config-propagation test passed — one change, zero script edits, all 3 components affected
[ ] Consistent-error test passed — same require_file(), same format, two different missing files
[ ] Dispatcher-transparency test passed — direct run and dispatcher run produce identical results
[ ] Permission-audit test passed — system-audit.sh actually caught a real non-executable script
[ ] shellcheck sweep passed — all 4 files, zero warnings, checked together in one command

Final Standard
[ ] I could rebuild lib/common.sh and config/toolkit.conf from scratch tomorrow, no notes
[ ] I can explain, out loud, why this is an "integration" and not just three scripts in one folder
```

If every box is checked honestly, this isn't just three working scripts — it's a toolkit.