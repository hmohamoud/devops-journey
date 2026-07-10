# Notes — Lab 06: Process Management & System Monitoring

---

## 1. Process Basics

`ps` — shows processes in your **current terminal session** only.
`ps aux` — shows **every** process on the entire system.
`ps -ef` — same idea as `ps aux`, but adds the **PPID** (parent process ID) column.

```bash
echo $$        # your current shell's own PID
echo $PPID     # your shell's parent PID
ps aux | grep $$   # verification trick — find your own shell in the full process list
```

### `ps aux` columns
| Column | Meaning |
|---|---|
| USER | who started the process |
| PID | process ID — unique identifier |
| %CPU | CPU usage relative to total system CPU |
| %MEM | RAM usage relative to total system RAM |
| STAT | current state of the process |
| COMMAND | the command that launched it |

### STAT values
| Code | Meaning |
|---|---|
| R | Running — actively using CPU right now |
| S | Sleeping — idle, waiting for something (normal, harmless by itself) |
| D | Uninterruptible sleep — blocked inside a kernel call (disk/network I/O). **Cannot be killed, not even with `kill -9`.** |
| Z | Zombie — already finished, but the parent hasn't reaped it (called `wait()`) yet. It's a corpse, not a live process. |
| T | Stopped — deliberately paused (via `SIGSTOP` or Ctrl+Z). Alive, suspended, fully killable. |

### Custom column views
```bash
ps -eo pid,ppid,stat,cmd
ps -eo pid,ppid,stat,%cpu,cmd
ps -eo pid,stat,wchan:32,cmd     # wchan shows what a process is waiting on
```
`wchan:32` widens the column so the wait-channel name isn't truncated — more descriptive than plain `wchan`.

---

## 2. Foreground vs Background Execution

**Foreground:** the terminal is blocked — you can't type anything until the command finishes or is killed.

**Background (`&`):** the process runs detached from terminal input, freeing you to keep typing.

```bash
long_task.sh &
```

### Ctrl+C (SIGINT)
Terminates the foreground process completely. Not paused — gone.

### Ctrl+Z (SIGTSTP)
Pauses (suspends) the foreground process. It is **still alive**, just frozen — this is what makes it recoverable.

### Job control
```bash
jobs        # background jobs in THIS terminal session
jobs -l     # same, but includes PIDs
fg          # bring a background/paused job back to the foreground (blocks terminal again)
bg          # resume a PAUSED (Ctrl+Z'd) job in the background — only works on paused jobs
```

**Recovery pattern for an accidentally-foregrounded long process:**
```
Ctrl+Z   → suspend it (still alive)
bg       → resume it in the background
jobs     → confirm it's running
disown   → detach it from the shell entirely
```

---

## 3. Detaching From the Shell (surviving terminal close)

When a terminal closes, Linux sends **SIGHUP** to every process in that session. Most processes obey it and die. That's why background jobs normally die when you close the window/SSH session.

| Tool | When applied | Effect |
|---|---|---|
| `nohup` | **Before** the process starts | Process ignores SIGHUP from the start |
| `disown` | **After** the process is already running (and usually already backgrounded) | Removes it from the shell's job table so SIGHUP is never even sent to it |

Both achieve the same outcome — surviving a terminal close — just applied at different points in the process's life.

```bash
nohup long_task.sh &      # protect from the start
# ...or, for an already-running background job:
disown                    # protect after the fact
```

---

## 4. Killing Processes

```bash
kill PID       # SIGTERM — polite request to stop; process can clean up first. ALWAYS TRY THIS FIRST.
kill -9 PID    # SIGKILL — forced, no cleanup, cannot be caught or ignored. Last resort.
```

**Rule:** never jump straight to `kill -9`. Try `kill` first, wait, verify, escalate only if needed.

### Finding processes by name (not PID)
```bash
pgrep -f long_task.sh    # find PID(s) matching full command text
pkill -f long_task.sh    # kill all matches — dangerous if the name is too generic (see Scenario 13)
```
**Danger:** `pkill -f python3` will kill *every* process with "python3" in its command line — including critical services, not just the bad one. Always `pgrep -f` first to see exactly what would be matched, then kill the specific PID(s) individually with `kill <pid>` rather than a broad `pkill`.

### Verifying a kill actually worked
```bash
kill <pid>
sleep 5
ps -p <pid>     # returns nothing → confirmed gone
                # still shows the process → escalate to kill -9
                # STILL won't die even with -9 → it's in D state, not a normal kill problem
```
**Never assume a kill worked — always verify.**

