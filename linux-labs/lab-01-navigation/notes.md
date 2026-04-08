# Linux Navigation — Notes

---

## Commands

### pwd
What it does:
Returns the absolute path of the current directory (where I am)

Example:
pwd
→ /Users/hamza/devops-journey/linux-labs/lab-01-navigation

---

### ls
What it does:
Lists contents of a directory

Key behaviour:
- ls → current directory
- ls <path> → specified location
- Does NOT search or guess

Difference:
- ls → current level
- ls -R → full recursive structure

Examples:
ls
ls reports
ls -R

---

### cd
What it does:
Changes current directory

Key usage:
- cd folder → move into folder
- cd .. → move up one level
- cd ../folder → move up then into another folder

Common mistake:
- guessing paths without using ls

Examples:
cd reports
cd ..
cd ../logs
cd ~/devops-journey/linux-labs/lab-01-navigation/reports

---

### mv
What it does:
Moves or renames files

Usage:
- mv source destination → move
- mv old new → rename

When to use:
- relocating files
- renaming files

Examples:
mv reports/file1.txt archive/
mv reports/file2.txt reports/final.txt

---

### cp
What it does:
Copies files

Usage:
- cp source destination

Difference from mv:
- mv moves (original gone)
- cp copies (original stays)

Examples:
cp reports/final.txt archive/
cp drafts/notes.txt archive/backup-notes.txt

---

### rm
What it does:
Deletes files

Risk:
- permanent (no undo)
- must be used carefully

Examples:
rm reports/final.txt
rm drafts/temp.txt

---

### mkdir
What it does:
Creates a new directory

When to use:
- setting up structure
- creating working folders

Examples:
mkdir test-folder
mkdir reports/old

---

### rmdir
What it does:
Removes an empty directory

Rule:
- only works if the directory is empty

Examples:
rmdir test-folder
rmdir reports/old

---

## Concepts

### File System
What it is:
A hierarchical structure of directories and files

Why it matters:
Everything in Linux is organised in this structure

---

### Paths

Relative:
- based on current location
- depends on where I am

Examples:
cd reports
cd ../logs
ls reports

---

Absolute:
- full path from root (~ or /)
- works from anywhere

Example:
cd ~/devops-journey/linux-labs/lab-01-navigation/reports
ls ~/devops-journey/linux-labs/lab-01-navigation/reports

Rule:
Path must exist or it fails

---

## Mental Model

Navigation:
- I always know where I am (pwd)
- I inspect before moving (ls)
- I move using correct paths (cd)

Efficiency:
- avoid step-by-step movement
- use combined paths (cd ../folder)

File operations:
- mv → move/rename
- cp → duplicate
- rm → delete file
- mkdir → create directory
- rmdir → remove empty directory
- always verify with ls

Core rule:
The filesystem only responds to exact paths — nothing is guessed or searched

---

## Summary

- Relative = based on current location
- Absolute = full path from root
- pwd = tells me where I am
- ls = shows what exists at a path
- cd = moves based on path
- mv = move/rename
- cp = copy
- rm = delete file
- mkdir = create directory
- rmdir = remove empty directory
- All commands depend on correct paths