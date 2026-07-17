# Advanced Log Analysis & Configuration Management — Notes

---

## Core Tools

| Tool | Purpose |
|---|---|
| `grep` | search text for a pattern, print matching lines |
| `awk` | split a line into fields (columns) and operate on them |
| `cut` | split a line into fields using one fixed delimiter |
| `sed` | edit text — delete lines, replace text, strip patterns |
| `sort` | order lines alphabetically or numerically |
| `uniq` | collapse adjacent duplicate lines, optionally count them |
| `find` | locate files by name, size, age, or permissions |
| `tee` | show output on screen and save it to a file at the same time |
| `xargs` | take piped input and feed it as arguments to another command |

---

## `grep` — Search and Filter

### What it does

Searches text for a pattern and prints the lines that match.

### Example

`grep "ERROR" app.log`

Prints every line containing the word ERROR.

### Key flags

| Flag | Meaning |
|---|---|
| `-i` | ignore case — matches ERROR, error, Error, eRRor |
| `-c` | print a count of matching lines instead of the lines themselves |
| `-v` | invert the match — print lines that do NOT contain the pattern |
| `-E` | enable extended regex, allowing `|` for "this OR that" |
| `-r` | search recursively through a directory of files |

### Example: case sensitivity

`grep "ERROR" app.log | wc -l` → counts only exact uppercase `ERROR`

`grep -i "ERROR" app.log | wc -l` → counts `ERROR`, `error`, `Error`, etc.

The two counts differ whenever the file contains the same word in different cases. This lab's log has lines like `error payment processing failed` (lowercase) sitting alongside `ERROR Payment gateway timeout` (uppercase) — `-i` catches both, plain `grep` catches only the uppercase ones.

### grep's limitation

`grep` finds lines. It does not understand columns. If you need a specific field on a line (the 9th value on an nginx line, for example), `grep` cannot isolate it — that is `awk`'s job.

---

## `awk` — Extract Columns and Count

### What it does

Reads a line, splits it into fields by a delimiter (whitespace by default), and lets you act on individual fields, count things, or apply conditions.

### Fields

Inside awk:

- `$0` = the whole line
- `$1` = first field
- `$2` = second field
- `$9` = ninth field, and so on

### Example

nginx log line:

```text
192.168.1.1 - - [01/Jun/2026:10:04:11 +0000] "GET /api/payments HTTP/1.1" 503 256
```

Because this line has spaces, awk splits it into separate fields:

- `$1` = `192.168.1.1`
- `$7` = `/api/payments`
- `$9` = `503`

`awk '{print $9}' nginx.log` prints just the status code column for every line.

### Field equality vs substring matching

`awk '$9 == 503'` matches only lines where the 9th field is **exactly** `503`.

`grep "503"` matches the string `503` **anywhere on the line** — including inside a byte-count field, a timestamp, or an IP address. This is why `grep "503"` can silently over-count: it might match `1503` bytes transferred, not just a 503 status code. Field-exact awk matching avoids that trap entirely.

### Combining conditions

`awk '$9 == 503 && $7 == "/api/payments"'` — both conditions must be true (`&&` = AND).

`awk '$9 == 500 || $9 == 503'` — either condition can be true (`||` = OR).


---

## `cut` — Simple Fixed-Delimiter Extraction

### What it does

Splits a line on one delimiter you specify and prints the field(s) you ask for. It cannot apply conditions or do math — it only extracts.

### Example

`cut -d= -f1 app.conf` → prints everything before the first `=` on each line (the key)

`cut -d= -f2 app.conf` → prints everything after the first `=` (the value)

`cut -d: -f1 /etc/passwd` → prints the first field of a colon-delimited file (the username)


---

## `sed` — Stream Editor

### What it does

Edits text: deletes lines, replaces text, and can save changes safely with a backup.

### Removing comments and blank lines

`sed '/^#/d' app.conf` — deletes any line starting with `#`

`sed '/^$/d' app.conf` — deletes any completely empty line

`sed '/^$/d; /^#/d' app.conf` — does both in one pass, semicolon-separated

### Find and replace

`sed 's/WORKERS=2/WORKERS=8/' app.conf` — prints the file to the screen with the change applied, but does **not** save it. This is a safe preview.

### Saving changes — always with a backup

`sed -i.bak 's/WORKERS=2/WORKERS=8/' app.conf` 

- `-i.bak` edits the file in place **and** creates `app.conf.bak` holding the original, untouched content, before making the change
- Without `.bak` (just `-i` alone), the original is gone the moment the command runs — there is no undo
- Verify the live file changed: `grep "WORKERS=8" app.conf`
- Verify the backup preserved the old value: `grep "WORKERS=2" app.conf.bak`

### Multiple replacements in one command

```bash
sed -i.bak -e 's/MAX_POOL_SIZE=10/MAX_POOL_SIZE=50/' -e 's/IDLE_TIMEOUT=300/IDLE_TIMEOUT=600/' database.conf
```

Each `-e` adds another edit expression to the same command, applied in sequence, saved once, backed up once.

---

## `sort` and `uniq` — Frequency Counting

### The pattern

