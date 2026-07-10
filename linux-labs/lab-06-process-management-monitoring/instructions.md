# Lab 06 — Process Management & System Monitoring

## Objective

Develop the ability to diagnose, control, and resolve process-related incidents on a live Linux system.

You must be able to:
- identify what processes are doing and why
- classify incidents correctly before acting
- kill, control, and manage processes safely
- trace parent-child relationships and process trees
- diagnose slow systems using process state, not guesswork

---

## Scenario

You are an on-call engineer responsible for a production Linux server.

Users are reporting degraded performance. You have been paged with no additional context. You do not know what is wrong. You must investigate, classify, and resolve the incident using your flow — no guessing, no skipping steps.

Each task below introduces a different failure. Your job is to find it and fix it.

---

## Constraints (MANDATORY)

- Do NOT skip steps in your flow
- Before acting on any process, identify it first
- Never run `kill -9` before trying `kill` first
- After every kill, verify the process is actually gone
- Before killing anything, ask: is this the parent or a child?
- Every command must have a clear intention
- Before running a command:
  → state what you expect to see
- After running a command:
  → interpret the result before moving on
- You must use your full investigation flow for every scenario

---

## Environment Setup

```bash
open -a Docker
docker start -ai process-lab
```

Install required tools if not already present:

```bash
apt update && apt install -y procps sysstat stress-ng psmisc python3
```

---

## Scenarios

---

### Scenario 1 — The Runaway Worker

**Alert received:**
> Production API response times have increased significantly. Engineers report the server feels sluggish. No recent deployments.

**Setup:**

```bash
stress-ng --cpu 2 --cpu-load 85 &
```

Investigate, classify, and resolve using the full flow.

---

### Scenario 2 — The Kernel Hog

**Alert received:**
> System CPU usage is elevated. Engineers cannot identify which application is responsible. Kernel time is unusually high.

**Setup:**

```bash
cat /dev/urandom > /dev/null &
cat /dev/urandom > /dev/null &
cat /dev/urandom > /dev/null &
cat /dev/urandom > /dev/null &
```

Investigate, classify, and resolve using the full flow.

---

### Scenario 3 — The Silent Leak

**Alert received:**
> System is slow but CPU looks fine. Engineers are confused. No high CPU processes visible in top.

**Setup:**

```bash
python3 -c "
import os, time
procs = []
for i in range(10):
    p = os.fork()
    if p == 0:
        time.sleep(9999)
        os._exit(0)
    procs.append(p)
while True:
    time.sleep(9999)
" &
```

Investigate, classify, and resolve using the full flow.

---

### Scenario 4 — The Fork Bomb

**Alert received:**
> System is becoming unresponsive. Process count is climbing rapidly. Engineers cannot SSH in reliably.

**Setup:**

```bash
ulimit -u 50 && python3 -c "
import os, time
def fork_forever():
    while True:
        os.fork()
        time.sleep(0.1)
fork_forever()
" &
```

**Act fast. The longer you wait the worse it gets.**

**You must answer:**
- [ ] What is the first thing you check to confirm this is a fork bomb?
- [ ] Why do you freeze the parent before killing it?
- [ ] What signal freezes a process without killing it?
- [ ] What is the correct kill order?
- [ ] How do you confirm the process count has stabilised?

**Record:**
→ Command used at each step
→ What you saw
→ Decision you made
→ Action you took

---

### Scenario 5 — The Zombie Factory

**Alert received:**
> Process table is filling up with dead processes. System stability is at risk.

**Setup:**

```bash
python3 -c "
import os, time, subprocess
while True:
    p = subprocess.Popen(['sleep', '0.1'])
    time.sleep(0.5)
" &
```

**You must answer:**
- [ ] What command shows you zombie processes?
- [ ] Can you kill a zombie directly? Why or why not?
- [ ] What is the actual fix for a zombie storm?
- [ ] Why is a small fixed zombie count harmless?
- [ ] At what point does a zombie storm become dangerous?
- [ ] How do you verify the storm has stopped?

**Record:**
→ Command used at each step
→ What you saw
→ Decision you made
→ Action you took

