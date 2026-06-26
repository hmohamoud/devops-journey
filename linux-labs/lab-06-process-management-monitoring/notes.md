ps shows every running processes in your current terminal.
ps aux shows every running process in your computer.

echo $$ - prints your current shells PID
ps aux | grep $$ - searches all processes in your entire system and finds your shell PID. Its a verification trick.


USER - Who user started this process
PID - Process id, uniquely identifies a process
%CPU - How much CPU its currently using (percentage in relative to total system CPU)
%MEM - How much RAM its currently using (percentage in relative to total system RAM)
STAT tells us what the process is doing right now 
    S = sleeping (idle, waiting for something)
    R = running(actively using CPU right now)
    Z = zombie (process has finished but hasnt been removed yet from the system, this is so that the parent process can check whether it completely successfully or not)
    T = Stopped (process has been paused)
COMMAND - the actual command that created this process


ps -ef is another way to show us every process running in our entire system:
The only thing it has on ps aux is it provides the PPID (parent process ID) of every process. 

echo $PPID

what is foreground execution
you cant type anything the terminal becomes unusable because the script is running
the terminal frees up until the script has finished or terminated
what is Ctrl + C
ctrl + C terminates the process completely not paused
it sends a signal that stops the process entirely
what is background execution (&)
the process runs in the background and frees the terminal which means we can type while its running
what is jobs
jobs tells us which processes are running in the background in our current terminal session
what is jobs -l
jobs -l includes the PID of that background process
what is fg
fg brings it back to the foreground terminal is blocked again
what is Ctrl + Z
ctrl + z pauses the process it doesnt terminate/kill it
why Ctrl + Z matters
this is perfect because we can now move it to background because bg only works on paused processes

If the shell closes, the job usually stops.

To detach the process from the shell there are two methods that allow background jobs to work even if the terminal dies.
disown = detach after running existing background job
nohup =  detach at start of running existing background job
both = prevent job from dying when terminal closes

To kill a background prcess you do
you do kill PID
kill PID = polite request to stop (safe first option)
kill -9 PID = forced shutdown (last resort)

pgrep -f long_task.sh
→ finds all PIDs matching the script name (uses full command match with -f)

pkill -f long_task.sh
→ kills all processes matching the script name

---

**The server is slow: 1. Check Uptime**

`uptime` - tells you how long the system has been running since its last reboot.

```
2:28  up 62 days, 15:24, 1 user, load averages: 1.25 1.31 1.27
```

It has been running for 62 days since last restart, one user is logged in, and the three numbers are called the **load average** — they tell us how many processes were waiting for CPU time, averaged over three different time windows. The numbers are always shown in this order: **1.25 is the 1-min window, 1.31 is the 5-min window, 1.27 is the 15-min window.**

**Critical thing nobody tells you clearly:** a raw number like "1.25" means nothing on its own. You must compare it to your number of CPU cores.

`nproc` - tells you how many cores you have.

---

**Step 1 — Is CPU a suspect? (check the 1-min number only)**

- 1-min load average ≈ number of cores → Good, not a suspect
- 1-min load average < number of cores → Good, not a suspect
- 1-min load average > number of cores → **Bad — CPU is a suspect**

If not a suspect, stop here, move on to `free -h`.

---

**Step 2 — How urgent is it? (only if Step 1 said "suspect")**

Picture the three numbers as dots on a line, oldest to newest, left to right:

```
15-min  •────────•  5-min  ────────•  1-min
```

Flip your numbers into that order and see which way the dots move:

- Dots go **up** → **climbing** → getting worse right now (if 1min > 15min its climbing)
- Dots go **down** → **falling** → was bad, recovering on its own (if 1min < 15min its falling)
- Dots stay **level** → **flat** → steady, unchanging (if 1min is approximately same as 15min its flat)

**Urgency by trend:**
- Climbing → **Very high** — act immediately, best chance to catch the live culprit
- Flat (and high) → **High** — sustained problem, not a fluke, needs action but not panic
- Falling → **Low** — already easing off, worth a look but not an emergency

**Worked example** (1.25, 1.31, 1.27), flipped to 15→5→1: `1.27 → 1.31 → 1.25` — barely moves, so **flat**. All three numbers are also way below `nproc` (so Step 1 already said "not a suspect" — Step 2 wasn't even needed here).

---

Now we go to `top` for confirmation 
Look at this line in your output:
%Cpu(s): 20.0 us,  0.0 sy,  0.0 ni, 79.9 id
id = 79.9%

id below 20% → CPU is the problem, stay here, find the villain
id above 20% → CPU is fine, move to `free -h`

---
Find the process that is the cause of why the CPU is the problem by `ps aux --sort=-%cpu | head`
# Don't know the PID yet
pgrep -f long_task.sh       # check it's running, see the PID
pkill -f long_task.sh       # or just kill it by name directly

# Already know the PID (from top/ps)
kill PID                    # polite
kill -9 PID                 # forced

Verify by running uptime and top again — CPU idle (%id) should increase and the load average should begin dropping toward the number of CPU cores.


free -h columns — what they actually mean:
    Total — Physical RAM installed.
    used — RAM being used.
    free — Completely unused RAM.
    buff/cache — RAM used for cache; reusable if needed.
    available — RAM available for new processes.

Swap is disk space the operating system uses as extra RAM when physical RAM is full. Because disk is much slower than RAM, heavy swap usage slows the system down.


Run free -h. Look at two numbers only: available and swap used.
Suspect — available is low (under 10% of total) OR swap used is high (50% of swap total). Find the hog.
ps aux --sort=-%mem | head
get the PID, kill PID

---

Size — Total storage on the filesystem.
Used — Storage currently being used.
Avail — Storage still available.
Use% — Percentage of storage being used.
Mounted on - Where the filesystem is located.

## Finding What's Filling the Disk

**Remember:**

* **`df` = Is the disk full?**
* **`du` = What's taking up the space?**

### Step 1 — Check if the disk is full

```bash
df -h
```

* **Use% < 90%** → Disk is probably **not** the problem.
* **Use% ≥ 90%** → Find the filesystem that's full and investigate it.

---

### Step 2 — Find the biggest thing

```bash
du -sh <path>/* | sort -rh
```

Always look at the **first result** (it's the biggest).

* If it's a **folder** → Go inside it and run the command again.
* If it's a **file** → You've found what's using the space.

Example:

```bash
du -sh /* | sort -rh
```

```
2.1G  /var
```

↓

```bash
du -sh /var/* | sort -rh
```

```
1.9G  /var/log
```

↓

```bash
du -sh /var/log/* | sort -rh
```

```
1.8G  /var/log/access.log
```

✅ Found the culprit.

---

### Step 3 — Remove the culprit

```bash
rm <file>
```

Only delete it if you know it's safe to remove.

---

### Step 4 — Check again

```bash
df -h
```

If **Use%** has dropped, you've fixed the problem.
