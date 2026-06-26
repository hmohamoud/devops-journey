# Lab 06 — Process Management & System Monitoring

## Objective

Develop the ability to inspect, control, and reason about running processes and system resources on a Linux machine.

This lab exists to turn you from someone who writes scripts in isolation into someone who can answer the question every on-call engineer eventually gets asked: **"the server is slow, what's going on?"**

By the end of this lab, you must be able to:

- list and interpret running processes
- distinguish foreground and background jobs
- move jobs between foreground and background
- send signals to processes correctly
- kill a misbehaving process safely
- detach a long-running process from your terminal session
- read system load, memory, and disk usage
- use process substitution correctly
- explain what a PID and PPID are
- diagnose "why is this server slow" using only built-in tools

---

## Scenario

You are a junior DevOps engineer who just got paged. A teammate says:

> "Something on the server is using all the CPU and we don't know what."

You don't have a fancy monitoring dashboard yet. You have SSH access and the terminal. This lab trains you to handle that page using nothing but standard Linux tools.

In production, weak process awareness causes:

- killing the wrong process
- restarting a service that wasn't actually the problem
- losing a long-running job because it was tied to a terminal session that closed
- missing the real resource bottleneck because you didn't check memory, disk, and CPU separately
- sending the wrong signal and causing data loss

A good engineer:

- checks before acting
- knows the difference between a soft kill and a hard kill
- never blindly runs `kill -9`
- can read `ps`, `top`, `free`, `df`, and `uptime` output fluently
- understands that closing a terminal can kill a job unless it was detached properly

This lab trains that standard.

---

## Production Framing

Process management and system monitoring are the foundation of incident response in any cloud or DevOps role.

Before you can build automated health checks, alerting, or deployment tooling, you need to be fluent in reading what a system is actually doing right now.

This lab prepares you directly for:

- Mini Project 2 — Server Health Check Reporter
- on-call incident response
- diagnosing resource exhaustion (CPU, memory, disk)
- safely managing long-running background jobs
- service troubleshooting (later labs)

The goal is not to memorise flags. The goal is to build the instinct: **see a symptom → check the right tool → form a hypothesis → confirm it → act.**

---

## Mandatory Rules

- Do not run `kill -9` as your first move. Always try a normal `kill` first and explain why.
- Before running any command, predict what you expect to see.
- After running it, verify what you actually saw and compare.
- Every background job you create must be intentionally managed — checked, brought to foreground, or properly detached.
- You must explain the difference between a process and a job.
- You must explain PID vs PPID for at least one real process on your machine.
- Record every mistake and fix in `evidence.md`.
- Do not move on if you cannot explain a command without looking at notes.

---

## Environment Setup

Create this structure inside the lab folder:

```text
process-lab/
├── scripts/
├── logs/
└── output/
```

Create one long-running test script to practise on:

```text
process-lab/scripts/long_task.sh
```

This script must:

- print a message every 2 seconds for at least 60 seconds
- include a clear identifying message like `Long task running, PID: $$`

You will use this script throughout the lab to practise job control, signals, and process inspection.

Verify setup with:

```bash
pwd
ls -R process-lab
```

Pass condition:

- `process-lab/` exists with all three folders
- `long_task.sh` exists and is executable
- Running it produces visible repeated output

---

## Task 1 — Listing and Reading Processes

Run:

```bash
ps
ps aux
ps -ef
```

Pass condition:

- You can explain the difference between plain `ps` and `ps aux`
- You can identify the PID column, the CPU% column, and the command column in `ps aux` output
- You can find your own shell's PID using `ps` and confirm it with `echo $$`

Then run:

```bash
ps aux | grep bash
```

Pass condition:

- You can explain why this command returns at least one extra line you didn't expect (the grep process itself)
- You know at least two ways to filter it out

---

## Task 2 — PID and PPID

Run:

```bash
echo $$
ps -ef | grep $$
```

Then start a subshell:

```bash
bash
echo $$
echo $PPID
exit
```

Pass condition:

- You can explain what a PID is
- You can explain what a PPID is
- You can explain why the subshell's PPID matches your original shell's PID
- You can explain this in one sentence: "Every process except the very first one has a parent."

---

## Task 3 — Foreground and Background Jobs

Run your long-running script in the foreground first:

```bash
./process-lab/scripts/long_task.sh
```

Pass condition:

- You confirm your terminal is blocked while it runs
- You stop it with `Ctrl+C` and can explain what signal that sends

Now run it in the background:

```bash
./process-lab/scripts/long_task.sh &
```

