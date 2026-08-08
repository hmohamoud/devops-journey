# Evidence — Integration 1: Scripting Toolkit

Real design decisions and fixes from spec-writing so far, plus test slots to fill in with real captured output once every component script is actually built and run.

---

## Design Decisions (with real reasoning, not hypothetical)

### Decision 1 — `require_file()` and `log_error()` don't call `exit`
**The question:** should shared functions in `lib/common.sh` handle failures completely on their own (check, log, and exit), or only check and report, leaving the exit decision to the caller?

**The decision:** functions only check and report. `require_file()` returns a non-zero code; the calling script's own `if` decides whether that means `exit 1`.

**Why:** if the shared function forced an exit, every component script using it would be locked into identical failure behavior with no flexibility, even though `health-check.sh` and `log-scanner.sh` could reasonably want to react differently in the future.

---

### Decision 2 — `EXIT` trap prints to terminal, report counts go to file
**The question:** should `health-check.sh`'s completion summary write into the report file (since it already writes there) or print to the terminal?

**The decision:** terminal, matching MP2's final corrected behavior.

**Why:** the trap's purpose is a live confirmation for whoever is watching the run (cron/CI), separate from the permanent record in the report file. Carried over directly from MP2's Error 13 fix.

---

### Decision 3 — `health-check.sh`'s input source changed from `$1` to `config/toolkit.conf`
**The question:** MP2's script took the fleet file path as `${1:-data/servers.txt}`. Should the toolkit version keep that, or move it to config?

**The decision:** moved to `$FLEET_FILE` from config, script now takes no arguments.

**Why:** makes it consistent with `log-scanner.sh` (also argument-free, also config-driven), and lets the dispatcher call every component the same simple way without needing to know or forward different arguments per subcommand.

---

### Decision 4 — Dispatcher uses `exec`, not a plain call
**The question:** should `toolkit.sh` call the component scripts normally, or with `exec`?

**The decision:** `exec`.

**Why:** `exec` replaces the dispatcher's own process with the component script, so the component's real exit code becomes the dispatcher's exit code directly, with no intermediate step that could rewrite it — and avoids both the dispatcher's and the component's `EXIT` traps trying to fire independently.

---

### Decision 5 — Original `instructions.md` was too ambiguous to code against directly
**What was broken:** early drafts said things like "checks these directories exist" without specifying the exact function contract, exact defaults, or exact edge-case behavior.

**The fix:** rewrote every section of `instructions.md` with literal function signatures, literal default values, and step-by-step build order for each script (see `system-audit.sh`'s section specifically — rebuilt into 9 explicit steps).

---

## Commands Executed

```bash
mkdir -p integration-01-scripting-toolkit/{config,lib,data/sample-logs,scripts,reports,errors,logs}
touch config/toolkit.conf lib/common.sh
touch scripts/{toolkit.sh,system-audit.sh,log-scanner.sh,health-check.sh}
chmod +x scripts/*.sh
```

`toolkit.sh` has been written in full (see `scripts/toolkit.sh`). `config/toolkit.conf`, `lib/common.sh`, `system-audit.sh`, `log-scanner.sh`, and `health-check.sh` are still to be written.

---

## Test Results

Fill in with real captured output once every script is built. This section is intentionally empty of results right now — nothing here should be filled in until it's actually been run.

### Test 1 — `./scripts/toolkit.sh` with no subcommand
**Command:**
**Expected:** usage message, exit `2`
**Actual output:**
**Pass/Fail:**

### Test 2 — `./scripts/toolkit.sh badcommand`
**Command:**
**Expected:** usage message, exit `2`
**Actual output:**
**Pass/Fail:**

### Test 3 — `./scripts/toolkit.sh audit`
**Command:**
**Expected:** directory/permission/file-inventory report generated in `reports/`
**Actual output:**
**Pass/Fail:**

### Test 4 — `./scripts/toolkit.sh logs`
**Command:**
**Expected:** log scan report generated, counts correct
**Actual output:**
**Pass/Fail:**

### Test 5 — `./scripts/toolkit.sh health`
**Command:**
**Expected:** health report generated, counts correct, correct exit code
**Actual output:**
**Pass/Fail:**

### Test 6 — Config-propagation test
**Change made:** `REPORT_DIR` in `config/toolkit.conf`
**Command:**
**Expected:** all three components write reports to the new location, zero script edits
**Actual output:**
**Pass/Fail:**

### Test 7 — Consistent-error test
**Setup:** `data/servers.txt` renamed temporarily
**Command:**
**Expected:** error format from `health-check.sh` matches `log-scanner.sh`'s error format for its own missing file, same `require_file()` function
**Actual output:**
**Pass/Fail:**

### Test 8 — Dispatcher-transparency test
**Direct run output/exit code:**
**Dispatcher run output/exit code:**
**Identical?:**

### Test 9 — `EXIT` trap fires on early exit
**Command:**
**Actual output:**
**Pass/Fail:**

### Test 10 — `ERR` trap logs correct line number
**Command:**
**Actual output:**
**Pass/Fail:**

### Test 11 — `shellcheck` sweep
**Command:** `shellcheck scripts/*.sh lib/*.sh`
**Warnings before:**
**Warnings after:**

---

## Error Fixes

To be filled in as real bugs are hit while writing `config/toolkit.conf`, `lib/common.sh`, `system-audit.sh`, `log-scanner.sh`, and `health-check.sh`. Format:

### Error N
**What I tried:**
**What happened:**
**Why it happened:**
**How I fixed it:**

---

## Proof of Completion

- [ ] `toolkit.sh` written and matches the dispatcher spec exactly
- [ ] `config/toolkit.conf` written, all 7 variables present, override tested
- [ ] `lib/common.sh` written, all 6 functions tested in isolation
- [ ] `system-audit.sh` built following all 9 steps from `instructions.md`
- [ ] `log-scanner.sh` built and passing its own requirements
- [ ] `health-check.sh` refactored from MP2 into the shared-library pattern
- [ ] All 11 tests above run with real captured output
- [ ] `shellcheck scripts/*.sh lib/*.sh` reports zero warnings in one combined run
- [ ] I can explain every design decision above without notes