---

## 5. Signals Reference

| Signal | Command | What it does |
|---|---|---|
| SIGTERM | `kill <pid>` | Polite stop request — process can catch it and clean up before exiting |
| SIGKILL | `kill -9 <pid>` | Forced kill — cannot be caught, ignored, or blocked. Always works (unless D state) |
| SIGSTOP | `kill -STOP <pid>` | Freezes a process immediately — cannot be caught or ignored |
| SIGCONT | `kill -CONT <pid>` | Resumes/unfreezes a stopped process |
| SIGHUP | `kill -HUP <pid>` | Originally "terminal hung up"; daemons commonly interpret it as "reload your config" |
| SIGINT | Ctrl+C | Interrupt from keyboard — terminates by default |
| SIGTSTP | Ctrl+Z | Suspend from keyboard — freezes, recoverable |

**When to use SIGSTOP instead of SIGKILL:** when you need to freeze a process *without killing it* — e.g. to stop a fork bomb's parent from spawning more children before you kill it cleanly, or to pause something you might want to resume later.

---

## 6. Priority — nice / renice

| Term | Meaning |
|---|---|
| NI | Nice value — what *you* set/change |
| PRI | Actual scheduler priority — calculated automatically by the kernel from NI |

**Higher nice value = lower priority (more polite, yields CPU to others).**
**Lower nice value = higher priority (more aggressive, grabs more CPU).**

```bash
ps -eo pid,ppid,stat,%cpu,ni,pri,cmd | grep stress-ng   # check current nice/priority
renice 10 -p <pid>                                       # lower priority (be nicer)
ps -eo pid,ppid,stat,%cpu,ni,pri,cmd | grep stress-ng   # verify the change took effect
```

**`nice` vs `renice`:** `nice` sets the priority of a process **when you first launch it** (`nice -n 10 command`). `renice` changes the priority of a process **already running**.

**Renicing does NOT help a process in D state** — D state means it's blocked on a kernel/I/O call, not competing for CPU scheduling time, so priority is irrelevant to it.

---

## 7. The Full Investigation Flow

```
Step 1  →  uptime + nproc - tells you if system is under pressure (it doesnt tell you if its cpu, memory,disk or networking as the cause we need to find and fix the cause)
           load (1min) > nproc?
           NO  → if it is climbing still move to step 2
           YES → something queued, move to step 2

Step 2  →  top → CPU summary line + press 1
           (us + sy) is high AND id is low AND wa is near 0  → CPU busy  → step 3
           wa is high  → process waiting for io    → step 6
           neither clear   → step 3

Step 2b → ps aux --sort=-%cpu | head
          → find top CPU consumers fast (who is actually burning CPU)

          THEN:
          ps -eo ppid,pid,stat,%cpu,cmd
          → understand structure (who is parent / what states)
          → you can use this to check if its process lifecycle problem fork bomb if the parent process children count grows we must kill parent process
          or if many procs same ppid, all S and not taking CPU% then its dead weight it should also be killed
          THEN → Step 3          

Step 3  →  top → S column → scan top 10 rows → count R vs D
           R > D  → CPU contention  → step 4
           D > R  → procs blocked   → step 5
           all S, nothing clear     → go deeper, step 6

Step 4  →  pidstat 1 5
           same PID + high %CPU + every sample → sustained, kill the process → step 5
           appears once then gone              → spike, dont kill the process
           many PIDs contributing              → broad load, escalate

Step 5  →  kill <pid>
           wait 5 seconds
           ps -p <pid>  → verify process is gone, if it returns nothing it is killed
           gone          → solved, watch load drop
           still there   → kill -9 <pid>
           wont die      → process is in D state → go back to step 5

Step 6  →  D STATE — do NOT ask "which process to kill"
           Enter this branch if at least one of these apply:
          - many processes are in D state
          - wa (I/O wait) is high in top
          - b (blocked processes) is high in vmstat
          Run:
           ps -eo pid,stat,wchan:32,cmd | awk '$2 ~ /D/'
           awk '$2 ~ /D/' - this means where the second column contains D
           this one also works ps -eo pid,ppid,stat,wchan:32,cmd | awk '$3 ~ /D/' - this means where the second column contains D
           wchan vs wchan:32: wchan:32 makes it more descriptive compared to using wchan
           read wchan column: this tells you what the process is waiting on 

Step M1 →  MEMORY PATH
           vmstat 1 5 
           si or so > 0 (sustained) = memory pressure  → this is the decision; if this is true there is memory pressure
           free -h
           look at available column only
           available low (under 10% of total)  → tells you the context only on how severe the memory pressure is. 
           ps aux --sort=-%mem | head          → find top memory consumer
           identify the process → kill or throttle

Step D1 →  DISK PATH
           df -h                               → which filesystem is full or near full

           Use% under 90%  → not the problem
           Use% at 90%+    → disk problem
           du -sh /* | sort -rh               → find biggest directory
           drill in until you find the file
           remove only if safe to remove
           df -h again                         → confirm space recovered
```

