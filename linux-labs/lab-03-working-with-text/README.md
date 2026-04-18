# Lab 03 — Linux Text Processing & System Inspection

## Objective

Develop the ability to investigate Linux systems quickly using command-line tools instead of manual file inspection.

This lab focused on production-style problem solving using logs, datasets, and live monitoring.

---

## Real-World Scenario

A Linux server is generating logs, user records, and transaction data.

Users report failures, duplicate records exist, and suspicious activity may be present.

My task was to diagnose issues using fast command-line workflows.

---

## What I Built

Created a working lab environment containing:

- `logs/app.log`
- `logs/errors.log`
- `data/users.txt`
- `data/transactions.txt`

Used realistic repeated errors, duplicate users, and repeated transaction values.

---

## Core Skills Demonstrated

### Log Investigation

Used:

- `grep`
- `grep -c`
- `tail -f`

Results:

- identified 4 ERROR events
- detected repeated database connection failures
- monitored live logs in real time

### Data Quality Analysis

Used:

- `sort`
- `uniq`
- `uniq -d`
- `uniq -c`

Results:

- detected duplicate users
- reduced dataset from 16 rows to 13 clean unique users

### Numeric Analysis

Used:

- `sort -n`
- `sort -nr`

Results:

- ranked transaction values
- identified repeated amounts
- created frequency distributions

### File Discovery

Used:

- `find`
- wildcards `*`

Results:

- located all `.txt` and `.log` files instantly
- operated across multiple files efficiently

---

## Engineering Behaviours Practised

- solved problems without opening files manually
- chained commands using pipes
- verified output after every command
- debugged wrong paths and case issues
- selected efficient commands under pressure

---

## Example Workflows

```bash
grep "ERROR" logs/app.log | wc -l
sort data/users.txt | uniq -d
grep "ERROR" logs/app.log | sort | uniq -c | sort -nr
tail -f logs/app.log | grep "ERROR"
