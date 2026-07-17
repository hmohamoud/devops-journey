# Lab 07 — Advanced Log Analysis & Configuration Management

## Objective

Given a broken service, messy logs, and bad configuration — find the problem, fix it safely, prove the fix, and automate prevention using only the terminal.

---

## Scenario

> "Something broke around 10:04. Payments are failing. Config was changed. Logs are huge. Root cause in 15 minutes."

You have SSH access. No dashboard. No GUI.

---

## Constraints

- Never open a file manually to search it — use a command
- Predict what each command will return before running it
- Verify every result after running
- No config change without a backup first
- Record every mistake in evidence.md

---

## Environment Setup

```text
ops-lab/
├── logs/
├── configs/
├── data/
├── output/
└── scripts/
```

`logs/app.log`:

```text
2026-06-01 10:00:01 INFO Application started
2026-06-01 10:00:45 INFO Health check passed
2026-06-01 10:01:10 WARNING High memory usage detected
2026-06-01 10:02:22 ERROR Database connection failed
2026-06-01 10:02:55 INFO Request processed successfully
2026-06-01 10:03:11 WARNING High memory usage detected
2026-06-01 10:03:44 ERROR Payment gateway timeout
2026-06-01 10:04:01 INFO Config reload triggered
2026-06-01 10:04:11 ERROR Payment gateway timeout
2026-06-01 10:04:33 ERROR Database connection failed
2026-06-01 10:04:55 ERROR Payment gateway timeout
2026-06-01 10:05:01 error payment processing failed
2026-06-01 10:05:22 ERROR Authentication service down
2026-06-01 10:05:44 ERROR Payment gateway timeout
2026-06-01 10:06:01 WARNING Disk usage above 80%
2026-06-01 10:06:22 ERROR Database connection failed
2026-06-01 10:06:44 error null pointer exception
2026-06-01 10:07:01 INFO Retry attempt 1
2026-06-01 10:07:22 ERROR Payment gateway timeout
2026-06-01 10:07:44 INFO Retry attempt 2
2026-06-01 10:08:01 ERROR Payment gateway timeout
2026-06-01 10:08:22 WARNING Connection pool exhausted
2026-06-01 10:08:44 ERROR Database connection failed
2026-06-01 10:09:01 INFO Cache cleared
2026-06-01 10:09:22 ERROR Payment gateway timeout
2026-06-01 10:09:44 ERROR Authentication service down
2026-06-01 10:10:01 INFO Scheduled job completed
2026-06-01 10:10:22 ERROR Database connection failed
2026-06-01 10:10:44 WARNING High memory usage detected
2026-06-01 10:11:01 ERROR Payment gateway timeout
```

`logs/nginx.log`:

```text
192.168.1.1 - - [01/Jun/2026:10:00:01 +0000] "GET /api/payments HTTP/1.1" 200 512
192.168.1.2 - - [01/Jun/2026:10:01:10 +0000] "POST /api/auth HTTP/1.1" 401 128
192.168.1.1 - - [01/Jun/2026:10:02:22 +0000] "GET /api/payments HTTP/1.1" 500 256
192.168.1.3 - - [01/Jun/2026:10:03:05 +0000] "GET /health HTTP/1.1" 200 64
192.168.1.1 - - [01/Jun/2026:10:04:11 +0000] "GET /api/payments HTTP/1.1" 503 256
192.168.1.4 - - [01/Jun/2026:10:04:33 +0000] "POST /api/payments HTTP/1.1" 503 512
192.168.1.2 - - [01/Jun/2026:10:05:10 +0000] "POST /api/auth HTTP/1.1" 401 128
192.168.1.1 - - [01/Jun/2026:10:05:44 +0000] "GET /api/payments HTTP/1.1" 503 256
192.168.1.5 - - [01/Jun/2026:10:06:15 +0000] "GET /health HTTP/1.1" 200 64
192.168.1.2 - - [01/Jun/2026:10:06:44 +0000] "POST /api/auth HTTP/1.1" 401 128
192.168.1.1 - - [01/Jun/2026:10:07:22 +0000] "GET /api/payments HTTP/1.1" 503 256
192.168.1.3 - - [01/Jun/2026:10:08:05 +0000] "GET /health HTTP/1.1" 200 64
192.168.1.4 - - [01/Jun/2026:10:08:44 +0000] "POST /api/payments HTTP/1.1" 503 512
192.168.1.1 - - [01/Jun/2026:10:09:22 +0000] "GET /api/payments HTTP/1.1" 503 256
192.168.1.2 - - [01/Jun/2026:10:10:01 +0000] "POST /api/auth HTTP/1.1" 401 128
```

