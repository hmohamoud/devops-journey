# Lab 04 — Shell Basics, Redirection & Command Control

## Objective
Develop full control over how commands communicate, where output goes, how errors are handled, and how shell features are used to build efficient workflows.

You must be able to:
- understand stdin, stdout, and stderr
- redirect output and errors intentionally
- chain commands cleanly using pipes
- inspect and discover commands quickly
- reuse command output dynamically
- use shell features to operate faster and safer

---

## Scenario
You are operating on a live Linux system.

Commands generate:
- useful output
- errors
- intermediate data

You must control:
- where data comes from (input)
- where it goes (output / files)
- what gets ignored vs captured
- how commands connect together

You are no longer just running commands.

You are controlling **data flow inside the system**.

---

## Constraints (MANDATORY)

- Do NOT guess where output goes
- Before running:
  → predict stdout vs stderr
- After running:
  → verify using `cat`, `ls`, or inspection
- Do NOT manually scan when commands can solve it
- You must explain WHY each command works
- Every command must have intention

---

## Tasks

### Task 1 — Environment Setup

- [ ] Create:
  - shell-lab/
    - input/
    - output/
    - errors/
    - temp/

- [ ] Create files:
  - input/users.txt
  - input/logs.txt
  - input/commands.txt

- [ ] Populate:
  - users.txt → duplicates
  - logs.txt → INFO, WARNING, ERROR
  - commands.txt → random command names

- [ ] Verify:
  - `ls`
  - `ls -R`

---

### Task 2 — stdout & Output Redirection

- [ ] Redirect output using `>`
- [ ] Confirm overwrite behaviour
- [ ] Append using `>>`
- [ ] Verify using `cat`

Answer:
→ difference between `>` and `>>`

---

### Task 3 — stdin & Input Redirection

- [ ] Count lines using file argument
- [ ] Count lines using `<`
- [ ] Compare behaviour

Answer:
→ what `<` actually changes

---

### Task 4 — stderr & Error Redirection

- [ ] Generate an error
- [ ] Redirect using `2>`
- [ ] Append using `2>>`
- [ ] Confirm errors are NOT in terminal

Answer:
→ what stderr is  
→ why separating errors matters

---

### Task 5 — Separate stdout vs stderr

- [ ] Run command with valid output + error
- [ ] Send stdout to file A
- [ ] Send stderr to file B
- [ ] Verify both

Answer:
→ why systems separate these

---

### Task 6 — Combine Streams

- [ ] Use `2>&1` to combine output + errors
- [ ] Save into one file
- [ ] Inspect result

Answer:
→ what actually happened internally

---

### Task 7 — Pipes & Command Flow

- [ ] Count ERROR lines using pipes
- [ ] Find duplicate users with counts
- [ ] Rank highest frequency values
- [ ] Extract top result

Answer:
→ why pipes > manual steps

---

### Task 8 — Command vs Process Substitution

- [ ] Use `$(...)` to embed output in a command
- [ ] Print dynamic results (e.g. counts)

- [ ] Use process substitution `<(...)`
  Example:
  diff <(sort file1.txt) <(sort file2.txt)

- [ ] Explain:
  → difference between:
    - command substitution
    - process substitution

---

### Task 9 — Command Path & Environment

- [ ] Inspect `$PATH`
- [ ] Print env variables
- [ ] Create variable
- [ ] Export variable
- [ ] Verify it exists

Answer:
→ what `$PATH` does  
→ why env variables matter

---

### Task 10 — Help and Command Discovery
You must be able to inspect commands quickly.
- [ ] Use `man` on a command
- [ ] Use `--help` on a command
- [ ] Answer:
  → When is `--help` faster than `man`

---

### Task 11 — Superuser Basics

- [ ] Understand `sudo`
- [ ] Identify when elevated access is needed
- [ ] Explain risks of misuse

DO NOT spam `sudo`

---

## Break/Fix Tasks (CRITICAL)

- [ ] Overwrite file accidentally → recover
- [ ] Append instead of overwrite → fix
- [ ] Wrong redirection target → debug
- [ ] Missing output → locate where it went
- [ ] Incorrect substitution syntax → fix
- [ ] Bad alias → correct
- [ ] Misunderstood pipe output → diagnose

---

## Verification Checkpoints

You must be able to:

- [ ] Explain stdin / stdout / stderr
- [ ] Use:
  - `>`
  - `>>`
  - `<`
  - `2>`
  - `2>>`
  - `2>&1`
- [ ] Use pipes (`|`) confidently
- [ ] Use `$(...)`
- [ ] Use `<(...)`
- [ ] Use:
  - `man`, `--help`, `which`, `type`
- [ ] Explain `$PATH`
- [ ] Explain environment variables
- [ ] Predict output location BEFORE running

---

## Success Criteria

You are successful when:

- You control output and errors intentionally
- You never lose data by accident
- You chain commands naturally
- You reuse command output dynamically
- You debug by reasoning, not guessing
- You operate like a systems engineer, not a beginner
