# Challenge — Linux Text Processing & System Inspection

## Rules

- Do NOT use notes.md
- Do NOT manually scroll large files unless required
- Think first, command second
- Predict output before running commands
- Use the fastest clean solution possible
- Prefer pipelines where useful
- Verify every answer

---

## Challenge 1 — Fast Error Count

You are given:

`logs/app.log`

Tasks:

- Find all lines containing `ERROR`
- Count total ERROR events
- Count total ERROR events ignoring case
- Explain why the two counts may differ

---

## Challenge 2 — Most Common Failure

Using only commands:

- Group repeated ERROR messages
- Count each one
- Rank highest first
- Return only the single most common failure

Answer:

- What issue happens most often?

---

## Challenge 3 — User Dataset Integrity

You are given:

`data/users.txt`

Tasks:

- Count total users
- Count unique users
- Show duplicates only
- Show how many times each duplicate appears
- Create a clean file with duplicates removed

Answer:

- Is this dataset trustworthy?

---

## Challenge 4 — Suspicious Transactions

You are given:

`data/transactions.txt`

Tasks:

- Count total transactions
- Show highest transaction
- Show lowest transaction
- Show repeated transaction values
- Show most common transaction amount

Answer:

- Is there suspicious repetition?

---

## Challenge 5 — Lost File Recovery

You forgot where files were moved.

Tasks:

- Find every `.txt` file in the lab
- Find every `.log` file
- Find `clean_dataset.txt`
- Find all files beginning with `c`

Answer:

- Which folder currently stores cleaned output?

---

## Challenge 6 — Real-Time Incident Response

Monitor:

`logs/app.log`

Tasks:

- Watch file live
- Only display ERROR messages
- In another terminal append:

`INFO login ok`

then append:

`ERROR payment timeout`

Answer:

- Did only failures appear?

---

## Challenge 7 — Wildcard Operator Test

Without typing filenames one by one:

- Display all `.txt` files inside `data/`
- Count lines in all `.txt` files
- Search for `alice` across all `.txt` files
- Copy all `.txt` files into `output/`

Explain:

- Why are wildcards powerful in real jobs?

---

## Challenge 8 — No Output Debugging

Each command returns nothing or fails. Diagnose and fix.

### A

`grep "error" logs/app.log`

### B

`ls *.txt`

### C

`wc -l < users.txt`

### D

`tail -f logs.app`

For each:

- Explain why it failed
- Give corrected command

---

## Challenge 9 — Efficiency Battle

Solve both ways:

### Slow way:
Use multiple commands / unnecessary steps

### Fast way:
Use best direct command

Tasks:

- Find ERROR lines
- Count users
- Find duplicates

Then explain:

- Why the fast version is better

---

## Challenge 10 — Pattern Thinking

Choose the correct tool instantly:

Need to search text?  
→ ?

Need count total lines?  
→ ?

Need remove duplicates?  
→ ?

Need repeated counts?  
→ ?

Need live logs?  
→ ?

Need lost file?  
→ ?

Need biggest number first?  
→ ?

---

## Challenge 11 — Engineer Scenario

Production server issue reported:

- Users complain payments fail
- Logs are large
- You need answer in 60 seconds

Tasks:

Use commands to determine:

- Are payment errors present?
- How many?
- Most common related failure?
- Latest recent error?
- Where related logs are stored?

---

## Challenge 12 — Pressure Round (No Hesitation)

Answer instantly:

- Difference between `grep` and `grep -c`
- Difference between `uniq` and `uniq -c`
- Why does `uniq` often need `sort` first?
- Difference between `tail` and `tail -f`
- Why did `ls *.txt` fail sometimes?
- Why is `grep file | cat` usually wrong thinking?

---

## Final Check

You pass this lab when you can:

- Investigate files without opening them manually
- Use pipelines naturally
- Diagnose failures quickly
- Think in patterns, not memorised commands
- Solve common log/data problems under pressure
- Explain every command you use
