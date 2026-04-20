# Linux Lab 01 — Navigation & File Management

## Problem
Operating in a Linux environment without clear navigation leads to slow workflows, file misplacement, and errors.  
Needed a reliable way to move through the filesystem, manage files, and recover from mistakes without guessing.

---

## What I Built
A structured Linux workspace with multiple directories (`logs`, `reports`, `drafts`, `scripts`, `archive`) and a repeatable workflow to navigate, organise, and manage files efficiently.

---

## How I Solved It
- Used `pwd` to always confirm current location
- Used `ls` to inspect directories before acting
- Navigated using both:
  - relative paths (`cd ../reports`)
  - absolute paths (`cd ~/devops-journey/...`)
- Managed files using:
  - `mv` (move/rename)
  - `cp` (copy)
  - `rm` (delete)
  - `mkdir` / `rmdir` (directory control)
- Verified every operation using `ls` to prevent errors
- Recovered from mistakes (wrong paths, missing files) using inspection instead of guessing

---

## Tools Used
- Navigation: `cd`, `pwd`, `ls`
- File management: `mv`, `cp`, `rm`
- Directories: `mkdir`, `rmdir`
- File inspection/editing: `cat`, `echo`

---

## Result
- Navigated the filesystem without trial-and-error
- Reduced multi-step navigation into single efficient commands
- Managed files across directories with consistent verification
- Recovered from errors quickly using logical inspection

---

## Proof

### Directory Structure
![directory structure](screenshots/ls-R.png)

---

### Navigation
![navigation](screenshots/navigation.png)

---

### File Operation
![file move](screenshots/file-move.png)

---

### Break/Fix — Wrong Path
![wrong path](screenshots/wrong-path.png)


---

## Key Takeaway
Linux does not guess — every command depends on correct paths.  
Efficiency comes from understanding the filesystem structure, not memorising commands.

---

## Next Step
Permissions, ownership, and execution control (Lab 02)
