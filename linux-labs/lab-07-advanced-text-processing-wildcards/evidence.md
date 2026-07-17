# Evidence

## Completed Tasks

### Environment Setup
- Created structured lab environment:
  - `ops-lab/`
    - `logs/`
    - `configs/`
    - `data/`
    - `output/`
    - `scripts/`

- Populated working files:
  - `logs/app.log`
  - `logs/nginx.log`
  - `configs/app.conf`
  - `configs/database.conf`
  - `data/users.txt`
  - `data/transactions.txt`

- Verified structure and size using:
  - `ls -R ops-lab/`
  - `wc -l ops-lab/logs/app.log`

---

### Task 1 — Scope the Incident

- Counted total log entries:
  - `wc -l < ops-lab/logs/app.log`

- Found first timestamp:
  - `head -1 ops-lab/logs/app.log`

- Found last timestamp:
  - `tail -1 ops-lab/logs/app.log`

- Counted ERROR events case sensitive:
  - `grep "ERROR" ops-lab/logs/app.log | wc -l` (or `grep -c "ERROR" ops-lab/logs/app.log`)

- Counted error events case insensitive:
  - `grep -i "ERROR" ops-lab/logs/app.log | wc -l` (or `grep -ic "ERROR" ops-lab/logs/app.log`)

- Found why the two counts differ:
  - One search is case sensitive, the other is case insensitive — the file contains lowercase `error` lines (e.g. `error payment processing failed`) that only the `-i` version catches

- Counted errors before/after 10:04:
  - `grep -i "ERROR" ops-lab/logs/app.log | awk '$2 < "10:04"'`
  - `grep -i "ERROR" ops-lab/logs/app.log | awk '$2 > "10:04"'`

- Listed every unique error message:
  - `grep -i "error" ops-lab/logs/app.log | sort | uniq`

---

### Task 2 — Find Root Cause

- Found the most common error message:
  - `grep -i "error" ops-lab/logs/app.log | sort | uniq -c | sort -nr | head -1`

- Found the top 3 most common error messages with counts:
  - `grep -i "error" ops-lab/logs/app.log | sort | uniq -c | sort -nr | head -3`

- Found every line containing "payment":
  - `grep -i "payment" ops-lab/logs/app.log`

- Found the most recent error:
  - `grep -i "error" ops-lab/logs/app.log | tail -1`

- Found which error messages only started appearing after 10:04:
  - `grep -i "ERROR" ops-lab/logs/app.log | awk '$2 > "10:04"'`

---

### Task 3 — nginx Investigation

- Counted total requests:
  - `wc -l < ops-lab/logs/nginx.log`

- Counted requests per status code:
  - `awk '{print $9}' ops-lab/logs/nginx.log | sort | uniq -c`

- Found which IP makes the most requests:
  - `awk '{print $1}' ops-lab/logs/nginx.log | sort | uniq -c | sort -nr | head -1`

- Found which endpoint returns the most 503 errors:
  - `grep -i "503" ops-lab/logs/nginx.log | awk '{print $7}' | sort | uniq -c | sort -nr | head -1`

- Found the first 503 error timestamp:
  - `grep -i "503" ops-lab/logs/nginx.log | awk '{print $4}' | head -1`

- Found which IPs hit the payment endpoint:
  - `grep -i "payment" ops-lab/logs/nginx.log | awk '{print $1}' | sort | uniq`

- Found all 503 responses only for `/api/payments` using an AND condition:
  - `awk '$9 == 503 && $7 == "/api/payments"' ops-lab/logs/nginx.log`

- Counted requests that returned either 500 or 503 using an OR condition:
  - `awk '$9 == 500 || $9 == 503' ops-lab/logs/nginx.log`

- Counted unique client IPs:
  - `awk '{print $1}' ops-lab/logs/nginx.log | sort | uniq | wc -l`

---

### Task 4 — Config Investigation

- Viewed `app.conf` with no comments and no blank lines:
  - `sed '/^$/d; /^#/d' ops-lab/configs/app.conf`

- Extracted only the key names:
  - `sed '/^$/d; /^#/d' ops-lab/configs/app.conf | cut -d= -f1`

- Extracted only the values:
  - `sed '/^$/d; /^#/d' ops-lab/configs/app.conf | cut -d= -f2`

- Found dangerously low values (workers, timeouts, connections, pool size):
  - `grep -iE "WORKERS|TIMEOUT|CONNECTIONS|POOL" ops-lab/configs/app.conf`