---

## 8. CPU Path — Deep Notes

- **Load average alone tells you nothing** without comparing it to `nproc`. A raw number like "1.25" is meaningless in isolation.
- A single `top` snapshot can be misleading if only one core is loaded — the aggregate `us+sy` can look low even while one specific core is maxed. **Press `1` in top** to see per-core breakdown and catch this.
- **`sy` (system/kernel time) high + `us` (user time) low** = the process is doing kernel-level work, not application logic. Classic cause: heavy syscalls (e.g. `cat /dev/urandom > /dev/null` — every read is a syscall, so `sy` climbs while `us` stays low).
- **Never act on a single `top` snapshot.** Always confirm sustained load with `pidstat 1 5` before killing anything — a one-off CPU spike is noise, not an incident.
- **S state + 0% CPU + never shows up in `pidstat` with sustained CPU = innocent.** Don't touch it just because it exists alongside the real problem. `pidstat` is the source of truth for "who actually deserves to be killed" — if a process never appears there with sustained usage, it is not your problem.
- `pkill -f <name>` is efficient for cleaning up multiple matching processes at once, but it is a blunt instrument — verify what it will match with `pgrep -f` first, and never use it with a name broad enough to catch innocent/critical processes too (e.g. `python3`).

---

## 9. Fork Bombs & Process Lifecycle Problems

### Distinguishing the two
- **Process lifecycle problem (harmless-ish):** many child processes share the same PPID, all in S state, 0% CPU, and the **count is fixed/stable** — not growing. Still worth cleaning up (kill the parent, children get reparented to init and cleaned up), but not an emergency.
- **Fork bomb (emergency):** same shape, but the **child count keeps growing** over time. This is dangerous and demands immediate action.

### Watching for growth in real time
```bash
watch -n1 'ps aux | wc -l'                                   # is total process count climbing?
watch -n1 'ps -eo ppid | sort | uniq -c | sort -rn | head'    # which parent is spawning the most children, live?
```

### Correct fork bomb kill order
```
1. watch -n1 'ps aux | wc -l'                                 → confirm count is climbing
2. watch -n1 'ps -eo ppid | sort | uniq -c | sort -rn | head' → find the worst parent
3. kill -STOP <parent_pid>    → freeze it FIRST so it stops forking mid-cleanup
                                 (prevents new orphaned children being created while you work)
4. kill <parent_pid>          → kill it cleanly
5. pkill -P <parent_pid>      → clean up any remaining direct children
6. ps aux | wc -l              → confirm count is dropping back to normal
```

**Why freeze before killing?** If you kill the parent while it's still actively forking, it can spawn one more child in the split second between your kill and the process actually dying — leaving orphans behind. `SIGSTOP` guarantees it can't fork again before you finish cleanup.

### Kill target rule for stress-ng-style tools
Tools like `stress-ng --vm ...` spawn a stable long-lived **controller/parent** which continuously forks short-lived **worker children**. Trying to kill a worker PID directly often fails with "No such process" — by the time you act, that worker already died and got replaced by a fresh one. **Always kill the stable parent/controller PID**, not the transient worker.

---

## 10. Zombies

- Check with: `ps -eo pid,ppid,stat,cmd` — look for **`Z`** in the STAT column.
- **A zombie is already dead.** It finished running; you cannot kill it because there is nothing left to kill — it's a corpse the parent forgot to bury (the parent never called `wait()` to acknowledge completion and let the kernel remove the entry).
- `kill -9 <zombie_pid>` does **nothing** — confirmed by testing directly.
- **The actual fix:** kill the **parent** process. This forces the OS to clean up (reap) the zombie children.
- A small, fixed zombie count is harmless — it only becomes dangerous if the zombie count keeps climbing (a "zombie storm"), which indicates the parent has a systemic bug where it spawns children but never reaps them.
- Verify the storm has stopped the same way you'd verify anything: re-check `ps -eo pid,ppid,stat,cmd` and confirm the Z entries and their growth are gone.