`configs/app.conf`:

```text
APP_ENV=dev
PORT=8080
MAX_CONNECTIONS=100
DEBUG=true
WORKERS=2
LOG_LEVEL=info
# This is a comment line
DB_HOST=localhost
DB_PORT=5432

PAYMENT_TIMEOUT=30
PAYMENT_RETRIES=3
# End of config
```

`configs/database.conf`:

```text
DB_ENGINE=postgres
DB_HOST=localhost
DB_PORT=5432
DB_NAME=payments
DB_USER=admin
DB_PASSWORD=changeme
MAX_POOL_SIZE=10
IDLE_TIMEOUT=300
```

`data/users.txt` — at least 20 names with duplicates.

`data/transactions.txt` — at least 15 amounts with repeated values and one suspiciously high value.

Verify:

```bash
ls -R ops-lab/
wc -l ops-lab/logs/app.log
```

---

## Task 1 — Scope the Incident

You are given `ops-lab/logs/app.log`.

Without opening it:

- Count total log entries in app.log
- Find the first timestamp in app.log
- Find the last timestamp in app.log
- Count ERROR events in app.log case sensitive
- Count error events in app.log case insensitive
- Find why the two counts differ
- Count errors in app.log before 10:04 and after 10:04 separately
- List every unique error message in app.log

Record what app.log tells you about when the problem started.

---

## Task 2 — Find Root Cause

You are given `ops-lab/logs/app.log`.

Without opening it:

- Find which error message in app.log appears most often
- Find the top 3 most common error messages in app.log with counts
- Find every line in app.log containing the word payment
- Find the most recent error in app.log
- Find which error messages in app.log only started appearing after 10:04

Record which error is most likely causing the payment failures and why.

---

## Task 3 — nginx Investigation

You are given `ops-lab/logs/nginx.log`.

Without opening it:

- Count total requests in nginx.log
- Count requests per status code in nginx.log using awk to extract the status code column then count
- Find which IP makes the most requests in nginx.log
- Find which endpoint returns the most 503 errors in nginx.log
- Find the first 503 error timestamp in nginx.log and the first error timestamp in app.log and compare them
- Find which IPs hit the payment endpoint in nginx.log

- Find all 503 responses only for the `/api/payments` endpoint using an awk AND condition
- Count all requests that returned either 500 or 503 status codes using an awk OR condition
- Count the number of unique client IP addresses that made requests in nginx.log
Record whether the nginx.log timeline matches app.log and what that tells you.

---

## Task 4 — Config Investigation

You are given `ops-lab/configs/app.conf` and `ops-lab/configs/database.conf`.

Without opening either file:

- View app.conf with no comments and no blank lines
- Extract only the key names from app.conf using cut with = as delimiter
- Extract only the values from app.conf using cut with = as delimiter
- Find values in app.conf that look dangerously low by searching for WORKERS, TIMEOUT, CONNECTIONS, and POOL
- Find any value in database.conf that should not be in production by searching for password and default credentials

Record which values are suspicious and what you would change.

---

## Task 5 — Safe Config Fix

You are working on `ops-lab/configs/app.conf` and `ops-lab/configs/database.conf`.

- Preview changing WORKERS=2 to WORKERS=8 in app.conf without saving
- Confirm original file was not changed
- Make the change in app.conf with a backup
- Verify app.conf changed correctly using grep
- Verify the backup contains the original WORKERS=2 value using grep
- Change PAYMENT_TIMEOUT=30 to PAYMENT_TIMEOUT=60 in app.conf with a backup
- Change MAX_POOL_SIZE=10 to MAX_POOL_SIZE=50 and IDLE_TIMEOUT=300 to IDLE_TIMEOUT=600 in database.conf in a single sed command with a backup
- Strip all comments and blank lines from app.conf and save the result to ops-lab/output/clean-app.conf

Record why the preview step and backup are not optional in production.

---

## Task 6 — Live Monitoring

You are working with `ops-lab/logs/app.log`.

