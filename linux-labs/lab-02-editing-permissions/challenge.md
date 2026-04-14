# Challenge — Editing & Permissions (No Hints Mode)

## Rules

- No notes
- No copying
- Use only the terminal
- Verify everything with `ls -l`
- If something fails → explain why before fixing
- Do not skip failures

---

## Challenge 1 — Read Permissions

Given:

-rw-r--r-- file1.txt  
-rwxr-xr-- script.sh  

Explain:
- what each group can do
- which file can be executed and why

---

## Challenge 2 — Silent Failure

You try:

./deploy.sh

It fails.

Fix it without looking at notes.

---

## Challenge 3 — Lock Yourself Out

Take a file and:
- remove your ability to read it
- confirm it fails
- restore access

Explain what changed.

---

## Challenge 4 — Exact Permission Target

Create a file where:
- owner can read + write
- group can only read
- others have no access

Verify using `ls -l`

---

## Challenge 5 — Overexposed File

You accidentally set:
chmod 777 file.txt

Tasks:
- explain the risk
- fix it to a normal safe permission
- verify the fix

---

## Challenge 6 — Editing Failure

Try to edit a file but it fails.

Tasks:
- identify the missing permission
- fix it
- confirm editing works

---

## Challenge 7 — Script Execution

Create a script:
- add content
- attempt to run it (fail first)
- fix it properly
- run successfully

---

## Challenge 8 — Mixed System Debug

You are given:

configs/app.conf  
scripts/run.sh  

Problems:
- app.conf cannot be edited
- run.sh cannot be executed

Fix both without guessing.

---

## Challenge 9 — Real Navigation + Permissions

From a different directory:
- locate your lab folder
- inspect permissions of a file
- modify it without entering unnecessary directories

---

## Final Check (No Thinking)

Answer instantly:

- What does rwxr-xr-- mean?
- Why does ./file fail?
- Difference between 755 and 644?
- What’s the FIRST command you run when something fails?

If you hesitate → redo the lab