Pass condition:

- Your terminal is immediately free
- You can explain what the `&` does

Check your background jobs:

```bash
jobs
jobs -l
```

Pass condition:

- You can explain the job number shown in brackets
- You can explain the difference between the job number and the PID

---

## Task 4 — Moving Jobs Between Foreground and Background

With your background job still running from Task 3:

```bash
fg
```

Pass condition:

- The job comes to the foreground and you can see it printing in real time
- You can explain what `fg` does

Suspend it without killing it:

```bash
Ctrl+Z
```

Pass condition:

- You can explain the difference between `Ctrl+Z` and `Ctrl+C`
- You can explain that the process is stopped, not terminated

Check its state:

```bash
jobs
```

Pass condition:

- You can identify the job as `Stopped`

Resume it in the background:

```bash
bg
```

Pass condition:

- The job resumes running but your terminal stays free
- You can explain what `bg` does

---

## Task 5 — Disowning and Detaching Jobs

Start another background job:

```bash
./process-lab/scripts/long_task.sh &
```

Detach it from your shell so it survives even if your terminal closes:

```bash
disown
```

Pass condition:

- You can explain what `disown` does
- You can explain why a normal background job dies if you close the terminal, but a disowned one does not

Now test `nohup` as an alternative approach:

```bash
nohup ./process-lab/scripts/long_task.sh > process-lab/logs/nohup_test.log 2>&1 &
```

Pass condition:

- You can explain what `nohup` does
- You can explain the difference between `disown` and `nohup`
- You can explain why output had to be redirected in the `nohup` example

---

## Task 6 — Signals

Run a fresh long-running job:

```bash
./process-lab/scripts/long_task.sh &
```

Get its PID:

```bash
jobs -l
```

Send a termination signal:

```bash
kill PID
```

Pass condition:

- The job stops
- You can explain that plain `kill` sends SIGTERM, a polite request to stop
- You can explain what "clean up before dying" means — what a process might actually do when it receives SIGTERM

Run another job and this time send a hard kill:

```bash
./process-lab/scripts/long_task.sh &
kill -9 PID
```

Pass condition:

- You can explain that `-9` sends SIGKILL, which cannot be caught or ignored by the process
- You can explain why SIGTERM should always be tried first
- You can explain one real risk of always using `kill -9`

Run another job and freeze it without killing it:

```bash
./process-lab/scripts/long_task.sh &
kill -STOP PID
```

Check its state with `ps aux`. Then resume it:

```bash
kill -CONT PID
```

Pass condition:

- You can identify what the STAT column shows for a stopped process
- You can explain the difference between SIGSTOP and SIGKILL
- You can explain when you'd use SIGSTOP instead of SIGTERM

---

## Task 7 — Finding and Killing Processes by Name

Start three background jobs:

```bash
./process-lab/scripts/long_task.sh &
./process-lab/scripts/long_task.sh &
./process-lab/scripts/long_task.sh &
```

Find them all by name:

```bash
pgrep -f long_task.sh
```

Pass condition:

- You see three PIDs
- You can explain what `pgrep -f` does and why `-f` was needed here
- You can explain why you'd run `pgrep -f` before running `pkill -f`

Kill them all at once:

```bash
pkill -f long_task.sh
```

Pass condition:

- All three jobs are gone
- You can confirm with `jobs` and `pgrep -f long_task.sh` returning nothing
- You can explain the risk of `pkill` if your search pattern is too broad

---

## Task 8 — System Load and Uptime

Run:

```bash
uptime
nproc
```

Pass condition:

- You can identify the three load average numbers and which time window each represents
- You can explain why the raw number means nothing without comparing it to `nproc`
- You can determine whether CPU is a suspect on your machine right now and explain your reasoning
- You can read the trend (climbing / falling / flat) and explain what each means for urgency

---

## Task 9 — Memory Usage

Run:

```bash
free -h
```

Pass condition:

- You can identify total, used, free, and available memory
- You can explain why "free" is almost always low on Linux and why that is not a problem
- You can explain what "available" actually means and why it's the number that matters
- You can explain what high swap usage tells you about the system

---

## Task 10 — Disk Usage

Run:

```bash
df -h
```

Pass condition:

- You can identify which filesystem your home directory lives on
- You can identify the percentage used for each filesystem
- You can explain what happens to a system when a disk reaches 100%

Then run:

```bash
du -sh process-lab/
du -sh process-lab/*
```

Pass condition:

- You can explain the difference between `df` (filesystem-level) and `du` (directory/file-level)
- You can identify which subfolder of `process-lab/` is using the most space
- You can explain when you'd reach for `df` versus `du`

---

## Task 11 — Process Substitution

Create two slightly different versions of a file list:

```bash
ls process-lab/scripts > process-lab/output/list1.txt
ls process-lab/scripts process-lab/logs > process-lab/output/list2.txt
```

Compare them using process substitution instead of temp files:

```bash
diff <(ls process-lab/scripts) <(ls process-lab/scripts process-lab/logs)
```

Pass condition:

- You can explain what `<(...)` does and what the shell actually creates behind the scenes
- You can explain why this avoids creating temporary files
- You can explain the difference between `<(...)` and `$(...)`
- You can give one other use case where `<(...)` is the right tool

---

## Task 12 — Full Diagnostic Drill

This is the final drill for the lab.

Create:

```text
process-lab/scripts/health_snapshot.sh
```

The script must:

1. Print a report title and timestamp
2. Print system uptime and load average
3. Print memory usage (`free -h`)
4. Print disk usage (`df -h`)
5. Print the top 5 processes by CPU usage
6. Print the top 5 processes by memory usage
7. Save the full report into `process-lab/output/health-snapshot-TIMESTAMP.txt`
8. Print where the report was saved

Hint for top processes by CPU:

```bash
ps aux --sort=-%cpu | head -6
```

Hint for top processes by memory:

```bash
ps aux --sort=-%mem | head -6
```

Pass condition:

- Script runs without errors
- Report file is created with a timestamp in the filename
- Report contains all 6 required sections
- You can explain every line
- You can explain why this script is the seed of Mini Project 2

This drill is not a mini-project. It is a controlled diagnostic-script-building test.

---

## Break/Fix Tasks

You must intentionally break and fix these.

### Break/Fix 1 — Killing the Wrong Process

Start two background jobs. Use `ps aux | grep long_task` to find both PIDs, but deliberately kill the wrong one first.

Record:

- which PID you killed
- how you confirmed it was the wrong one
- how you found the correct one
- what you learned about double-checking PIDs before killing

---

### Break/Fix 2 — Losing a Job by Closing the Terminal

Start a background job without `disown` or `nohup`. Note its PID. Open a new terminal tab/window and check if the process is still running using `ps -ef | grep long_task`.

Record:

- what you expected
- what actually happened
- why this matters for real production work

---

### Break/Fix 3 — Wrong Signal

Run a background job. Send `kill -STOP PID` instead of a normal kill.

Record:

- what happened to the process (check with `ps aux` — note its STAT column)
- how this differs from `kill -9`
- how to resume it

---

### Break/Fix 4 — pkill Too Broad

Start `long_task.sh` in the background. Run `pkill -f task` instead of `pkill -f long_task.sh`.

Record:

- what else could have matched this broader pattern on a real system
- why specific patterns matter
- the corrected, safer command

---

### Break/Fix 5 — Misreading free Output

Look at `free -h` output and write down what you think "available" memory means before checking. Then verify with `man free`.

Record:

- your first guess
- what it actually means
- why the distinction matters when deciding if a system is low on memory

---

## Verification Checkpoints

You must be able to answer instantly:

- What is a PID?
- What is a PPID?
- What does `ps aux` show that plain `ps` does not?
- What is the difference between a process and a job?
- What does `&` do?
- What does `Ctrl+Z` do versus `Ctrl+C`?
- What is the difference between `fg` and `bg`?
- What does `disown` do?
- What does `nohup` do, and how is it different from `disown`?
- What signal does plain `kill` send?
- What signal does `kill -9` send?
- Why should you try SIGTERM before SIGKILL?
- What does SIGSTOP do, and how is it different from SIGTERM?
- What does `pgrep -f` do?
- What is the risk of `pkill` with a broad pattern?
- What do the three numbers in `uptime`'s load average mean?
- What is the difference between "free" and "available" memory?
- What is the difference between `df` and `du`?
- What does `<(...)` do, and how is it different from `$(...)`?

---

## Final Pass Standard

You pass this lab only when you can build this from scratch without notes:

A script that:

- prints system uptime and load
- prints memory and disk usage
- lists the top 5 CPU-consuming processes
- lists the top 5 memory-consuming processes
- saves everything into a timestamped report
- can be explained line by line

And you can, without hesitation:

- start a background job, suspend it, resume it, and detach it
- find a process by name and kill it safely
- explain why you'd choose `kill` over `kill -9` in a real incident

If you cannot do this yet, repeat the lab before moving to Lab 07.