---

### Scenario 6 — The Disguised Problem

**Alert received:**
> Load average is elevated. Team has already killed what they thought was the problem. System is still slow.

**Setup:**

```bash
stress-ng --cpu 1 --cpu-load 40 &
stress-ng --cpu 1 --cpu-load 40 &
stress-ng --cpu 1 --cpu-load 40 &
sleep infinity &
sleep infinity &
sleep infinity &
sleep infinity &
sleep infinity &
```

**You must answer:**
- [ ] What state are the sleep processes in?
- [ ] Does S state with 0% CPU mean they are the problem?
- [ ] What does pidstat tell you that top does not?
- [ ] How do you identify the actual cause when no single process dominates?
- [ ] How do you clean up only the guilty processes without touching the innocent ones?

**Record:**
→ Command used at each step
→ What you saw
→ Decision you made
→ Action you took

---

### Scenario 7 — The Priority Inversion

**Alert received:**
> Critical service is responding slowly even though CPU is not fully saturated. A background job appears to be competing with it.

**Setup:**

```bash
stress-ng --cpu 3 --cpu-load 60 &
```

**You cannot kill the stress-ng process. Reduce its priority instead.**

**You must answer:**
- [ ] What command shows the current priority (NI column) of a process?
- [ ] What is the nice value range and what does a higher value mean?
- [ ] How do you change the priority of a running process?
- [ ] Does renicing help a process in D state?
- [ ] How do you verify the priority change took effect?
- [ ] What is the difference between nice and renice?

**Record:**
→ Command used at each step
→ What you saw
→ Decision you made
→ Action you took

---

### Scenario 8 — The Orphan

**Alert received:**
> A long running data export process has been running for hours. The engineer who started it has disconnected. Nobody knows if it is still running or what state it is in.

**Setup:**

```bash
nohup bash -c 'while true; do echo exporting >> /tmp/export.log; sleep 2; done' &
disown
```

**You must answer:**
- [ ] How do you find a process when you do not know its PID?
- [ ] How do you confirm it is still running and making progress?
- [ ] What does disown mean and why does the process survive terminal close?
- [ ] How do you safely terminate a long running process without corrupting its output?
- [ ] How do you verify it has fully stopped?

**Record:**
→ Command used at each step
→ What you saw
→ Decision you made
→ Action you took

---

### Scenario 9 — The Unkillable Process

**Alert received:**
> Engineer reports they cannot kill a process. kill and kill -9 both appear to do nothing.

**Setup:**

```bash
sleep infinity &
PID=$!
kill -STOP $PID
```

**You must answer:**
- [ ] What process state causes kill -9 to appear to fail?
- [ ] What is the difference between a T state and a D state process?
- [ ] What signal resumes a stopped process?
- [ ] How do you distinguish T state from D state in ps output?
- [ ] What is the correct action for each?

**Record:**
→ Command used at each step
→ What you saw
→ Decision you made
→ Action you took

---

### Scenario 10 — The Mixed Incident

**Alert received:**
> Multiple engineers are reporting different symptoms at the same time. One says CPU is high. Another says processes are unresponsive. A third says the process count looks wrong.

**Setup:**

```bash
stress-ng --cpu 1 --cpu-load 80 &
python3 -c "
import os, time
for i in range(8):
    p = os.fork()
    if p == 0:
        time.sleep(9999)
        os._exit(0)
while True:
    time.sleep(9999)
" &
cat /dev/urandom > /dev/null &
```

**You must answer:**
- [ ] How do you separate multiple problems when symptoms overlap?
- [ ] Which problem do you fix first and why?
- [ ] How do you confirm each fix without affecting the others?
- [ ] How do you verify full system recovery at the end?

**Record:**
→ Command used at each step
→ What you saw
→ Decision you made
→ Action you took

---

### Scenario 11 — The Signal Decision

**Alert received:**
> A service is misbehaving. You need to control it using signals — but the wrong signal will cause data loss or leave it running.

**Setup:**

```bash
bash -c 'trap "echo TERM caught, cleaning up; sleep 2; echo done" TERM; while true; do echo working; sleep 1; done' &
```

