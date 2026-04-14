# Linux Editing & Permissions — Notes

---

## Commands

### ls -l
What it does:
Shows detailed file info including permissions and size

Example:
ls -l

Output:
-rwxr-xr--  1 user group  120  date  file

---

### chmod
What it does:
Changes file permissions

Examples:
chmod +x file
chmod -w file
chmod 755 file
chmod 644 file

---

### nano
What it does:
Edits file in terminal

Example:
nano file.txt

---

### cat
What it does:
Displays file contents

Example:
cat file.txt

---

### ./
What it does:
Runs executable file

Example:
./file.sh

---

## Concepts

### File type
- `-` = file  
- `d` = directory  

---

### Permission structure
-rwxr-xr--

Split into:
- owner (first 3)
- group (second 3)
- others (last 3)

---

### Permissions
r = read  
w = write  
x = execute  

---

### Numeric values
r = 4  
w = 2  
x = 1  

Example:
755 = rwx r-x r-x  

---

### What permissions do
No read → can’t view (cat fails)  
No write → can’t edit  
No execute → can’t run  

---

### Execute rule
To run a file:
- file must have execute permission  
- use ./file  

---

## Mental Model

- Always check permissions first using `ls -l`  
- Permissions control what actions are allowed  
- If something fails → it’s usually a permission issue  
- Fix by adding/removing r, w, or x  

---

## Summary

- ls -l → inspect permissions + size  
- chmod → change permissions  
- r/w/x → control access  
- numeric = precise  
- ./file → run executable 
