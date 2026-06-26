# Lab 06 — Process Management & System Monitoring

**Environment:** macOS Sequoia | Zsh | VS Code Terminal | Apple Silicon (M-series)

---

## Problem

A script that runs is not enough.

In production, engineers get paged because something is slow, something is using all the CPU, or a disk is full. You need to be able to answer those questions using only a terminal and built-in tools.

Needed to understand how to:

- list and interpret running processes
- move jobs between foreground and background
- detach long-running processes from the terminal so they survive shell death
- send the correct signal for the situation
- find and kill processes safely by name
- read system load, memory, and disk usage
- diagnose a slow server from first principles

---

## What I Built

A structured process management environment:

- `process-lab/scripts/` — long-running test scripts and diagnostic tools
- `process-lab/logs/` — nohup and process output logs
- `process-lab/output/` — timestamped health snapshot reports

Built a full server diagnostic tool that prints uptime, load average, memory usage, disk usage, top 5 CPU processes, and top 5 memory processes — then saves everything to a timestamped report file.

---

## How I Solved It

**Process Inspection:**

- `ps` shows processes in the current terminal only
- `ps aux` shows every process on the machine with CPU, memory, and state
- `ps -ef` adds PPID — the parent process ID — which `ps aux` does not show
- Every process except the very first has a parent

**Job Control:**

- `&` runs a process in the background, freeing the terminal
- `Ctrl+C` terminates completely — sends SIGINT
- `Ctrl+Z` pauses without terminating — sends SIGTSTP
- `fg` brings a background job to the foreground
- `bg` resumes a paused job in the background
- `jobs -l` shows all background jobs with their PIDs

**Detaching from the Shell:**

- When the terminal closes, background jobs receive SIGHUP and die
- `disown` detaches an already-running background job from the shell
- `nohup` starts a job already immune to SIGHUP — output must be redirected
- `disown` = detach after starting, `nohup` = detach at start

**Signals:**

- `kill PID` sends SIGTERM — polite request, process can clean up
- `kill -9 PID` sends SIGKILL — forced, no cleanup, last resort
- `kill -STOP PID` pauses the process — shows as T in STAT column
- `kill -CONT PID` resumes a stopped process
- Always try SIGTERM first — SIGKILL can corrupt files mid-write

**Finding Processes by Name:**

- `pgrep -f long_task.sh` finds all PIDs matching the full command name
- `pkill -f long_task.sh` kills all matching processes at once
- Always run `pgrep -f` before `pkill -f` to verify what will be killed
- Too broad a pattern can kill unintended processes

**Diagnosing a Slow Server:**

- `uptime` → compare load average to `nproc` to check if CPU is a suspect
- `top` → check `%id` — below 20% means CPU is the problem
- `ps aux --sort=-%cpu | head` → find the highest CPU consumer
- `free -h` → check `available` and `swap used`, not `free`
- `df -h` → check `Use%` on each filesystem — 90%+ is dangerous
- `du -sh <path>/* | sort -rh` → drill down until you find the culprit file

---

## Proof

### health_snapshot.sh running and saving a timestamped report

![health snapshot](screenshots/health-snapshot.png)

### ps aux output showing STAT column

![ps aux stat](screenshots/ps-aux-stat.png)

### Background job control — jobs, fg, Ctrl+Z, bg

![job control](screenshots/job-control.png)

### kill vs kill -9 — process stopping clean vs forced

![signals](screenshots/signals.png)

### pgrep and pkill — finding and killing by name

![pgrep pkill](screenshots/pgrep-pkill.png)

### free -h output — available vs free explained

![free -h](screenshots/free-h.png)

### df -h and du -sh drill — finding disk culprit

![disk drill](screenshots/disk-drill.png)

---

## Scripts Built

| Script | Purpose |
|---|---|
| `long_task.sh` | Long-running test process for job control practice |
| `health_snapshot.sh` | Full system diagnostic report with timestamp |
| `system_check.sh` | Challenge version built from scratch without notes |

---

## Break/Fix Summary

| Issue | Cause | Fix |
|---|---|---|
| Killed the wrong process | Picked first PID without verifying | Used `pgrep -f` to confirm PID before killing |
| Job died after closing terminal | Started with `&` only, no disown or nohup | Used `disown` or `nohup` to detach |
| `kill -9` used immediately | Default habit, did not try SIGTERM first | Always try `kill PID` first |
| `pkill -f task` killed too much | Pattern too broad, matched unintended processes | Used `pgrep -f` first to verify exact matches |
| Panicked over low free memory | Misread `free` column instead of `available` | Checked `available` — system had plenty of RAM |

---

## Key Scripts

```bash
# Find the slow process
ps aux --sort=-%cpu | head

# Kill safely
kill PID        # polite — try this first
kill -9 PID     # forced — last resort only

# Find by name before killing
pgrep -f long_task.sh
pkill -f long_task.sh

# Detach from terminal
nohup ./long_task.sh > process-lab/logs/output.log 2>&1 &
disown

# Is CPU a suspect?
uptime && nproc

# Is memory a suspect?
free -h

# Is disk a suspect?
df -h
du -sh /var/* | sort -rh
```

---

## Improvements After Completion

- Learned that `free` memory being low is normal — `available` is what matters
- Learned that `kill -9` should never be the first move
- Learned that a background job without `disown` or `nohup` dies when the terminal closes
- Learned that `pgrep -f` before `pkill -f` is not optional — it prevents destroying the wrong processes
- Learned to read load average as a trend across three windows, not just a single number
- Learned that `df` finds which filesystem is full and `du` finds what is filling it

---

## Key Takeaway

Before this lab, slow server meant panic.

After this lab, slow server means a structured five-step investigation:
uptime → top → ps → free -h → df -h

Every command has a reason. Every kill has a verification. Every disk problem has a drill.

That is the difference between guessing and diagnosing.

---

## Next Step

[Lab 07 — Advanced Text Processing & Wildcards](../lab-07-text-processing/)