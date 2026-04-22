# Shell I/O, Redirection & Command Control — Notes

---

## Core Patterns (memorise these)

>  overwrite output → file  
>> append output → file  
<  file → command input  

2>   errors → file  
2>>  append errors → file  
2>&1 output + errors → same place  

|    send output → next command  

$(...)   run command → inject result  
<(... )  run command → use output as file  

---

## Commands

### >
What it does:  
Overwrite output into a file  

Example:
ls -l > output.txt  

Use when:  
Clean output, no terminal noise  

---

### >>
What it does:  
Append output into a file  

Example:
echo "ERROR" >> logs/app.log  

Use when:  
Keeping logs/history  

---

### <
What it does:  
Feed file content into command  

Example:
wc -l < data/users.txt  

Use when:  
Cleaner scripting (no filename printed)  

---

### 2>
What it does:  
Redirect errors only  

Example:
ls wrongfile 2> errors.txt  

Use when:  
Debugging failures  

---

### 2>&1
What it does:  
Combine output + errors  

Example:
command > output.txt 2>&1  

Use when:  
Production logging  

---

### |
What it does:  
Chain commands  

Example:
grep "ERROR" logs/app.log | wc -l  

Use when:  
Processing output step by step  

---

### $(...)
What it does:  
Run command → inject result  

Example:
echo "Users: $(wc -l < data/users.txt)"  

Use when:  
Dynamic output inside commands  

---

### <(...)
What it does:  
Run command → treat output like file  

Example:
diff <(sort a.txt) <(sort b.txt)  

Use when:  
Compare without temp files  

---

## Environment & System

### PATH
What it is:  
List of directories the shell checks to find commands  

Example:
echo $PATH  

If command not in PATH → command not found  

---

### env
What it does:  
Shows all environment variables  

Example:
env  

---

### Local Variable
What it is:  
Only exists in current shell  

Example:
name="Hamza"  
echo $name  

Child shell cannot see it  

---

### Export Variable
What it is:  
Shared with child processes  

Example:
export project="devops"  

Test:
bash  
env | grep project  

---

### sudo
What it does:  
Run command as root  

Example:
sudo apt update  

Use when:
- install software  
- modify system files  
- change permissions  

Risk:
Can break system → don’t use blindly  

---

### Help

Quick syntax:
command --help  

Full explanation:
man command  

---

## Real Job Patterns

Save output:
command > file.txt  

Append logs:
command >> file.txt  

Input cleanly:
wc -l < file.txt  

Errors only:
command 2> errors.txt  

Everything logged:
command > file.txt 2>&1  

Dynamic output:
echo "Users: $(wc -l < file.txt)"  

Compare outputs:
diff <(sort a.txt) <(sort b.txt)  

---

## Decision Making

Need clean output → >  
Need to keep logs → >>  
Need file input → <  
Need errors only → 2>  
Need everything → 2>&1  
Need chaining → |  
Need dynamic result → $(...)  
Need command output as file → <(...)  

---

## Debugging

Output missing → redirected to file  

File wiped → used > instead of >>  

Errors still showing → didn’t use 2>  

Command not found → PATH issue  

Variable missing → not exported  

Stop command → Ctrl + C  

---

## Mental Model

Commands have:
- output (stdout)
- errors (stderr)
- input (stdin)

You control:
- where output goes  
- where errors go  
- what input feeds it  
- how commands connect  

---

## Summary

> overwrite  
>> append  
< input  
2> errors  
2>&1 everything  
| chain  
$(...) inject result  
<(... ) use output as file  

PATH → where commands are found  
env → show variables  
export → share variable  
sudo → root access