- Found risky production credentials:
  - `grep -iE "password|changeme|secret|default" ops-lab/configs/database.conf`

---

### Task 5 — Safe Config Fix

- Previewed changing `WORKERS=2` to `WORKERS=8` without saving:
  - `sed 's/WORKERS=2/WORKERS=8/g' ops-lab/configs/app.conf`

- Confirmed original file was unchanged:
  - `grep -i "workers" ops-lab/configs/app.conf`

- Made the change in `app.conf` with a backup:
  - `sed -i.bak 's/WORKERS=2/WORKERS=8/g' ops-lab/configs/app.conf`

- Verified the live file changed:
  - `grep "WORKERS" ops-lab/configs/app.conf`

- Verified the backup preserved the original value:
  - `grep "WORKERS" ops-lab/configs/app.conf.bak`

- Changed `PAYMENT_TIMEOUT=30` to `PAYMENT_TIMEOUT=60` with a backup:
  - `sed -i.bak 's/PAYMENT_TIMEOUT=30/PAYMENT_TIMEOUT=60/g' ops-lab/configs/app.conf`

- Changed both `MAX_POOL_SIZE` and `IDLE_TIMEOUT` in `database.conf` in one command:
  - `sed -i.bak 's/MAX_POOL_SIZE=10/MAX_POOL_SIZE=50/g; s/IDLE_TIMEOUT=300/IDLE_TIMEOUT=600/g' ops-lab/configs/database.conf`

- Saved a clean version with comments and blank lines stripped:
  - `sed '/^#/d; /^$/d' ops-lab/configs/app.conf > ops-lab/output/clean-app.conf`

---

### Task 6 — Live Monitoring

- Watched `app.log` live, showing only ERROR lines:
  - `tail -f ops-lab/logs/app.log | grep -i "error"`

- Appended lines from a second terminal to simulate new activity:
  - 3x `echo "... INFO ..." >> ops-lab/logs/app.log`
  - 2x `echo "... ERROR ..." >> ops-lab/logs/app.log`

- Confirmed only the ERROR lines surfaced in the first terminal

- Saved the live error stream while still watching it on screen:
  - `tail -f ops-lab/logs/app.log | grep --line-buffered -i "error" | tee -a ops-lab/output/live-errors.log`

- Re-ran the monitor a second time and confirmed prior entries in `live-errors.log` were preserved, with new entries appended after them (thanks to `tee -a`)

---

### Task 7 — Data Integrity

- Counted total users:
  - `wc -l < ops-lab/data/users.txt`

- Counted unique users:
  - `sort ops-lab/data/users.txt | uniq | wc -l`

- Found the most duplicated user:
  - `sort ops-lab/data/users.txt | uniq -c | sort -nr | head -1`

- Saved a clean deduplicated, sorted version:
  - `sort ops-lab/data/users.txt | uniq > ops-lab/output/clean-users.txt`

- Counted total transactions:
  - `wc -l < ops-lab/data/transactions.txt`

- Found the highest amount:
  - `sort -nr ops-lab/data/transactions.txt | head -1`

- Found the lowest amount:
  - `sort ops-lab/data/transactions.txt | head -1`

- Found the most common amount:
  - `sort ops-lab/data/transactions.txt | uniq -c | sort -nr | head -1`

- Found amounts appearing suspiciously often:
  - `sort ops-lab/data/transactions.txt | uniq -c | sort -nr`

---

### Task 8 — File System Investigation

- Found every log file:
  - `find ops-lab/ -name "*.log"`

- Found every config file:
  - `find ops-lab/ -name "*.conf"`

- Found the biggest files, sorted by size:
  - `find ops-lab/ -type f | xargs du -sh | sort -rh`

- Found files modified in the last 24 hours:
  - `find ops-lab/ -mtime -1`

- Found files older than 30 days:
  - `find ops-lab/ -mtime +30`

- Found files with 777 permissions:
  - `find ops-lab/ -perm 777`

- Found all shell scripts:
  - `find ops-lab/ -name "*.sh"`

---

## Break/Fix Logs

### Issue 1 — Case-sensitive grep undercounts errors

Problem:
`grep "error" ops-lab/logs/app.log | sort | uniq -c | sort -rn`

Cause:
Plain `grep "error"` only matches lowercase `error` and misses the uppercase `ERROR` lines (or vice versa) — the log mixes both cases.

