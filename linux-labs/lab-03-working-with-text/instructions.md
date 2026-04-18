
# Lab 03 — Linux Text Processing & System Inspection

## Objective
Develop precise control over extracting, analysing, and monitoring text data in Linux systems.

You must be able to:
- locate critical information instantly
- detect patterns and anomalies
- operate on large datasets without manual scanning
- combine commands to solve real problems efficiently

---

## Scenario
You are responsible for maintaining a live Linux server.

The system generates logs, user data, and transaction records continuously.

Recently:
- users are reporting issues
- errors are appearing in logs
- data inconsistencies are suspected

You must investigate and extract answers **without opening files manually**.

---

## Constraints (MANDATORY)

- Do NOT scroll through files manually unless absolutely necessary
- You are NOT allowed to rely on trial-and-error
- Every command must have a clear intention
- Before running a command:
  → predict the output
- After running a command:
  → verify and interpret the result
- You must prioritise:
  → speed, precision, and clarity
- You MUST use pipes (`|`) where appropriate
- Prefer minimal, efficient commands over long solutions

---

## Tasks

### Task 1 — Environment Setup

- [ ] Create:
  - text-lab/
    - logs/
    - data/
    - output/

- [ ] Create files:
  - logs/app.log
  - logs/errors.log
  - data/users.txt
  - data/transactions.txt

- [ ] Populate files with realistic data:
  - logs should include:
    - INFO, WARNING, ERROR messages
    - repeated patterns
  - users.txt should include:
    - duplicate users
  - transactions.txt should include:
    - numeric values

- [ ] Verify structure using:
  - `ls`
  - `ls -R`

---

### Task 2 — System Log Inspection

You are investigating system failures.

- [ ] Extract all lines containing "ERROR" from logs/app.log
- [ ] Count total ERROR occurrences using a pipeline
- [ ] Determine if errors are repeated or unique
- [ ] Group and count unique error messages
- [ ] Identify the most frequent error message

- [ ] Combine commands to produce:
  → error summary with counts

- [ ] Answer:
  → What is the most common system failure?

- [ ] Record:
  → Command used  
  → Output observed  
  → Interpretation  

---

### Task 3 — Data Integrity Analysis

User data may be corrupted.

- [ ] Count total number of users
- [ ] Identify duplicate users
- [ ] Extract only unique users
- [ ] Determine how many duplicates exist

- [ ] Combine commands to:
  → produce a clean dataset

- [ ] Answer:
  → Is the dataset reliable?

- [ ] Record:
  → Command used  
  → Output observed  
  → Interpretation  

---

### Task 4 — Transaction Analysis

You are analysing system usage.

- [ ] Count total transactions
- [ ] Sort transaction values
- [ ] Identify repeated transaction values
- [ ] Determine most frequent transaction amount

- [ ] Combine commands to:
  → produce frequency distribution

- [ ] Answer:
  → Are there suspicious patterns?

- [ ] Record:
  → Command used  
  → Output observed  
  → Interpretation  

---

### Task 5 — File Discovery & Investigation

System structure is unclear.

- [ ] Locate all `.txt` files in the lab
- [ ] Locate all log files
- [ ] Identify largest files using inspection

- [ ] Answer:
  → Which files are most important to investigate?

- [ ] Record:
  → Command used  
  → Output observed  
  → Interpretation  

---

### Task 6 — Real-Time Monitoring

The system is actively running.

- [ ] Monitor logs/app.log in real time
- [ ] Simulate activity:
  - append new log entries
- [ ] Detect when an ERROR appears

- [ ] Answer:
  → How quickly can you detect system failure?

- [ ] Record:
  → Command used  
  → Output observed  
  → Interpretation  

---

### Task 7 — Wildcard Efficiency

You must operate quickly across many files.

- [ ] List all `.txt` files using wildcards
- [ ] Apply commands across multiple files at once
- [ ] Copy or inspect multiple files using patterns

- [ ] Explain:
  → why wildcards are essential in large systems

- [ ] Record:
  → Command used  
  → Output observed  
  → Interpretation  

---

## Break/Fix Tasks (CRITICAL)

You must intentionally create and resolve real-world failures.

- [ ] Search for data that does not exist  
  → explain why no output appears

- [ ] Use incorrect case in search  
  → diagnose and fix

- [ ] Run inefficient commands on large data  
  → recognise issue and optimise

- [ ] Create duplicate data  
  → clean it using proper commands

- [ ] Monitor logs but miss an error  
  → improve detection approach

- [ ] Lose track of file location  
  → recover using `find`

---

## Verification Checkpoints (NO SKIPPING)

At the end, you must be able to:

- [ ] Extract specific information from large files instantly
- [ ] Combine commands using pipes (`|`)
- [ ] Explain:
  - `grep`
  - `wc`
  - `sort | uniq -c`
  - `head` vs `tail`
- [ ] Detect patterns and anomalies in data
- [ ] Monitor logs in real time without missing events
- [ ] Find any file without guessing

---

## Success Criteria

You are successful when:

- You do NOT manually scan large files
- You solve problems using command combinations
- You think in terms of:
  → “What question am I answering?”
- You interpret outputs, not just run commands
- You operate efficiently under pressure
- You demonstrate behaviour of a real DevOps / system engineer
