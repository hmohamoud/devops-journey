# Evidence — Lab 06 Process Management and System Monitoring

## Task 1 — Listing Processes

Command I ran:
ps
ps aux
ps -ef

What I expected:
ps would show everything running on the machine

What actually happened:
ps only showed processes in my current terminal session
ps aux showed everything including other users and system processes
ps -ef showed the same but with PPID column which ps aux does not have

What surprised me:
ps aux | grep bash returned an extra line I did not expect
The grep command itself showed up in the results because grep was
searching for the word bash and its own command line contained bash

How I filtered it out:
ps aux | grep [b]ash
or
pgrep bash

---

## Task 3 — Background Jobs

Command I ran:
./process-lab/scripts/long_task.sh &

What I expected:
Terminal would stay blocked like foreground

What actually happened:
Terminal freed up immediately
Got a job number in brackets and the PID printed next to it
Script was running silently in the background

What confused me:
I thought & just runs it faster — I did not realise it completely
detaches it from blocking the terminal

---

## Task 5 — disown vs nohup

Command I ran:
./process-lab/scripts/long_task.sh &
disown

nohup ./process-lab/scripts/long_task.sh > process-lab/logs/nohup_test.log 2>&1 &

What I expected:
Both would do the same thing

What actually happened:
disown detaches an already running background job from the shell
nohup starts the job already detached and immune to SIGHUP
nohup needed output redirection because it has no terminal to print to

Key difference I now understand:
disown = detach after starting
nohup = detach at start

---

## Task 6 — Signals

Command I ran:
kill PID
kill -9 PID
kill -STOP PID
kill -CONT PID

What I expected:
kill and kill -9 would do the same thing

What actually happened:
kill sent SIGTERM — the process had a chance to clean up before dying
kill -9 sent SIGKILL — the process was destroyed immediately with no cleanup
kill -STOP froze the process — it showed as T in the STAT column in ps aux
kill -CONT resumed it exactly where it stopped

Mistake I made:
I used kill -9 first on my second test before trying plain kill
I should always try SIGTERM first because SIGKILL can cause data corruption
if the process was in the middle of writing to a file

---

## Task 8 — System Load

Command I ran:
uptime
nproc

Output I got:
load averages: 0.45 0.38 0.41
nproc returned 4

What I understood:
0.45 is the 1 minute average
0.38 is the 5 minute average
0.41 is the 15 minute average
All three are well below 4 cores so CPU is not a suspect
Trend is flat — not climbing or falling

---

## Task 9 — Memory

Command I ran:
free -h

What confused me at first:
free memory showed 200Mi and I thought the server was nearly out of RAM
I nearly panicked

What I actually learned:
Linux uses spare RAM as disk cache — this is normal and healthy
The number that matters is available not free
available showed 5.8Gi which means plenty of RAM is accessible
swap used was near zero which confirmed RAM was never exhausted

---

## Task 10 — Disk

Command I ran:
df -h
du -sh process-lab/
du -sh process-lab/*

What I learned:
df shows the big picture — which filesystem is full
du shows what is inside — which folder is eating the space
df is the alarm, du is the investigation
I drill with du | sort -rh and follow the biggest item until I hit a file

---

## Break/Fix 1 — Killed the Wrong Process

What I did:
Started two background jobs
Ran ps aux | grep long_task
Saw two PIDs and picked the first one
Killed it
Checked jobs and realised the wrong one was gone

How I found the right one:
Ran pgrep -f long_task.sh which showed both PIDs clearly
Used jobs -l to match job numbers to PIDs
Killed the correct one second time

What I learned:
Always verify the PID before killing
pgrep -f is safer than grepping ps output manually
Never assume the first result is the right one

---

## Break/Fix 2 — Lost Job After Closing Terminal

What I did:
Started long_task.sh with just &
Opened a new terminal
Ran ps -ef | grep long_task
Process was gone

Why it happened:
When the terminal closed it sent SIGHUP to all child processes
The job was still attached to that terminal session
It had no protection against SIGHUP so it died

How to prevent it:
Use disown after starting the job
Or use nohup before starting the job

---

## Biggest Mistake This Lab

Used kill -9 as my default before reading the task properly
Did not realise SIGTERM gives the process a chance to clean up
In production this could corrupt a database write or lose log data

## What Clicked That Did Not Before

The difference between free and available memory
I would have restarted a service unnecessarily based on free alone
Available is what actually matters

## What I Would Do Differently

Always run pgrep -f before pkill -f to see exactly what would be killed
Always try kill before kill -9
Always check available not free when diagnosing memory