Fix:
Used `grep -i "error"` to match regardless of case.

Prevention:
Always check case sensitivity before trusting a count against a log that isn't guaranteed to be consistently cased.

---

### Issue 2 — `uniq -c` gives wrong duplicate counts

Problem:
`uniq -c ops-lab/data/users.txt`

Cause:
`uniq` only collapses **adjacent** duplicate lines. The file wasn't sorted first, so identical names scattered throughout the file weren't grouped together.

Fix:
`sort ops-lab/data/users.txt | uniq -c`

Prevention:
Always sort before piping into `uniq -c`.

---

### Issue 3 — Config change made with no backup

Problem:
`sed -i 's/dev/production/g' ops-lab/configs/app.conf`

Cause:
`-i` alone edits the file in place immediately with no backup — the original `APP_ENV=dev` value was gone the moment the command ran.

Fix:
Recovered by identifying the previous value from evidence gathered earlier in Task 4 and manually restoring it, then re-ran the change safely as `sed -i.bak 's/dev/production/g' ops-lab/configs/app.conf` so a `.bak` copy exists going forward.

Prevention:
Never run `sed -i` without `.bak` (or an equivalent manual backup) on a config file.

---

### Issue 4 — awk prints the wrong column

Problem:
`awk '{print $2}' ops-lab/logs/nginx.log`

Cause:
`$2` on an nginx access log line is the literal `-` placeholder field, not the IP address. The IP address is `$1`.

Fix:
`awk '{print $1}' ops-lab/logs/nginx.log`

Prevention:
Confirm field positions against a sample line before writing an awk extraction.

---

### Issue 5 — `find /` floods the terminal with permission errors

Problem:
`find / -name "app.conf"`

Cause:
Searching from `/` traverses protected system directories the current user can't read, generating a wall of `Permission denied` messages.

Fix:
`find / -name "app.conf" 2>/dev/null`

Prevention:
Scope `find` to the relevant directory (`ops-lab/`) whenever possible, and suppress stderr with `2>/dev/null` when searching broader paths.

---

### Issue 6 — Wrong pipeline stage order

Problem:
`grep "ERROR" ops-lab/logs/app.log | uniq -c | sort -rn`

Cause:
`uniq -c` ran before the lines were sorted, so it only collapsed adjacent duplicates instead of all duplicates in the file.

Fix:
`grep "ERROR" ops-lab/logs/app.log | sort | uniq -c | sort -nr`

Prevention:
Remember the required pipeline order: `sort` → `uniq -c` → `sort -nr`.

---

### Issue 7 — Missed a live error in the log

Problem:
`tail ops-lab/logs/app.log | grep "ERROR"`

Cause:
Plain `tail` (without `-f`) only prints a static snapshot of the last lines once and exits — it doesn't keep watching the file, so new errors written after the command ran were missed.

Fix:
`tail -f ops-lab/logs/app.log | grep -i "ERROR"` (add `--line-buffered` to `grep` if output through further pipes appears delayed).

Prevention:
Use `-f` any time the goal is to watch a file continuously rather than take a single snapshot.

---

## Key Patterns

- Most issues came from:
  - unsorted input before `uniq -c`
  - forgetting `-i` on a log with inconsistent casing
  - skipping the backup step before editing a config
  - misreading column positions before writing an awk filter
  - running destructive commands (`find /`, `sed -i`) without scoping or protection first

- Effective debugging tools:
  - `grep -i` / `grep -c` to sanity-check counts
  - `head -1` on a sample line to confirm field positions before scripting an `awk` filter
  - `.bak` files and `diff`-by-eye against the backup to confirm a config change was correct
  - `2>/dev/null` to keep noisy commands readable

---

## Main Takeaways

- Every count is only as trustworthy as the pipeline that produced it — order and case sensitivity change the answer
- `awk` understands columns; `grep` only understands substrings — this distinction is what prevents a `grep "503"` false positive
- No config change goes out without a backup first, no exceptions
- `sort | uniq -c | sort -nr` is the standard shape for "what's most common," and getting the order wrong silently corrupts the result
- `tail -f` (not plain `tail`) is required for genuinely live monitoring
- Investigating logs, configs, and the filesystem together — rather than in isolation — is what actually locates a root cause instead of just describing symptoms
- Always think:
  - is this count sorted before I count duplicates?
  - is this edit backed up before I make it?
  - is this search scoped before I run it broadly?