---

## 11. Unkillable Processes — T state vs D state

| | T state | D state |
|---|---|---|
| Cause | Deliberately frozen via `SIGSTOP` or Ctrl+Z | Blocked inside a kernel call (disk/network I/O) |
| Alive? | Yes, alive but suspended | Yes, but stuck waiting on the kernel |
| Killable? | Yes — `kill -9` works directly, or `kill -CONT` to resume it first, then `kill` normally | **No — cannot receive ANY signal, including SIGKILL** |
| Correct fix | `kill -9 <pid>` OR `kill -CONT <pid>` then `kill <pid>` | Find what it's blocked on via `wchan`; fix the underlying blocker or escalate. Killing does nothing. |

Distinguish them with:
```bash
ps -eo pid,stat,cmd
```
`T` in STAT = frozen, killable. `D` in STAT = blocked in kernel, not killable no matter what signal you send.

---

## 12. Memory Deep Notes

### `free -h` columns
| Column | Meaning |
|---|---|
| total | physical RAM installed |
| used | RAM actively in use |
| free | completely unused RAM |
| buff/cache | RAM used for cache — reusable/reclaimable if something else needs it |
| available | RAM realistically available for new processes (accounts for reclaimable cache) |

**Swap** = disk space used as overflow "RAM" when physical RAM is full. Disk is far slower than RAM, so heavy swap usage directly causes system slowdowns.

### Is memory a suspect?
- **Not a suspect:** available > ~10% of total AND swap used < ~50% of swap total
- **Suspect:** available is low (<10%) OR swap used is high (>50%)

### The critical trap (learned the hard way)
`free -h`'s "available" column can look completely calm (e.g. 6.4Gi available, looks fine) **while `vmstat`'s `si`/`so` columns show sustained, heavy swap activity (e.g. `so` > 1,000,000) happening every single second.** This is not a contradiction to explain away — it's the actual lesson: **CPU and "available" memory both can lie first; swap activity is the ground-truth confirmation.** When they disagree, trust the swap numbers over the calm-looking snapshot.

### Finding the memory hog
```bash
ps aux --sort=-%mem | head
kill <pid>
```
Never act on `%MEM` alone without first checking `available` and `swap` — a process can have a high %MEM and still be harmless if there's no actual pressure (see cached-memory note below).

