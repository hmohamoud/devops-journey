# Lab 02 — Linux Permissions & File Control

**Environment:** macOS Sequoia | Zsh | VS Code Terminal | Apple Silicon (M-series)  
> Note: Permission behaviour follows standard Unix/Linux permission model

---

## Problem

In Linux systems, incorrect permissions directly break functionality:
scripts fail to execute, files become unreadable, and modifications are blocked.

A reliable workflow was needed to:
- inspect permissions before acting
- control access (read / write / execute) intentionally
- diagnose permission failures quickly
- recover without trial-and-error

---

## What I Built

A controlled Linux environment with:

- **files**
  - `notes.txt`
  - `private.txt`
  - `read_only.txt`

- **scripts**
  - `deploy.sh`
  - `runme.sh`

- **configs**
  - `app.conf`

This environment was used to simulate real-world failures:
- script execution errors
- read/write restrictions
- incorrect permission states

---

## How I Solved It

### Permission Inspection
- Used `ls -l` before every action — no assumptions
- Interpreted permission structure:
  - owner → group → others
- Identified file type from leading character:
  - `-` = file
  - `d` = directory

---

### Permission Control — Symbolic Mode
- `chmod +x` → enable execution (required for scripts)
- `chmod -w` → remove write (simulate edit restrictions)

Used for fast, targeted changes.

---

### Permission Control — Numeric Mode
- `755` → owner full control, others read/execute (standard for scripts)
- `644` → owner read/write, others read-only (standard for configs)
- `455` → owner cannot write (locked file scenario)
- `444` → read-only for all users

Used for setting full permission states efficiently.

---

### Execution Logic
A script requires:
1. correct shebang → `#!/bin/bash`
2. execute permission → `x`

If either is missing:
→ execution fails

---

### Verification Habit
Every change was validated using:
- `ls -l` → confirm permission state
- `./deploy.sh` / `./runme.sh` → confirm execution
- `cat` / `nano` → confirm read/write behaviour

No assumptions — only verified state.

---

## Proof

### 1. Permission Inspection
Initial inspection using `ls -l` to understand file access before modification  
![permissions](screenshots/permission-view.png)

---

### 2. Script Execution (Before → After)
Shows script state before and after adding execute permission with `chmod +x`  
![script execution](screenshots/script-execution.png)

---

### 3. Break/Fix — Execution Permission Denied
- Removed execute permission → script failed (`permission denied`)
- Diagnosed using `ls -l` (missing `x`)
- Restored using `chmod +x`
- Verified with successful execution  
![permission denied fix](screenshots/permission-denied-fix.png)

---

### 4. Break/Fix — Read/Write Restriction
- Removed write permission → file could not be edited
- Removed read permission → file could not be viewed with `cat`
- Diagnosed using permission string
- Restored using `chmod 755`
- Verified by editing and reading file successfully  
![read write restriction](screenshots/read-write-restrictions.png)

---

## Scope

This lab focuses on:
- permission inspection (`ls -l`)
- permission control (`chmod`)
- script execution requirements
- diagnosing permission failures

Ownership management (`chown`, `chgrp`) is intentionally excluded and will be covered in a later lab.

---

## Break/Fix Summary

| Issue | Cause | Fix |
|---|---|---|
| Script would not run | Execute permission missing | `chmod +x script.sh` |
| Permission denied on execution | Execute permission removed | `chmod +x script.sh` |
| File could not be edited | Write permission removed | `chmod 755 file.txt` |
| File could not be read | Read permission removed | `chmod 755 file.txt` |
| Script failed — bad interpreter | Incorrect shebang (`#!bin/bash`) | Fixed to `#!/bin/bash` |
| Wrong command used | Typed `ls 455` instead of `chmod` | `chmod 455 file.txt` |

---

## Key Takeaway

Permissions directly control system behaviour.

Failures follow simple rules:
- no `r` → cannot read
- no `w` → cannot modify
- no `x` → cannot execute

The core skill is:
→ identifying the missing permission instantly  
→ fixing it in a single command  

---

## Next Step

[Lab 03 — Text Processing & System Inspection](../lab-03-working-with-text/)
