# Notes — Lab 06: Process Management & System Monitoring

---

## Process Commands

`ps` shows every running process in your current terminal.
`ps aux` shows every running process in your computer.

```bash
echo $$
```
Prints your current shell's PID.

```bash
ps aux | grep $$
```
Searches all processes in your entire system and finds your shell PID. It's a verification trick.

---

## ps aux Columns
USER    — who started this process

PID     — process ID, uniquely identifies a process

%CPU    — how much CPU it's currently using (relative to total system CPU)

%MEM    — how much RAM it's currently using (relative to total system RAM)

STAT    — what the process is doing right now

COMMAND — the actual command that created this process

**STAT values:**
S = sleeping (idle, waiting for something)

R = running (actively using CPU right now)

Z = zombie (process has finished but hasn't been removed yet — parent needs to check if it completed successfully)

T = stopped (process has been paused)

---

## ps -ef

Another way to show every process running on the entire system.

The only thing it has over `ps aux` is it provides the **PPID** (parent process ID) of every process.

```bash
echo $PPID
```

---

## Foreground Execution

You can't type anything — the terminal becomes unusable because the script is running.
The terminal frees up only when the script has finished or been terminated.

---

## Ctrl + C

Terminates the process completely — not paused.
Sends a signal that stops the process entirely.

---

## Background Execution (&)

The process runs in the background and frees the terminal, which means you can type while it's running.

---

## jobs

Tells you which processes are running in the background in your current terminal session.

## jobs -l

Includes the PID of that background process.

---

## fg

Brings the job back to the foreground — terminal is blocked again.

---

## Ctrl + Z

Pauses the process — it doesn't terminate or kill it.

**Why Ctrl + Z matters:**
This is perfect because you can now move it to the background — `bg` only works on paused processes.

---

## bg

Resumes a paused job in the background — terminal stays free.

---

## Detaching from the Shell

If the shell closes, the job usually stops.

To detach the process from the shell there are two methods that allow background jobs to work even if the terminal dies:
disown = detach after running existing background job

nohup  = detach at start of running existing background job

both   = prevent job from dying when terminal closes

---

## Killing a Background Process

```bash
kill PID      # polite request to stop (safe first option)
kill -9 PID   # forced shutdown (last resort)
```

---

## Finding and Killing by Name

```bash
pgrep -f long_task.sh
```
Finds all PIDs matching the script name. Uses full command match with `-f`.

```bash
pkill -f long_task.sh
```
Kills all processes matching the script name.

---

## The Server is Slow — Investigation Flow

### Step 1 — Check Uptime

```bash
uptime
```

Tells you how long the system has been running since its last reboot.
2:28  up 62 days, 15:24, 1 user, load averages: 1.25 1.31 1.27

The three numbers are the **load average** — how many processes were waiting for CPU time, averaged over three time windows.
1.25 = 1-min window

1.31 = 5-min window

1.27 = 15-min window

A raw number means nothing on its own. Compare it to your number of CPU cores.

```bash
nproc
```

Tells you how many cores you have.

---

### Is CPU a Suspect?

Check the 1-min number only:
1-min ≈ cores  → not a suspect

1-min < cores  → not a suspect

1-min > cores  → CPU is a suspect

If not a suspect, stop here and move to `free -h`.

---

### How Urgent Is It? (only if CPU is a suspect)

Read the trend oldest to newest — left to right:
15-min  •────────•  5-min  ────────•  1-min

1-min > 15-min → climbing → getting worse right now → Very high urgency

1-min < 15-min → falling  → recovering on its own   → Low urgency

1-min ≈ 15-min → flat     → steady, not a fluke     → High urgency

---

### Step 2 — Confirm with top

```bash
top
```

Look at:
%Cpu(s): 20.0 us,  0.0 sy,  0.0 ni, 79.9 id

id below 20% → CPU is the problem — find the villain

id above 20% → CPU is fine — move to free -h

---

### Step 3 — Find the Villain

```bash
ps aux --sort=-%cpu | head
```

```bash
# Don't know the PID yet
pgrep -f long_task.sh       # check it's running, see the PID
pkill -f long_task.sh       # kill it by name directly

# Already know the PID (from top or ps)
kill PID                    # polite
kill -9 PID                 # forced
```

---

### Verify

Run `uptime` and `top` again.
CPU idle (`%id`) should increase and load average should begin dropping toward the number of cores.

---

## Memory — free -h
total      — physical RAM installed

used       — RAM being used

free       — completely unused RAM

buff/cache — RAM used for cache, reusable if needed

available  — RAM available for new processes

**Swap** is disk space the OS uses as extra RAM when physical RAM is full.
Because disk is much slower than RAM, heavy swap usage slows the system down.

---

### Is Memory a Suspect?

Run `free -h`. Look at two numbers only: `available` and `swap used`.
Not a suspect → available above 10% of total AND swap used below 50% of swap total

Suspect       → available is low (under 10%) OR swap used is high (above 50%)

---

### Find the Memory Hog

```bash
ps aux --sort=-%mem | head
```

Get the PID, then:

```bash
kill PID
```

---

## Disk — df -h and du
Size       — total storage on the filesystem

Used       — storage currently being used

Avail      — storage still available

Use%       — percentage of storage being used

Mounted on — where the filesystem is located

df = is the disk full?

du = what's taking up the space?

---

### Step 1 — Check if the Disk is Full

```bash
df -h
```
Use% under 90% → disk is not the problem

Use% at 90%+   → find the full filesystem and investigate

---

### Step 2 — Find the Biggest Thing

```bash
du -sh <path>/* | sort -rh
```

Always look at the first result — it's the biggest.
folder → go inside it and run the command again

file   → you've found the culprit

**Example drill:**

```bash
du -sh /* | sort -rh
# 2.1G  /var  → folder, drill in

du -sh /var/* | sort -rh
# 1.9G  /var/log  → folder, drill in

du -sh /var/log/* | sort -rh
# 1.8G  /var/log/access.log  → file, stop
```

---

### Step 3 — Remove the Culprit

```bash
rm <file>
```

Only delete it if you know it's safe to remove.

---

### Step 4 — Verify

```bash
df -h
```

If `Use%` has dropped, the problem is fixed.