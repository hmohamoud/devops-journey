cat > evidence.md <<'EOF'
# Evidence

## Completed Tasks
- Created the lab directory structure: `logs/`, `reports/`, `drafts/`, `scripts/`, `archive/`
- Created initial files: `logs/system.log`, `reports/todo.txt`, `drafts/notes.txt`
- Used `pwd`, `ls`, and `ls -R` to inspect location and structure
- Navigated between directories using:
  - normal movement (`cd folder`, `cd ..`)
  - relative paths (`cd ../reports`, `cd ../drafts`)
  - absolute paths (`cd ~/devops-journey/linux-labs/lab-01-navigation/reports`)
- Created files with `touch`
- Moved and renamed files with `mv`
- Copied files with `cp`
- Deleted files with `rm`
- Created and removed directories with `mkdir` and `rmdir`
- Added content to a file correctly using:
  - `echo "Hello World" >> drafts/notes.txt`

---

## Break/Fix Logs

### Issue 1 — Wrong relative navigation
Problem:
Tried to move from `archive` to `reports` using `cd reports`

Cause:
`reports` was not inside `archive`; it was a sibling directory

Diagnosis:
Checked current location with `pwd` and understood the directory structure

Fix:
Used:
`cd ../reports`

Prevention:
When moving between sibling folders, go up one level first with `..`

---

### Issue 2 — Wrong absolute path
Problem:
Tried:
`cd ~/devops-journey/lab-01-navigation/reports`

Cause:
Missed the `linux-labs/` directory in the full path

Diagnosis:
Used `ls`, `ls -R`, and inspected the actual structure from `devops-journey`

Fix:
Used:
`cd ~/devops-journey/linux-labs/lab-01-navigation/reports`

Prevention:
Build the absolute path from the real directory structure, not memory alone

---

### Issue 3 — Incorrect `mv` syntax
Problem:
Tried:
`mv reports/file1.txt > archive`

Cause:
Used `>` instead of passing the destination as a normal argument

Diagnosis:
The `mv` usage output showed the command syntax was wrong

Fix:
Used:
`mv reports/file1.txt archive/`

Prevention:
`mv` syntax is:
`mv source destination`

---

### Issue 4 — Renaming a file that did not exist
Problem:
Tried:
`mv archive/file.txt archive/ameen.txt`

Cause:
The real file name was `file1.txt`, not `file.txt`

Diagnosis:
Checked contents with:
`ls archive`

Fix:
Used:
`mv archive/file1.txt archive/hamza.txt`

Prevention:
Always verify actual filenames with `ls` before renaming

---

### Issue 5 — Incorrect `echo` syntax created unintended files
Problem:
Tried:
`echo > "My name is Hamza" drafts/notes.txt`
and
`echo >> "Hello World" drafts/notes.txt`

Cause:
The order of `echo`, text, redirection, and target file was wrong

Diagnosis:
Used `ls` and noticed unexpected files were created in the current directory

Fix:
Removed unintended files and used:
`echo "Hello World" >> drafts/notes.txt`

Prevention:
Correct pattern:
- append: `echo "text" >> file`
- overwrite: `echo "text" > file`

---

### Issue 6 — Trying to access files from the wrong location
Problem:
Inside `logs/`, tried:
`cat README.md`

Cause:
`README.md` was not inside `logs`; it was one level up

Diagnosis:
Used current location awareness and path reasoning

Fix:
Used:
`cat ../README.md`

Prevention:
Use relative paths based on current directory, not assumptions

---

## Key Patterns

- Most errors came from:
  - incorrect paths
  - wrong command syntax
  - assuming a file/folder existed without verifying

- What helped me fix them:
  - using `pwd` to confirm location
  - using `ls` / `ls -R` to inspect structure
  - slowing down and checking exact filenames before acting

---

## Main Takeaways
- Paths are everything in navigation
- `ls` should be used before guessing
- `pwd` keeps location awareness high
- `mv` can both move and rename
- `echo` redirection syntax must be exact
- Errors are useful if I diagnose them properly
EOF