`uniq -c` only collapses **adjacent** duplicate lines — it does not look through the whole file. That means the input must be sorted first, or identical lines that aren't next to each other won't be grouped.

```bash
sort file.txt | uniq -c | sort -nr
```

1. `sort` — puts identical lines next to each other
2. `uniq -c` — collapses each group into one line, prefixed with its count
3. `sort -nr` — re-sorts by that count, numerically (`-n`), highest first (`-r`)

`sort -u` is a shortcut for "sort, then keep only one copy of each line" — equivalent to `sort | uniq` in one step, useful when you just need the unique count, not the frequency of each.

---

## `find` — Locate Files

### What it does

Searches a directory tree for files matching a condition — name, age, size, or permissions.

### Common conditions

| Command | Meaning |
|---|---|
| `find ops-lab/ -name "*.log"` | files ending in `.log` |
| `find ops-lab/ -name "*.conf"` | files ending in `.conf` |
| `find ops-lab/ -mtime -1` | modified in the last 24 hours (`-` = less than) |
| `find ops-lab/ -mtime +30` | modified more than 30 days ago (`+` = more than) |
| `find ops-lab/ -perm 777` | files with world-readable/writable/executable permissions |
| `find ops-lab/ -size +100M` | files larger than 100 megabytes |
| `find ops-lab/ -name "*.sh"` | shell scripts |

### Finding the biggest files

`find ops-lab/ -type f | xargs du -sh | sort -rh`

- `find -type f` lists every regular file
- `xargs` takes that list and feeds each filename as an argument into `du -sh` (disk usage, human-readable)
- `sort -rh` sorts human-readable sizes (like `4.2M`, `800K`) largest first

---

## `tee` — Watch and Save at the Same Time

### What it does

Takes input from a pipe, prints it to the screen, and writes it to a file simultaneously — you don't have to choose between watching output live and keeping a copy.

### Live example

```bash
tail -f app.log | grep -i "error" | tee live-errors.log
```

- `tail -f` streams new lines as they're appended
- `grep -i "error"` filters to only error lines
- `tee` shows those filtered lines on screen and writes them to `live-errors.log`

### `tee` vs `tee -a`

Plain `tee file.txt` **overwrites** the file every time the command starts fresh. If you stop and restart the monitor, the previous run's saved errors are wiped out.

`tee -a file.txt` **appends** instead — new output is added to the end of the file, and everything captured in earlier runs stays intact.

---

## Decision Guide

| Need | Use |
|---|---|
| Search for a pattern in text | `grep` |
| Pull out a specific column with a condition or count | `awk` |
| Pull out a column with a fixed delimiter, no condition | `cut` |
| Delete lines or replace text safely | `sed -i.bak` |
| Rank items by how often they occur | `sort \| uniq -c \| sort -nr` OR an awk associative array |
| Find files by name/age/size/permission | `find` |
| Watch live output and save it without losing history | `tail -f \| grep \| tee -a` |
| Feed a list of files into another command | `xargs` |

---

## Debugging Guide

| Problem | Likely cause |
|---|---|
| `awk '{print $1}'` on a config file returns the whole line | no delimiter set — awk defaults to splitting on whitespace, and `KEY=VALUE` has no spaces; add `-F=` |
| `grep "503"` count looks too high | `grep` matched `503` inside another field (bytes, timestamp); use `awk '$9 == 503'` for exact field matching |
| `uniq -c` gives wrong duplicate counts | input wasn't sorted first — `uniq` only merges adjacent duplicates |
| Config edit destroyed the original | used `sed -i` without `.bak` — no backup existed |
| Live monitor's saved file is empty after a restart | used `tee` instead of `tee -a`, which overwrote it |
| `find /` floods the terminal | permission-denied errors weren't suppressed — add `2>/dev/null` |
| Pipeline gives wrong counts | stages are in the wrong order — `sort` must come before `uniq -c`, and `uniq -c` before the second `sort -nr` |

---

## Final Summary

| Command / Symbol | Meaning |
|---|---|
| `grep -i` | case-insensitive search |
| `grep -c` | count of matching lines |
| `awk '{print $N}'` | print field N (splits on whitespace by default) |
| `awk -F=` | split fields on `=` instead of whitespace |
| `awk '$N == value'` | exact field match |
| `awk '... && ...'` / `awk '... \|\| ...'` | AND / OR conditions |
| `awk '{count[x]++} END{...}'` | count occurrences with an associative array |
| `cut -d= -f1` | extract field 1, splitting on `=` |
| `sed '/^#/d'` | delete comment lines |
| `sed '/^$/d'` | delete blank lines |
| `sed -i.bak 's/old/new/'` | replace text, save, and keep a backup |
| `sort \| uniq -c \| sort -nr` | rank by frequency, highest first |
| `sort -u` | unique lines, sorted |
| `find -mtime -1` / `+30` | modified within / older than N days |
| `find -size +100M` | files larger than 100MB |
| `2>/dev/null` | discard error output only |
| `tee file` | show and save, overwriting each run |
| `tee -a file` | show and save, appending across runs |
| `xargs` | pass piped input as arguments to another command |