**You must answer:**
- [ ] What is the difference between SIGTERM and SIGKILL?
- [ ] Which signal allows a process to clean up before dying?
- [ ] Which signal cannot be caught or ignored?
- [ ] What does SIGSTOP do and when would you use it over SIGKILL?
- [ ] What does SIGHUP mean and why do daemons use it?
- [ ] What is SIGINT and what terminal shortcut sends it?

**You must practice:**
```bash
kill -TERM <pid>     # observe it catches the signal and cleans up
kill -STOP <pid>     # pauses it
kill -CONT <pid>     # resume it
kill -KILL <pid>     # force kill, no cleanup
```

**Record:**
→ Signal used
→ What the process did
→ What you learned about when to use each

---

### Scenario 12 — The Blocked Terminal

**Alert received:**
> An engineer accidentally started a long running backup in the foreground. The terminal is now blocked. The backup must not be interrupted.

**Setup:**

```bash
bash -c 'echo backup started; while true; do echo backing up; sleep 1; done'
```

**Your terminal is now blocked. You must recover it without stopping the backup.**

**You must answer:**
- [ ] How do you suspend the foreground process without killing it?
- [ ] How do you resume it in the background?
- [ ] How do you list what is running in the background?
- [ ] How do you bring it back to the foreground?
- [ ] How do you detach it so it survives if your terminal closes?
- [ ] What is the difference between disown and nohup?

**You must use in order:**
```
Ctrl+Z   → suspend it
bg       → resume in background
jobs     → confirm it is running
disown   → detach from terminal
```

**Record:**
→ Command used at each step
→ What you saw
→ Decision you made
→ Action you took

---

### Scenario 13 — The Wrong Kill

**Alert received:**
> System is slow. An engineer runs pkill python3 to clean up. Three critical services go down immediately.

**Setup:**

```bash
python3 -c "import time; print('service A running'); [time.sleep(1) for _ in iter(int, 1)]" &
python3 -c "import time; print('service B running'); [time.sleep(1) for _ in iter(int, 1)]" &
python3 -c "import time; print('BAD PROCESS burning CPU'); exec(compile('while True: pass', '', 'exec'))" &
```

**You must kill only the bad process without touching the two services.**

**You must answer:**
- [ ] Why is pkill -f python3 dangerous here?
- [ ] How do you check what pgrep would match before running pkill?
- [ ] How do you identify which python3 process is the bad one?
- [ ] How do you kill only that specific PID safely?
- [ ] How do you verify the two services are still running after?

**Record:**
→ Command used at each step
→ What you saw
→ Decision you made
→ Action you took

---

### Scenario 14 — The Memory Pressure Mystery

**Alert received:**
> Application is slow. CPU usage is only ~5%. No obvious process spike. Users report lag and timeouts.

**Setup:**

```bash
stress-ng --vm 2 --vm-bytes 80% --timeout 60s &
```

**Your job:**

CPU looks fine. Something else is causing the slowness. You must find it.

**You must answer:**
- [ ] Why is CPU low but the system still slow?
- [ ] What does `free -h` reveal about usable memory vs cached memory?
- [ ] Which process is actually consuming memory?
- [ ] Is the system swapping?
- [ ] What happens when swap starts being used heavily?

**Commands you must use:**

```bash
free -h
ps aux --sort=-%mem | head
vmstat 1 5
```

**Resolution rule:**

```
check free -h → available and swap columns only
confirm with ps aux --sort=-%mem
identify the top memory consumer
kill or throttle it
never act on %MEM alone without checking available and swap first
```

**Record:**
→ Command used at each step
→ What you saw
→ Decision you made
→ Action you took

---

### Scenario 15 — The Disk Explosion

**Alert received:**
> Server is stable but writes are failing. Logs and uploads are breaking silently.

**Setup:**

```bash
mkdir -p /mnt/faketest
mount -t tmpfs -o size=200M tmpfs /mnt/faketest
dd if=/dev/zero of=/mnt/faketest/bloatfile bs=10M count=18 oflag=direct status=progress
```

