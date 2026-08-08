# Notes — Integration 1: Scripting Toolkit

Real concepts worked through while designing and building this, in my own words.

---

## Config File Fundamentals

**Uppercase naming convention.** Variables in config files are usually defined in uppercase to make configuration/global values easier to identify and distinguish from normal script variables. This is why `config/toolkit.conf` uses `FLEET_FILE`, `REPORT_DIR`, `CPU_WARNING_THRESHOLD`, etc. — all caps — while ordinary local variables inside a script (like `name`, `status`, `count`) stay lowercase. Seeing an uppercase variable anywhere in a script is an instant visual signal: "this came from config, not from local logic."

**Why config files don't have a shebang.** Config files do not use `#!/bin/bash` because they only store variables. `#!/bin/bash` is only for executable scripts that you run directly. `config/toolkit.conf` is never run on its own (`./config/toolkit.conf` would make no sense) — it's only ever `source`d into another script's existing process. A shebang line has no purpose there.

**What `${VAR:-default}` actually means.** `${VAR:-default}` → use `VAR` if it already has a value; otherwise use `default`. This is the exact mechanism that makes `config/toolkit.conf` overridable without editing the file — if `CPU_WARNING_THRESHOLD` was already exported before the config was sourced, that value wins; otherwise it falls back to `80`.

**Single source of truth.** Configuration files are a single source of truth: edit one value in the config file, and every script using it automatically gets the update. This is the entire reason `config/toolkit.conf` exists instead of every script defining its own copy of `$REPORT_DIR` — one edit, every component picks it up, nothing to keep in sync manually.

**What `source` actually does.** `source` allows your script to use the variables defined in the config file. It doesn't run the config file as a separate program — it reads its contents directly into the current shell's environment, as if those lines had been typed directly into the running script.

---

## Function Call Syntax

`function_name` → calls the function; `$(function_name)` → calls it and uses the value it outputs.

This is the distinction between running a function for its *side effect* (like `log_error "message"`, where I don't need anything back, I just want the error logged) versus running it to *capture its output* (like `now=$(timestamp)`, where I specifically want the string it echoes, to store in a variable). Same underlying idea as the exit-status-vs-captured-output confusion from MP2 (`if is_healthy ...` vs `health=$(is_healthy ...)`) — just phrased as the general rule this time instead of learned the hard way through a bug.

---

## Architecture Decision: Load Order of Config and Common Lib

**The two options considered:**
1. `common.sh` could load/source the config itself, so the running scripts would only need to load `common.sh`
2. Load the config first, then load `common.sh` in each running script, so `common.sh` inherits the config variables

**What was chosen:** option 2. In each script:

```bash
source config/toolkit.conf   # load the config first
source lib/common.sh          # load common.sh so it can inherit the variables defined in config/toolkit.conf
```

This allows the scripts to use the functions in `common.sh` that are using the variables defined in the config file — for example, `require_dir()` inside `common.sh` needs to know what `$ERROR_DIR` is, and it only knows that because `config/toolkit.conf` was already sourced into the shell *before* `common.sh`'s functions are ever called. If the order were reversed, or if `common.sh` tried to source the config itself, it would work too — but the chosen pattern keeps every script's startup sequence identical and explicit, rather than hiding the config-loading step inside the library file where it's less obvious.

---

## `find` Syntax

In `find`, `-o` means OR. This is how `system-audit.sh`'s file inventory command works: `find . -name "*.sh" -o -name "*.conf" -o -name "*.log"` finds every file matching *any* of the three patterns, not requiring all three at once.

---

## What Was Learned (design decisions)

### Why `require_file()` and `log_error()` don't call `exit`
Functions in `lib/common.sh` only check and report — they return a code or log a message, but never force an `exit` themselves. If `require_file()` called `exit 1` internally the moment a file was missing, every component script using it would be locked into identical failure behavior with zero flexibility. The *decision* about what to do after a failed check stays with the calling script, not the shared function.

### Function parameter capture pattern
Every function in `lib/common.sh` opens with `local message="$1"` (or `local path="$1"`) — capturing the positional parameter into a named `local` variable immediately, rather than scattering `$1` through the function body. Keeps the code readable and keeps the variable properly scoped, same `local` discipline as Lab 09/MP2.

### Why the `EXIT` trap prints to the terminal, not the report file
The `EXIT` trap's job is a live, human-readable confirmation that the run finished — useful to someone watching a cron job or CI log in real time. The permanent record (the actual counts, the actual per-server lines) belongs in the timestamped report file, written separately with `>>`. Same lesson as MP2's Error 13, carried forward.

### Why `health-check.sh`'s input source moved from `$1` to config
In MP2, the fleet file path came from `${1:-data/servers.txt}`. In the toolkit, it comes from `$FLEET_FILE` in config instead, and the script takes no arguments at all. This makes it consistent with `log-scanner.sh` (also argument-free, also config-driven), and lets the dispatcher call every component the same simple way, with no argument-forwarding logic needed.

### Why the dispatcher uses `exec`, not a plain call
`exec` replaces the dispatcher's own running process with the component script, so the component's real exit code becomes the dispatcher's exit code directly, with no intermediate step that could rewrite it — and avoids both the dispatcher's and the component's `EXIT` traps trying to fire independently for the same run.

### Why some directory checks use literal strings and others use variables
`require_dir("config")`, `require_dir("lib")` etc. use literal strings because those four directory names are structural — they define the shape of the project and will never change. `require_dir("$REPORT_DIR")` etc. use variables because those three are meant to be reconfigurable from `config/toolkit.conf`. Mixing this up would either break the single-source-of-truth rule or add pointless indirection to something that never varies.

---

## Commands Used

```bash
mkdir -p integration-01-scripting-toolkit/{config,lib,data/sample-logs,scripts,reports,errors,logs}
touch config/toolkit.conf lib/common.sh
touch scripts/{toolkit.sh,system-audit.sh,log-scanner.sh,health-check.sh}
chmod +x scripts/*.sh
CPU_WARNING_THRESHOLD=90 bash -c 'source config/toolkit.conf; echo "$CPU_WARNING_THRESHOLD"'
shellcheck scripts/*.sh lib/*.sh
```

---

## Problems Encountered

### Problem 1 — Ambiguity in the original `instructions.md`
**What happened:** the first draft described requirements like "checks these directories exist" and "sets a trap" without specifying exact function signatures, exact defaults, or exact behavior for edge cases.

**Why it happened:** the checklist was written at the level of "what the script should do" without pinning down "exactly how, with what exact values."

**How I found it:** kept hitting genuine ambiguity trying to figure out how to actually write `log_error()`'s parameter handling and `system-audit.sh`'s directory-check logic.

**How it was fixed:** rewrote `instructions.md` section by section with exact function signatures, exact parameter meanings, exact return-vs-exit behavior, and exact step-by-step build order — removing every "e.g." and replacing it with the literal value to use.

---

## Open Questions / Things I'm Still Unsure About

- Whether `require_dir()`'s self-healing behavior (silently creating a missing directory) is right for every case, or whether a missing `data/` directory should be a hard failure instead, since that usually signals something more seriously wrong than a missing `reports/` directory
- Whether `pgrep -f "toolkit.sh"` in `system-audit.sh`'s "already running" check behaves correctly when launched *through* the dispatcher (via `exec`) versus run directly — need to test both paths once the script is built