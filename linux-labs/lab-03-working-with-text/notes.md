# Linux Text Processing & System Inspection — Notes

---

## Commands

### grep
What it does:  
Finds lines containing a word/pattern

Examples:
grep "ERROR" logs/app.log
grep "user" data/users.txt

Use when:  
Need to search inside files

---

### grep -i
What it does:  
Finds matches ignoring capital letters

Example:
grep -i "error" logs/app.log

Matches:
error  
Error  
ERROR

Use when:  
Not sure about upper/lowercase

---

### grep -c
What it does:  
Counts lines containing the match

Example:
grep -c "ERROR" logs/app.log

Use when:  
Need number of errors quickly

---

### wc -l
What it does:  
Counts total lines

Examples:
wc -l data/users.txt
wc -l < data/users.txt

Use when:  
Need total rows / entries

---

### sort
What it does:  
Puts lines in order

Example:
sort data/users.txt

Use when:  
Need organised output

---

### sort -r
What it does:  
Reverse order

Example:
sort -r file.txt

Use when:  
Need Z → A

---

### sort -n
What it does:  
Sorts numbers lowest → highest

Example:
sort -n data/transactions.txt

Use when:  
Working with numbers

---

### sort -nr
What it does:  
Sorts numbers highest → lowest

Example:
sort -nr data/transactions.txt

Use when:  
Need biggest values first

---

### uniq
What it does:  
Removes duplicates only if sorted

Example:
sort data/users.txt | uniq

Use when:  
Need one clean copy of each item

---

### uniq -c
What it does:  
Counts repeats only if sorted

Example:
sort data/users.txt | uniq -c

Use when:  
Need frequency counts

---

### uniq -d
What it does:  
Shows duplicates only if sorted

Example:
sort data/users.txt | uniq -d

Use when:  
Need repeated entries only

---

### head
What it does:  
Shows first lines

Examples:
head file.txt
head -1 file.txt

Use when:  
Need first result / preview

---

### tail
What it does:  
Shows last lines

Examples:
tail file.txt
tail -5 file.txt

Use when:  
Need latest entries

---

### tail -f
What it does:  
Live watches a file

Example:
tail -f logs/app.log

Use when:  
Watching logs in real jobs

---

### find
What it does:  
Searches for files/folders

Examples:
find . -name "*.txt"
find . -name "*.log"

Use when:  
Need lost files fast

---

### find -iname
What it does:  
Searches ignoring capital letters

Example:
find . -iname "*.TXT"

---

### ls -lh
What it does:  
Shows file sizes clearly

Example:
ls -lh

Use when:  
Need biggest files

---

## Concepts

### Pipe |

What it does:  
Sends output into next command

Example:
grep "ERROR" logs/app.log | wc -l

Means:  
Search first → count second

---

### Wildcard *

What it does:  
Matches many names

Examples:
*.txt
logs/*.log
data/*.txt

Use when:  
Know pattern, not exact file

---

## Real Job Patterns

### Count errors

Pattern:
grep -c "ERROR" logs/app.log

Used for:
Quick checks in logs

---

### Search then count

Pattern:
grep "ERROR" logs/app.log | wc -l

Used for:
Counting results another way

---

### Repeated errors

Pattern:
grep "ERROR" logs/app.log | sort | uniq -c

Used for:
See repeated failures

---

### Most common error

Pattern:
grep "ERROR" logs/app.log | sort | uniq -c | sort -nr | head -1

Used for:
Find main issue first

---

### Clean dataset

Pattern:
sort users.txt | uniq > clean.txt

Used for:
Remove duplicates

---

### Duplicate users

Pattern:
sort users.txt | uniq -d

Used for:
Find bad/repeated data

---

### Highest transactions

Pattern:
sort -nr transactions.txt | head

Used for:
Largest values first

---

### Live failures only

Pattern:
tail -f logs/app.log | grep "ERROR"

Used for:
Watch production issues live

---

### Find all text files

Pattern:
find . -name "*.txt"

Used for:
Locate files quickly

---

## Decision Making

Need to search text?  
→ grep

Need count only?  
→ grep -c  
or wc -l

Need organise lines?  
→ sort

Need duplicates removed?  
→ sort | uniq

Need repeat counts?  
→ sort | uniq -c

Need biggest count first?  
→ ... | sort -nr

Need latest logs?  
→ tail

Need live logs?  
→ tail -f

Need lost file?  
→ find

Need many files at once?  
→ *

---

## Debugging

No output?

Check:
- wrong path
- wrong spelling
- wrong case
- no match exists

Fix:
grep -i "word" file

---

uniq not working?

Cause:
File not sorted

Fix:
sort file | uniq

---

Numbers sorted wrong?

Cause:
Used normal sort

Fix:
sort -n
or
sort -nr

---

Wildcard failed?

Cause:
Wrong folder / no matches

Fix:
ls data/*.txt

---

## Speed Rules

Bad:
cat huge.log then scroll

Good:
grep "ERROR" huge.log

---

Bad:
Count by eye

Good:
grep -c "ERROR" huge.log

---

Bad:
Look for duplicates manually

Good:
sort file | uniq -d

---

## Mental Model

Ask question first.

Need text?  
→ grep

Need count?  
→ grep -c / wc -l

Need order?  
→ sort

Need duplicates?  
→ uniq

Need live logs?  
→ tail -f

Need file location?  
→ find

Then combine tools.

---

## Summary

- grep = find text
- grep -i = ignore case
- grep -c = count matching lines
- wc -l = count total lines
- sort = put in order
- sort -nr = biggest numbers first
- uniq = remove duplicates if sorted
- uniq -c = count repeats if sorted
- uniq -d = duplicates only if sorted
- head = first lines
- tail = last lines
- tail -f = live watch file
- find = locate files
- * = many matching names
- | = chain commands
