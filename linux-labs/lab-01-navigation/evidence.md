cat > evidence.md <<'EOF'
# Evidence

## Completed Tasks
- Built lab structure: `logs/`, `reports/`, `drafts/`, `scripts/`, `archive/`
- Created files: `logs/system.log`, `reports/todo.txt`, `drafts/notes.txt`
- Verified structure using: `pwd`, `ls`, `ls -R`
- Navigated using:
  - basic movement (`cd`, `cd ..`)
  - relative paths (`cd ../reports`, `cd ../drafts`)
  - absolute paths (`cd ~/devops-journey/linux-labs/lab-01-navigation/reports`)
- Performed file operations:
  - create → `touch`
  - move/rename → `mv`
  - copy → `cp`
  - delete → `rm`
  - directory management → `mkdir`, `rmdir`
- Modified file content using:
  - `echo "Hello World" >> drafts/notes.txt`

---

## Break/Fix Logs

### Issue 1 — Incorrect relative navigation

Command:
`cd reports`

Expected:
Move from `archive` → `reports`

Actual:
Failed

Error:
`cd: no such file or directory`

Why:
`reports` is not inside `archive` (it is a sibling)

Fix:
`cd ../reports`

Lesson:
Sibling movement = go up (`..`) → then enter target

---

### Issue 2 — Invalid absolute path

Command:
`cd ~/devops-journey/lab-01-navigation/reports`

Expected:
Navigate to reports

Actual:
Failed

Error:
`no such file or directory`

Why:
Missing `linux-labs/` in full path

Fix:
`cd ~/devops-journey/linux-labs/lab-01-navigation/reports`

Lesson:
Absolute paths must match the exact filesystem — no guessing

---

### Issue 3 — Wrong `mv` syntax

Command:
`mv reports/file1.txt > archive`

Expected:
Move file into archive

Actual:
Failed

Error:
`mv` usage output

Why:
Used shell redirection (`>`) instead of argument

Fix:
`mv reports/file1.txt archive/`

Lesson:
`mv` syntax:
`mv source destination`

---

### Issue 4 — Renaming non-existent file

Command:
`mv archive/file.txt archive/ameen.txt`

Expected:
Rename file

Actual:
Failed

Error:
File not found

Why:
Incorrect filename (`file.txt` ≠ `file1.txt`)

Fix:
`mv archive/file1.txt archive/hamza.txt`

Lesson:
Always confirm filenames with `ls` before acting

---

### Issue 5 — Incorrect `echo` redirection

Command:
`echo > "My name is Hamza" drafts/notes.txt`

Expected:
Write text into file

Actual:
Created unintended files

Error:
Misused redirection syntax

Why:
Incorrect order of text and redirection

Fix:
`echo "Hello World" >> drafts/notes.txt`

Lesson:
- append → `>>`
- overwrite → `>`
- format must be exact

---

### Issue 6 — Accessing file from wrong location

Command:
`cat README.md`

Expected:
Display file

Actual:
Failed

Error:
`No such file or directory`

Why:
File not in current directory

Fix:
`cat ../README.md`

Lesson:
Paths are always relative to current location unless absolute

---

## Key Patterns

Common failure points:
- incorrect paths
- wrong command syntax
- assumptions without verification

What resolved issues:
- `pwd` → confirm location
- `ls` / `ls -R` → inspect structure
- verifying before executing

---

## Core Takeaways

- Paths control everything in Linux
- Never guess — verify with `ls`
- `pwd` maintains spatial awareness
- `mv` = move + rename
- `echo` requires precise syntax
- Errors are signals — not problems
EOF
