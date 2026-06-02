# Evidence

## Completed Tasks
- Created lab structure: `files/`, `scripts/`, `configs/`, `archive/`
- Created files:
  - `files/notes.txt`, `files/private.txt`
  - `scripts/deploy.sh`
  - `configs/app.conf`
- Edited files using `nano` and verified with `cat`
- Inspected permissions using `ls -l`
- Made script executable with `chmod +x` and executed using `./`
- Modified permissions using:
  - symbolic mode (`+x`, `-w`)
  - numeric mode (`755`, `455`, `555`)
- Verified all changes with `ls -l`
- Tested read/write/execute restrictions and recovered from failures

---

## Break/Fix Logs

### Issue 1 — Script failed to run (bad interpreter)
Problem:
`./scripts/deploy.sh` failed with:
bad interpreter: bin/bash: no such file or directory

Cause:
Incorrect shebang:
`#!bin/bash` (missing `/`)

Diagnosis:
Inspected file with `cat scripts/deploy.sh`

Fix:
Updated to:
`#!/bin/bash`

Prevention:
Always use correct shebang for scripts

---

### Issue 2 — Script not executable
Problem:
Could not run script initially

Cause:
Execute permission missing

Diagnosis:
Checked with:
`ls -l scripts/deploy.sh`

Fix:
`chmod +x scripts/deploy.sh`

Prevention:
Scripts must have execute permission to run

---

### Issue 3 — Removed execute permission
Problem:
`./scripts/deploy.sh` → permission denied

Cause:
Used:
`chmod -x scripts/deploy.sh`

Diagnosis:
`ls -l` showed no `x`

Fix:
`chmod +x scripts/deploy.sh`

Prevention:
If a script won’t run, check execute permission first

---

### Issue 4 — Removed write permission
Problem:
Could not edit file

Cause:
Removed write:
`chmod -w files/read_only.txt`

Diagnosis:
`ls -l` showed no `w`

Fix:
`chmod 755 files/read_only.txt`

Prevention:
Write permission is required to edit files

---

### Issue 5 — Removed read permission
Problem:
`cat files/read_only.txt` → Permission denied

Cause:
Used:
`chmod 355 files/read_only.txt` (no read for owner)

Diagnosis:
`ls -l` showed missing `r`

Fix:
`chmod 755 files/read_only.txt`

Prevention:
Read permission is required to view file contents

---

### Issue 6 — Incorrect path
Problem:
`ls -l files/private` failed

Cause:
Missing `.txt` extension

Diagnosis:
Checked with `ls files`

Fix:
Used correct path:
`files/private.txt`

Prevention:
Always verify filenames before accessing

---

### Issue 7 — Incorrect chmod usage
Problem:
Used invalid command:
`ls 455 files/private.txt`

Cause:
Mixed up `ls` and `chmod`

Diagnosis:
Command failed immediately

Fix:
Used correct command:
`chmod 455 files/private.txt`

Prevention:
`chmod` changes permissions, `ls` only displays

---

### Issue 8 — Attempted to run non-executable file
Problem:
Tried to run file without execute permission

Cause:
File didn’t have `x`

Diagnosis:
Checked with `ls -l`

Fix:
Added execute:
`chmod +x file`

Prevention:
Always check permissions before execution

---

## Key Patterns

- Most errors came from:
  - incorrect permissions
  - incorrect paths
  - incorrect command usage

- What helped me fix them:
  - `ls -l` to inspect permissions
  - `cat` to verify file content
  - understanding r/w/x meaning

---

## Main Takeaways

- `ls -l` is essential for debugging permissions
- `chmod` controls access (read, write, execute)
- scripts require:
  - correct shebang
  - execute permission
- permission errors are predictable:
  - no r → can’t read
  - no w → can’t edit
  - no x → can’t run
- most issues can be solved by inspecting first, then fixing logically
