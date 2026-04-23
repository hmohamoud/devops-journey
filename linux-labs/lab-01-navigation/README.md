# Lab 01 — Linux Navigation & File Management

**Environment:** macOS Sequoia | Zsh | VS Code Terminal | Apple Silicon (M-series)

---

## Problem

Operating in a Linux environment without clear navigation leads to slow workflows,
file misplacement, and errors.  
Needed a reliable way to move through the filesystem, manage files,
and recover from mistakes without guessing.

---

## What I Built

A structured Linux workspace with directories (`logs`, `reports`, `drafts`,
`scripts`, `archive`) and a repeatable workflow to navigate, organise,
and manage files efficiently.

---

## How I Solved It

**Navigation:**
- Used `pwd` before every move — prevents incorrect assumptions in deep directory trees
- Used `ls` before acting — verified structure instead of guessing
- Used relative paths (`cd ../reports`) for efficient movement between directories
- Used absolute paths (`cd ~/devops-journey/...`) for recovery when location was uncertain

**File Management:**
- `mv` for moving and renaming in a single operation
- `cp` to safely duplicate before destructive actions
- `rm` used deliberately with verification after execution
- `mkdir` / `rmdir` to control directory structure

**Verification habit:**
Every operation was validated using `ls` or `pwd`.  
This prevents silent errors and ensures state awareness at all times.

---

## Proof

### 1. Directory Structure (Recursive Listing)
Shows full project layout using `ls -R` to understand hierarchy before navigation  
![Directory structure](screenshots/ls-R.png)

---

### 2. Navigation (Relative vs Absolute Paths)
Demonstrates controlled navigation across directories using:
- relative paths for efficiency
- absolute paths for recovery  
Each movement is verified with `pwd`  
![Navigation](screenshots/navigation.png)

---

### 3. File Operations (Move + Verify)
Demonstrates safe file movement using `mv`, followed by verification using `ls`  
Ensures file operations are intentional and correct  
![File move](screenshots/file-move.png)

---

### 4. Break/Fix — Incorrect Path Recovery
Demonstrates real debugging workflow:
- attempted invalid path (`cd reports`)
- received system error
- inspected structure using `ls`
- corrected using relative path (`cd ../reports`)
- verified using `pwd`  

![Wrong path fix](screenshots/wrong-path.png)

---

## Break/Fix Summary

| Issue | Cause | Fix |
|---|---|---|
| `cd reports` failed from archive/ | reports is a sibling, not a child | `cd ../reports` |
| Absolute path not found | Missing `linux-labs/` in path | Added full correct path |
| `mv` failed with `>` operator | Misused shell redirection | Used correct syntax: `mv source destination/` |
| Renamed wrong file | Assumed filename without verification | Used `ls` before operation |
| `echo` created incorrect files | Incorrect syntax order | Used `echo "text" >> file.txt` |

---

## Improvements (After Initial Completion)

- Learned `ls -a` to view hidden files not shown in standard listings  
  Example: `ls -a` → reveals `.git`, `.env`, hidden config files

- Learned `mkdir -p` to create nested directories in a single command  
  Example: `mkdir -p projects/app/src` → creates full structure without manual steps

- Learned `cp -r` to copy directories recursively (not just files)  
  Example: `cp -r logs backup/` → duplicates entire directory and contents

- Learned `rm -r` to delete directories containing files  
  Example: `rm -r temp/` → removes folder and everything inside

- Learned `rm -rf` to force delete without prompts (use carefully)  
  Example: `rm -rf build/` → immediate deletion of directory and contents

- Clarified difference between directory removal commands:  
  Example:  
  `rmdir empty-folder/` → works only if empty  
  `rm -r folder/` → removes folder with contents

---

## Key Takeaway

Linux does not guess — every command depends on correct paths and context.  
Efficiency comes from:
- verifying before acting
- diagnosing before fixing
- understanding structure, not memorising commands

---

## Next Step

[Lab 02 — Editing Files & Permissions](../lab-02-editing-permissions/)