**Your job:**

Processes are failing on write operations. Find what is consuming disk and clean it up safely.

**You must answer:**
- [ ] Is disk actually full?
- [ ] Which filesystem is impacted?
- [ ] What directory is growing the fastest?
- [ ] Is `/var/log` responsible?
- [ ] How do you clean up safely without deleting something important?

**Commands you must use:**

```bash
df -h
du -sh /*
du -sh /tmp/*
```

**Resolution rule:**

```
df -h first          →  confirm which filesystem is full
du -sh /* | sort -rh →  find the biggest directory
drill in until you find the file
rm the file only if safe to remove
df -h again          →  confirm space recovered
```

**Record:**
→ Command used at each step
→ What you saw
→ Decision you made
→ Action you took

---

### Scenario 16 — Mixed Resource Saturation

**Alert received:**
> System is slow. CPU is low. Memory looks okay at first glance. Engineers disagree on root cause.

**Setup:**

```bash
stress-ng --cpu 1 --cpu-load 20 &
stress-ng --vm 1 --vm-bytes 70% &
```

**Your job:**

Nothing is obvious. CPU looks fine. Memory looks fine at a glance. You must go deeper and find what is actually causing the slowness.

**You must answer:**
- [ ] Is this a CPU problem, a memory problem, or neither?
- [ ] Why does CPU look fine but the system still lag?
- [ ] What does swapping tell you that %MEM does not?
- [ ] Which metric lies first — CPU or memory?
- [ ] How do you confirm memory pressure when `free -h` looks okay at a glance?

**Commands you must use:**

```bash
top
free -h
vmstat 1 5
ps aux --sort=-%mem | head
```

**Record:**
→ Command used at each step
→ What you saw
→ Decision you made
→ Action you took

---

## Break/Fix Tasks (CRITICAL)

You must intentionally create and resolve these failures.

- [ ] Kill a child process instead of the parent in a fork scenario
```bash
python3 -c "
import os, time
for i in range(5):
    p = os.fork()
    if p == 0:
        time.sleep(9999)
        os._exit(0)
while True:
    time.sleep(9999)
" &
```
  → observe what happens to the other children
  → correct your approach

- [ ] Run `kill -9` on a process in T state
```bash
sleep infinity &
PID=$!
kill -STOP $PID
```
  → observe what actually happens
  → understand why it worked differently than D state

- [ ] Attempt to kill a zombie directly with kill -9
```bash
python3 -c "
import os, time, subprocess
for i in range(3):
    p = subprocess.Popen(['sleep', '0.1'])
    time.sleep(0.3)
" &
```
  → observe the result
  → apply the correct fix

- [ ] Use Ctrl+C instead of Ctrl+Z on a foreground process
  → observe the difference
  → understand when each is appropriate

---

## Verification Checkpoints (NO SKIPPING)

At the end you must be able to:

- [ ] Run the full investigation flow from Step 1 without referring to notes
- [ ] Classify any incident as CPU / blocked / lifecycle / fork bomb / zombie within 60 seconds
- [ ] Explain what R, S, D, Z, and T state mean and what action each requires
- [ ] Use pidstat to confirm sustained vs spike before acting
- [ ] Choose the correct signal for any situation without guessing
- [ ] Kill processes safely using the correct signal and order
- [ ] Find parent-child relationships using ps and ppid
- [ ] Move a foreground process to background without killing it
- [ ] Renice a running process and verify the change
- [ ] Find a process by name without knowing its PID
- [ ] Use pgrep before pkill to verify what you are about to kill
- [ ] Explain why kill -9 sometimes appears to do nothing
- [ ] Verify every action you take — never assume it worked

---

## Success Criteria

You are successful when:

- You run the investigation flow without skipping steps
- You classify the problem before acting on it
- You act on evidence not assumptions
- You verify every action before declaring the incident resolved
- You can explain every decision you made and why
- You choose the right signal for the right situation every time
- You never kill a process without confirming what it is first
- You operate calmly and methodically under time pressure
- You demonstrate the behaviour of a real SRE or platform engineer