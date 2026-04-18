# Evidence

## Completed Tasks

- Created lab environment with:
  - `logs/`
  - `data/`
  - `output/`
  - `text-lab/`

- Worked with files:
  - `logs/app.log`
  - `logs/errors.log`
  - `data/users.txt`
  - `data/transactions.txt`
  - generated outputs:
    - `clean_dataset.txt`
    - `error_summary.txt`
    - `frequency_distribution.txt`

- Searched logs using:
  - `grep`
  - `grep -i`
  - `grep -c`

- Counted entries using:
  - `wc -l`

- Analysed duplicates / frequency using:
  - `sort`
  - `uniq`
  - `uniq -c`
  - `uniq -d`

- Used ranking pipelines:
  - `sort -nr`
  - `head -1`

- Found files using:
  - `find . -name`
  - `find . -iname`

- Used wildcards:
  - `data/*.txt`
  - `logs/*.log`
  - `data/c*.txt`

- Monitored logs in real time:
  - `tail -f logs/app.log`
  - `tail -f logs/app.log | grep "ERROR"`

- Copied and moved output files into `text-lab/`

---

## Break/Fix Logs

### Issue 1 — Wrong file path

Problem:  
`wc -l < app.log`

Failed because file not found.

Cause:  
Wrong location.

Diagnosis:  
Checked folder structure.

Fix:  
Used correct path:

`wc -l < logs/app.log`

Prevention:  
Always verify path first.

---

### Issue 2 — Wrong live monitor path

Problem:

`tail -f logs.app`

Failed.

Cause:  
Incorrect filename/path.

Diagnosis:  
Used `ls logs`

Fix:

`tail -f logs/app.log`

Prevention:  
Check names before monitoring.

---

### Issue 3 — Wildcard no matches

Problem:

`ls *.txt`

Returned no matches.

Cause:  
No `.txt` files in current directory.

Diagnosis:  
Checked structure.

Fix:

`ls data/*.txt`

Prevention:  
Wildcards depend on current location.

---

### Issue 4 — Case sensitive grep

Problem:

`grep "error" logs/app.log`

Returned no output.

Cause:  
File used `ERROR`

Diagnosis:  
Recognised case sensitivity.

Fix:

`grep -i "error" logs/app.log`

Prevention:  
Use `-i` when unsure about case.

---

### Issue 5 — Incorrect find target

Problem:

`find . -name "data/users.txt"`

Returned nothing.

Cause:  
`find -name` expects filename pattern, not full path.

Fix:

`find . -name "users.txt"`

Prevention:  
Search by filename unless using path-aware methods.

---

### Issue 6 — Inefficient command usage

Problem:

Used:

`cat logs/app.log | grep "ERROR"`

Worked, but unnecessary.

Cause:  
Extra process used.

Fix:

`grep "ERROR" logs/app.log`

Prevention:  
Use direct commands when possible.

---

### Issue 7 — Duplicate cleaning confusion

Problem:  
Duplicates with different case remained.

Cause:  
`uniq` is case-sensitive.

Fix:

`sort file | uniq -i`

Prevention:  
Case differences matter in datasets.

---

## Key Patterns

- Most errors came from:
  - wrong paths
  - wrong case
  - wildcard assumptions
  - unnecessary command chaining

- What helped me fix them:
  - `ls`
  - `find`
  - understanding current directory
  - understanding case sensitivity

---

## Main Takeaways

- `grep` is essential for searching logs fast
- `grep -c` gives quick counts
- `sort | uniq -c` reveals repeated patterns
- `tail -f` is powerful for live monitoring
- `find` recovers lost files quickly
- wildcards speed up multi-file operations
- efficient commands matter more than long commands
- always ask:
  - what am I trying to find?
  - what command answers that fastest?
