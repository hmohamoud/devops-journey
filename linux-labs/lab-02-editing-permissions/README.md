# Lab 02 — Editing Files & Permissions

## Problem
Needed to control file access and fix execution failures in a Linux system where scripts and files were not behaving correctly due to permission issues.

---

## What I Built
Created a structured environment with:

- files/
- configs/
- scripts/
- archive/

Simulated real-world permission failures and recovery scenarios.

---

## How I Solved It
- Edited files using nano and verified with cat
- Inspected permissions using ls -l
- Changed permissions using:
  - symbolic mode (+x, -w)
  - numeric mode (755, 640, 440)
- Executed scripts using ./script
- Broke permissions intentionally and fixed them using inspection

---

## Tools Used
- nano, cat
- ls -l
- chmod
- script execution (./file)

---

## Results
- Fixed script execution failures
- Diagnosed and resolved permission errors quickly
- Controlled read, write, execute access intentionally
- Stopped relying on guessing by using inspection first

---

## Proof

### Script not executable → fixed
ls -l scripts/deploy.sh
chmod +x scripts/deploy.sh
./scripts/deploy.sh

### Read permission failure → fixed
chmod 355 files/read_only.txt
cat files/read_only.txt

chmod 755 files/read_only.txt
cat files/read_only.txt

---

## Key Takeaways
- ls -l is the first step in debugging permissions
- r, w, x directly control behaviour
- chmod must be used intentionally
- scripts need correct shebang + execute permission

---

## Outcome
I can now:
- debug permission issues quickly
- control file access precisely
- fix script execution problems without trial-and-error

---

## Next Step
Lab 03 — Text Processing & Inspection
