# Lab 02 — Editing Files & Permissions

## Objective
Develop control over file contents and file access in Linux by editing files, inspecting permissions, changing access levels, and recovering from permission-related failures.

---

## Scenario
You are a junior DevOps engineer working on a Linux server.

A small set of notes, scripts, and config files already exists, but some files are incomplete, some are not executable, and some cannot be edited or read due to permission settings.

Your job is to inspect, edit, secure, and recover the environment without guessing.

---

## Constraints (MANDATORY)

- Do NOT blindly copy commands
- Before changing permissions, inspect them first
- After every permission change, verify with `ls -l`
- After every file edit, verify with `cat`
- If something breaks, diagnose before fixing
- Use `nano` as the main editor for this lab
- Do not use `sudo` unless explicitly needed later

---

## Tasks

### Task 1 — Setup the environment

Create a controlled environment for the lab.

- [ ] Navigate to your `lab-02-permissions` folder
- [ ] Create these directories:
  - files/
  - scripts/
  - configs/
  - archive/

- [ ] Create these files:
  - files/notes.txt
  - files/private.txt
  - scripts/deploy.sh
  - configs/app.conf

- [ ] Verify the structure with:
  - `ls`
  - `ls -R`

---

### Task 2 — Edit files with nano

Learn to create and modify real file contents.

- [ ] Open `files/notes.txt` in `nano`
- [ ] Add 3 short lines of text
- [ ] Save and exit
- [ ] Verify contents with `cat`

- [ ] Open `configs/app.conf` in `nano`
- [ ] Add simple config-style content, for example:
  - `APP_ENV=dev`
  - `PORT=8000`
- [ ] Save and exit
- [ ] Verify contents with `cat`

- [ ] Open `scripts/deploy.sh` in `nano`
- [ ] Add a very simple shell script:
  - shebang line
  - one `echo` line
- [ ] Save and exit
- [ ] Verify contents with `cat`

---

### Task 3 — Inspect permissions

Learn how Linux represents access.

- [ ] Run `ls -l` in the lab root
- [ ] Run `ls -l files`
- [ ] Run `ls -l scripts`

- [ ] Identify for at least one file:
  - owner permissions
  - group permissions
  - others permissions

- [ ] Confirm whether `deploy.sh` is executable or not

---

### Task 4 — Change permissions with chmod

Learn to control read, write, and execute access.

- [ ] Make `scripts/deploy.sh` executable
- [ ] Verify with `ls -l`
- [ ] Run the script successfully

- [ ] Remove write permission from `files/private.txt`
- [ ] Verify with `ls -l`

- [ ] Add read/write permission back to `files/private.txt`
- [ ] Verify with `ls -l`

- [ ] Use both styles during the lab:
  - numeric mode
  - symbolic mode

Examples of the skill, not the answer:
- numeric: `chmod 644 file`
- symbolic: `chmod +x file`

---

### Task 5 — Understand practical permission levels

Build intuition for common permission patterns.

Apply and inspect these patterns on test files:

- [ ] Create `files/read_only.txt`
- [ ] Set it to read-only for the owner
- [ ] Verify with `ls -l`

- [ ] Create `scripts/runme.sh`
- [ ] Make it executable
- [ ] Verify with `ls -l`
- [ ] Run it successfully

- [ ] Compare:
  - a normal text file permission pattern
  - an executable script permission pattern

---

### Task 6 — File editing under permission constraints

Connect editing with access control.

- [ ] Try editing a file after removing the needed permission
- [ ] Observe what fails
- [ ] Restore the correct permission
- [ ] Edit successfully again
- [ ] Verify final contents with `cat`

---

## Break/Fix Tasks (CRITICAL)

You must intentionally create and resolve errors.

- [ ] Remove execute permission from `scripts/deploy.sh`
  → attempt to run it
  → diagnose the failure
  → fix it

- [ ] Remove read permission from a file
  → attempt to view it with `cat`
  → diagnose the failure
  → fix it

- [ ] Remove write permission from a file
  → attempt to edit it
  → diagnose the failure
  → fix it

- [ ] Apply the wrong chmod value to a file
  → inspect with `ls -l`
  → correct it

- [ ] Create one file whose permissions are too open
  → tighten them intentionally

---

## Verification Checkpoints (NO SKIPPING)

At the end, you must be able to:

- [ ] Explain what `r`, `w`, and `x` mean
- [ ] Explain the difference between owner, group, and others
- [ ] Read `ls -l` output without guessing
- [ ] Explain why a script may fail to run
- [ ] Use `chmod` in:
  - symbolic form
  - numeric form
- [ ] Edit files confidently with `nano`
- [ ] Verify all changes using:
  - `ls -l`
  - `cat`

---

## Success Criteria

You are successful when:

- You can edit files confidently in the terminal
- You understand how Linux file permissions control access
- You can read and interpret permission strings from `ls -l`
- You can fix read/write/execute failures logically
- You understand why executable scripts need the correct permission
- You can explain all of this simply and clearly without copying