**Cached memory high but available still okay → not a problem.** This is completely normal Linux behavior (the kernel uses spare RAM for disk cache since it's better than leaving it idle) — don't mistake it for a leak.

---

## 13. Disk Deep Notes

### `df -h` columns
| Column | Meaning |
|---|---|
| Size | total storage on the filesystem |
| Used | storage currently in use |
| Avail | storage still available |
| Use% | percentage used |
| Mounted on | where the filesystem is mounted |

**`df` answers "is the disk full?" `du` answers "what's taking up the space?"** Always run `df` first to confirm there's actually a problem and to identify *which* filesystem/mount is affected, before drilling with `du`.

### Drilling down
```bash
du -sh /* | sort -rh          # biggest top-level directory
du -sh /var/*  | sort -rh     # drill deeper
du -sh /var/log/* | sort -rh  # keep going...
```
Keep drilling until `du` shows you an actual **file** (not a directory) — that's the bottom, and your target. Verify before deleting:
```bash
ls -la <file>
file <file>
lsof <file>     # is a running process still holding it open? if so, may need to restart
                # that process before the space is actually reclaimed even after rm
```

### Don't assume — verify the real cause
**`/var/log` is not automatically guilty just because the alert mentions "logs breaking."** Always check it explicitly (`du -sh /var/log`) rather than assuming — the real hotspot might be somewhere completely different (e.g. `/tmp`, a test/bloat file, an app's data directory). Trust `du -sh /* | sort -rh` over the narrative in the alert.

### A subtlety: disk-full vs memory-cgroup-killed (they can look identical from the outside)
A write can fail with **"No space left on device"** for two completely different reasons that present the same symptom:
1. **Actual disk full** — confirmed by `df -h` showing high/100% `Use%`. Fix: find and remove the offending file(s).
2. **Container memory-cgroup limit hit via page cache**, NOT disk space at all. Buffered writes (plain `dd` without special flags) accumulate in page cache before being flushed to disk; in a memory-cgroup-limited container (e.g. Docker with a memory cap), that cache counts against the container's memory limit. You can get **OOM-killed (exit code 137)** while writing a file, even with hundreds of GB of real disk space free.
   - Confirm with: `dmesg | tail -30` → look for `oom-kill:constraint=CONSTRAINT_MEMCG`
   - Confirm the actual limit: `cat /sys/fs/cgroup/memory.max`
   - **Fix/workaround:** use `dd ... oflag=direct` to bypass the page cache entirely, writing straight to disk instead of piling up in memory first.
   - **Lesson:** `df -h` telling you there's plenty of free space is not proof the write failure is unrelated to disk — always also check `dmesg` for OOM kills when a write fails unexpectedly and disk looks fine.

### Simulating disk pressure safely for practice
Real hosts/containers often have far more disk than you want to actually fill (e.g. 200+ GB). To safely simulate a near-full filesystem without touching real disk:
```bash
mkdir -p /mnt/faketest
mount -t tmpfs -o size=200M tmpfs /mnt/faketest
dd if=/dev/zero of=/mnt/faketest/bloatfile bs=10M count=18 oflag=direct status=progress
df -h    # /mnt/faketest will show ~90%+ Use% on its own small 200M allocation
```
Teardown when done:
```bash
rm -f /mnt/faketest/bloatfile
umount /mnt/faketest
rmdir /mnt/faketest
```
Skipping teardown doesn't break anything, but leaves clutter in future `df`/`mount` output — always clean up test infrastructure, not just the file that caused the simulated incident.

**Practical note on `&` (backgrounding) and `dd`:** backgrounding a command with `&` only persists for the life of the current shell session. If each of your test commands runs in an isolated one-off shell (e.g. separate tool calls, separate SSH sessions), the backgrounded process gets killed the moment that shell exits — it never really "ran in the background" long-term. For quick tests, just run it in the foreground; it's usually fast enough that this doesn't matter.

---

## 14. Priority Inversion Scenario Notes

When a lower-priority background job (e.g. a stress test) is competing with and slowing down a critical process, and you're **not allowed to kill it**, the fix is to **renice it down** (raise its NI value) so the scheduler favors other processes over it:
```bash
ps -eo pid,ppid,stat,%cpu,ni,pri,cmd | grep <name>   # check current NI/PRI
renice 10 -p <pid>                                     # increase nice value = lower priority
ps -eo pid,ppid,stat,%cpu,ni,pri,cmd | grep <name>   # verify it changed
```
Remember: this only affects CPU **scheduling priority**. It does nothing for a process in D state (blocked on I/O) — renicing a D-state process doesn't help because it isn't competing for CPU time in the first place.

---

## 15. Signal Decision Scenario Notes

If a process **traps SIGTERM** to run cleanup logic (e.g. `trap "echo cleaning up..." TERM`), sending plain `kill <pid>` (SIGTERM) allows that cleanup to actually execute before it exits — this is the "polite" path and should always be tried first when a graceful shutdown matters (avoiding data loss, partial writes, etc.). Only escalate to `kill -9` (SIGKILL, uncatchable) if the process ignores SIGTERM entirely or a hard force-kill is genuinely required.

---

## 16. Cross-Cutting Lessons (from real practice runs)

1. **When every step of the flow shows "nothing wrong," that itself is the answer** — it usually means the incident is a *process lifecycle* issue (many idle children under one parent) rather than a resource-contention issue. Don't treat a clean flow as a dead end; it's telling you to look at process *structure*, not usage.
2. **Never act on a single snapshot of anything** (top, ps, free) — always confirm sustained behavior over multiple samples (`pidstat 1 5`, `vmstat 1 5`) before taking action.
3. **Trust the most direct, real-time evidence over the calmer-looking summary metric** when they disagree — e.g. sustained `so` (swap-out) over a lagging "available" reading; a `dmesg` OOM-kill entry over a healthy-looking `df -h`.
4. **Symptoms described in an alert are not proof of root cause.** "Logs breaking" doesn't mean `/var/log` is the culprit; "writes failing" doesn't necessarily mean disk is full (could be a memory-cgroup limit instead). Always verify empirically rather than chasing the alert's own framing.
5. **Killing something requires first correctly identifying its role in a hierarchy** — parent vs. child, controller vs. transient worker, T-state vs. D-state — because the wrong target either does nothing (killing an already-dead zombie, killing a worker that's already been replaced) or makes things worse (killing a parent mid-fork without freezing it first, leaving orphans).
6. **Broad-name kills (`pkill -f <generic name>`) are a common real-world cause of self-inflicted outages** — always preview with `pgrep -f` and prefer precise `kill <pid>` when the name isn't unique enough to safely match only the intended target.