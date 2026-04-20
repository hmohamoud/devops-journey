# Lab 01 — Linux Navigation & File System Control

## Objective
Develop precise control over the Linux filesystem by navigating, inspecting, and manipulating files and directories with full awareness and zero reliance on guesswork.

---

## Scenario
You are operating inside a live Linux server used by a production system.

Logs, reports, and scripts are distributed across directories.  
You must explore, organise, and maintain the system without breaking structure or losing data.

Mistakes are expected — recovery is required.

---

## Constraints (MANDATORY)

- Do NOT blindly copy commands
- Before running any command, predict what will happen
- After running a command, verify the result
- Every action must be confirmed using `pwd` or `ls`
- If something breaks, you must diagnose before fixing

---

## Tasks

### Task 1 — Environment Setup

- [ ] Create a root directory for the lab
- [ ] Inside it, create:
  - logs/
  - reports/
  - drafts/
  - scripts/
  - archive/

- [ ] Create initial files:
  - logs/system.log
  - reports/todo.txt
  - drafts/notes.txt

- [ ] Verify structure using `ls` and `ls -R`

---

### Task 2 — Navigation Control

- [ ] Use `pwd` to confirm your location before and after every move
- [ ] Navigate into each directory using `cd`
- [ ] Return to previous locations using `cd ..`
- [ ] Move directly between non-adjacent directories
- [ ] Use both:
  - relative paths
  - absolute paths

- [ ] At all times, be able to answer:
  → “Where am I right now?”

---

### Task 3 — File & Directory Operations

- [ ] Create new files inside reports/
- [ ] Move a file from reports/ → archive/
- [ ] Rename a file using `mv`
- [ ] Copy a file into archive/ using `cp`
- [ ] Make a backup copy of logs/ to /logs_copy using `cp -r`
- [ ] Delete a file using `rm`
- [ ] Create and remove a directory (`mkdir`, `rmdir`, `rmd -r`)

- [ ] After EACH operation:
  → verify using `ls`

---

### Task 4 — Viewing & Editing

- [ ] Add content to files using `echo`
- [ ] Inspect contents using `cat`
- [ ] Open and edit a file using `nano`
- [ ] Modify content and save changes
- [ ] Verify changes using `cat`

---

## Break/Fix Tasks (CRITICAL)

You must intentionally create and resolve errors.

- [ ] Attempt to navigate to a non-existent directory  
  → diagnose using `ls`, correct path

- [ ] Attempt to read a non-existent file  
  → identify correct file and recover

- [ ] Rename a file and lose track of it  
  → locate it using directory inspection

- [ ] Move a file to the wrong location  
  → identify mistake and restore structure

- [ ] Delete a file  
  → recreate correct structure manually

---

## Verification Checkpoints (NO SKIPPING)

At the end, you must be able to:

- [ ] Recreate the entire directory structure from memory
- [ ] Navigate to any directory without trial-and-error
- [ ] Explain the difference between:
  - relative vs absolute paths
  - `mv` vs `cp`
- [ ] Identify and fix at least 3 errors without guessing

---

## Success Criteria

You are successful when:

- You always know your location in the filesystem
- You never rely on guessing paths
- You verify every action with evidence
- You can manipulate files and directories confidently
- You recover from errors logically and quickly
- You can explain all actions clearly and simply