- Watch app.log live showing only ERROR lines
- In a second terminal append three INFO lines to app.log then two ERROR lines
- Confirm only ERROR lines appeared in the first terminal
- Save the live error stream from app.log to ops-lab/output/live-errors.log while still watching it on screen using tee
- Run the live error monitoring process a second time and save the new error stream without deleting previous results
- Verify that the existing error log entries are still present and that new error entries were added after them

Record whether errors reduced after the config change in Task 5.

---

## Task 7 — Data Integrity

You are given `ops-lab/data/users.txt` and `ops-lab/data/transactions.txt`.

Without opening either file:

- Count total users in users.txt
- Count unique users in users.txt
- Find the most duplicated user in users.txt
- Save a clean deduplicated and sorted version of users.txt to ops-lab/output/clean-users.txt
- Count total transactions in transactions.txt
- Find the highest amount in transactions.txt
- Find the lowest amount in transactions.txt
- Find the most common amount in transactions.txt
- Find any amount in transactions.txt that appears suspiciously often

Record whether the datasets are trustworthy.

---

## Task 8 — File System Investigation

You are investigating ops-lab/ for disk and permission issues.

Without opening any file:

- Find every log file in ops-lab/
- Find every config file in ops-lab/
- Find the biggest files in ops-lab/ sorted by size using find and xargs
- Find files in ops-lab/ modified in the last 24 hours
- Find files in ops-lab/ older than 30 days
- Find files in ops-lab/ with 777 permissions
- Find all shell scripts in ops-lab/

Record which files are biggest and whether any permissions are wrong.

---

## Task 9 — Automation

Create `ops-lab/scripts/incident_report.sh`.

The script must:

1. Accept a log file path as argument
2. Print usage and exit 2 if no argument provided
3. Print specific error and exit 1 if file does not exist
4. Count total errors in the provided log file case insensitively
5. Count total warnings in the provided log file case insensitively
6. Find the most common error in the provided log file
7. Find the first and last error timestamps in the provided log file
8. Count errors in the provided log file after 10:04
9. Save a timestamped report to ops-lab/output/
10. Print where the report was saved
11. Exit 0 on success

Run:

```bash
./ops-lab/scripts/incident_report.sh ops-lab/logs/app.log
echo $?

./ops-lab/scripts/incident_report.sh ops-lab/logs/missing.log
echo $?

./ops-lab/scripts/incident_report.sh
echo $?
```

Explain every line without notes.

---

## Task 10 — Full Root Cause Drill

> Payment service went down at 10:04. Config was changed. nginx returning 503s. Database errors spiking. You have 10 minutes.

No hints. No notes. No manual file opening.

Investigate app.log, nginx.log, app.conf, and database.conf. Fix what is wrong, prove the fix worked, and save all evidence to ops-lab/output/.

---

## Break/Fix Tasks

### Break/Fix 1
```bash
grep "error" ops-lab/logs/app.log | sort | uniq -c | sort -rn
```
Count in app.log is lower than expected. Find why and fix it.

---

### Break/Fix 2
```bash
uniq -c ops-lab/data/users.txt
```
Duplicate counts in users.txt are wrong. Find why and fix it.

---

### Break/Fix 3
```bash
sed -i 's/dev/production/g' ops-lab/configs/app.conf
```
Wrong change to app.conf. No backup. Recover. Then show the safe version.

---

### Break/Fix 4
```bash
awk '{print $2}' ops-lab/logs/nginx.log
```
Not printing the IP from nginx.log. Fix it.

---

### Break/Fix 5
```bash
find / -name "app.conf"
```
Terminal flooded with permission denied. Fix it.

---

### Break/Fix 6
```bash
grep "ERROR" ops-lab/logs/app.log | uniq -c | sort -rn
```
Counts from app.log are wrong. Find which stage is in the wrong place and fix it.

---

### Break/Fix 7
```bash
tail ops-lab/logs/app.log | grep "ERROR"
```
You miss a live error in app.log. Find why and give the correct monitoring command.

---

## Success Criteria

You are successful when:

- You find root cause without opening files manually
- You fix configs safely with backups every time
- You build pipelines from logic without notes
- You handle noisy and inconsistent data
- You diagnose broken pipelines before changing them
- You automate investigation so it never has to be done manually again
- You explain every command you run