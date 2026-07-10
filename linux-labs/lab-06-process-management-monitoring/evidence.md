# Evidence — Lab 06: Process Management & System Monitoring

---

## Environment Setup

- Provisioned an isolated Docker container (`process-lab`) for safe incident simulation
- Installed required tooling: `procps`, `sysstat`, `stress-ng`, `psmisc`, `python3`
- Verified tool availability before starting scenario work

---

## Completed Scenarios

### Scenario 1 — The Runaway Worker

**Setup:** `stress-ng --cpu 2 --cpu-load 85 &`

| Step | Command | Observation | Decision |
|---|---|---|---|
| 1 | `uptime` | Load average below `nproc` but climbing | Climbing trend is the trigger to investigate, not the raw number |
| 2 | `top` + press `1` | Aggregate `us+sy` looked low, but per-core view showed one core fully saturated | Confirms single-process CPU contention hiding in the aggregate |
| 3 | `top` (STAT column) | `R` count exceeded `D` count | Confirms CPU contention, not I/O blocking |
| 4 | `pidstat 1 5` | Same PID sustained ~85% CPU across all five samples | Sustained, not a spike — safe to act |
| 5 | `kill <pid>` → `ps -p <pid>` | Process gone after SIGTERM | Verified before declaring resolved |
| 6 | `uptime` | Load average dropped back toward baseline | Confirmed full resolution |

**Pattern recognised:** load climbing + one core maxed (per-core view) + `R` dominant + `pidstat` sustained → runaway single process.

---

### Scenario 2 — The Kernel Hog

**Setup:** four `cat /dev/urandom > /dev/null &` processes

| Step | Command | Observation | Decision |
|---|---|---|---|
| 1 | `top` | `sy` high, `us` low | Kernel-level work, not application logic — every `read()` on `/dev/urandom` is a syscall |
| 2 | `top` + press `1` | Multiple cores saturated at the kernel level | Confirms syscall-heavy processes across cores |
| 3 | `top` (STAT column) | `R` dominant | CPU contention confirmed |
| 4 | `pidstat 1 5` | All four PIDs sustained high `%CPU` every sample | Not a spike |
| 5 | `pkill -f cat` | All matching processes terminated in one command | Efficient cleanup — verified afterward |
| 6 | `ps aux \| grep cat` | No matching processes remained | Verified before closing the incident |

**Pattern recognised:** `sy` high + `us` low + `R` dominant + `pidstat` sustained → kernel/syscall-heavy process.

---

### Scenario 3 — The Silent Leak

**Setup:** Python script forking 10 children that all sleep indefinitely

| Step | Command | Observation | Decision |
|---|---|---|---|
| 1 | `uptime`, `top` | Load below `nproc`, `us+sy` low, `id` high | No CPU problem |
| 2 | `vmstat 1 5` | `b` = 0, no blocked processes | No I/O problem |
| 3 | `pidstat 1 5` | Empty — nothing consuming CPU | Every step of the flow returning "nothing" is itself the signal — this is a lifecycle issue, not a dead end |
| 4 | `ps -eo pid,ppid,stat,cmd` | Ten processes sharing the same `PPID`, all in `S` state | Confirms child pool under one parent |
| 5 | `pstree -p <ppid>` | Full parent-child tree visible | Verified the hierarchy before acting |
| 6 | `kill <ppid>` → `ps -eo pid,ppid,stat,cmd` | Children reparented to init and cleared | Killing the parent is the correct target, not the children |

**Pattern recognised:** flow gives nothing at every step + `ps` shows many processes sharing one `PPID`, all `S` → process lifecycle problem → kill the parent.

---

### Scenario 4 — The Fork Bomb

**Setup:** `ulimit -u 50` + unbounded `os.fork()` loop

| Step | Command | Observation | Decision/Action |
|---|---|---|---|
| 1 | `watch -n1 'ps aux \| wc -l'` | Total process count climbing rapidly | Confirmed fork bomb, not a stable lifecycle pattern |
| 2 | `watch -n1 'ps -eo ppid \| sort \| uniq -c \| sort -rn \| head'` | One PPID spawning far more children than any other | Identified the runaway parent |
| 3 | `kill -STOP <parent_pid>` | Process frozen | Freezing first prevents one more fork slipping through between kill and death, avoiding orphans |
| 4 | `kill <parent_pid>` | Parent terminated cleanly | SIGTERM tried before SIGKILL, per constraint |
| 5 | `pkill -P <parent_pid>` | Remaining direct children cleaned up | Removed leftovers not reparented in time |
| 6 | `ps aux \| wc -l` | Count dropped back to baseline and stayed stable | Confirmed resolution |

**Answers:**
- Confirmation of a fork bomb: sustained, climbing process count via `watch`.
- Freeze before kill: prevents the parent forking again mid-termination and leaving orphaned children.
- Freeze signal: `SIGSTOP` (`kill -STOP`).
- Correct order: `STOP` → `kill` → `pkill -P` for stragglers → verify count.
- Stabilisation confirmed via repeated `ps aux | wc -l` readings holding steady.

---

### Scenario 5 — The Zombie Factory

**Setup:** loop spawning short-lived `sleep 0.1` children via `subprocess.Popen` without reaping them

| Step | Command | Observation | Decision/Action |
|---|---|---|---|
| 1 | `ps -eo pid,ppid,stat,cmd` | Multiple entries with `STAT = Z` | Zombies identified by the `Z` code |
| 2 | `kill -9 <zombie_pid>` | No effect | A zombie is already dead — there is nothing left to signal, it is a process-table entry the parent never reaped |
| 3 | `ps -eo pid,ppid,stat,cmd` | Zombies all shared the same `PPID` | Located the responsible parent |
| 4 | `kill <ppid>` | Parent terminated | Killing the parent forces the kernel to reap its zombie children |
| 5 | `ps -eo pid,ppid,stat,cmd \| grep Z` | No zombie entries remained | Verified the storm had stopped |

**Answers:**
- Zombies are shown via `ps -eo pid,ppid,stat,cmd` (`STAT = Z`).
- A zombie cannot be killed directly — it has already finished executing; only the process-table entry remains until the parent calls `wait()`.
- The actual fix is killing the parent, forcing reaping.
- A small, fixed zombie count is harmless housekeeping; it becomes dangerous only if the count keeps climbing (a true "zombie storm"), indicating the parent never reaps at all.
- Verified via re-checking `ps` for `Z` entries and confirming growth had stopped.

---

### Scenario 6 — The Disguised Problem

**Setup:** three `stress-ng --cpu 1 --cpu-load 40` processes + five `sleep infinity` processes

| Step | Command | Observation | Decision |
|---|---|---|---|
| 1 | `uptime` | Load below `nproc` but climbing | Investigation still warranted |
| 2 | `top` | `us` moderately high, `sy` low, `id` slightly reduced | CPU flagged as a suspect, not yet confirmed |
| 3 | `watch -n1 'ps -eo ppid \| sort \| uniq -c \| sort -nr \| head'` | Child counts static — no growth | Ruled out a fork bomb |
| 4 | `vmstat 1 5` | `b` = 0 across samples | Ruled out I/O blocking |
| 5 | `pidstat 1 5` | Only the three `stress-ng` PIDs showed sustained CPU; the `sleep` PIDs never appeared | `pidstat` is the source of truth for "who to kill" — a process that never shows sustained CPU there is not the problem |
| 6 | `pkill -f stress-ng` | All three stress workers terminated | Targeted only the confirmed offenders |

**Correction made:** an initial `pkill -f sleep` was run before checking `pidstat` closely — this was unnecessary, since the `sleep infinity` processes were in `S` state at 0% CPU and never appeared in `pidstat`. Lesson reinforced: `S` state + 0% CPU + absence from sustained `pidstat` output = innocent; do not touch it just because it is present alongside the real problem.

---

### Scenario 7 — The Priority Inversion

**Setup:** `stress-ng --cpu 3 --cpu-load 60 &` (cannot be killed)

| Step | Command | Observation | Decision/Action |
|---|---|---|---|
| 1 | `ps -eo pid,ppid,stat,%cpu,ni,pri,cmd \| grep stress-ng` | All matching processes at default `NI` (0) | Baseline priority confirmed before changing anything |
| 2 | `renice 10 -p <pid>` | Nice value raised | Higher nice value = lower scheduling priority = process yields more CPU to others |
| 3 | `ps -eo pid,ppid,stat,%cpu,ni,pri,cmd \| grep stress-ng` | `NI` updated to 10, `PRI` recalculated accordingly | Verified the change took effect |

**Answers:**
- Current priority is shown via the `NI` column from `ps -eo ...,ni,pri,...`.
- Nice values range from -20 (highest priority) to 19 (lowest); higher = more polite/lower priority.
- Priority of a running process is changed with `renice <value> -p <pid>`.
- Renicing does not help a process in `D` state — it is blocked on a kernel call, not competing for CPU scheduling time.
- Verified by re-running the `ps` check and confirming `NI`/`PRI` changed.
- `nice` sets priority at launch time; `renice` changes it for an already-running process.

---

### Scenario 8 — The Orphan

**Setup:** `nohup bash -c 'while true; do echo exporting >> /tmp/export.log; sleep 2; done' & disown`

| Step | Command | Observation | Decision/Action |
|---|---|---|---|
| 1 | `pgrep -f export` / `ps -eo pid,ppid,stat,cmd \| grep export` | PID located by command text, not by job table | `jobs -l` was ruled out — the process was disowned, so it no longer appears in the shell's job table |
| 2 | `tail -f /tmp/export.log` | New lines continuing to append | Confirmed the process was alive and making progress |
| 3 | `kill <pid>` | Process exited cleanly | SIGTERM allows any in-flight write to finish rather than corrupting output, unlike `kill -9` |
| 4 | `ps -p <pid>` / `tail -f /tmp/export.log` | No process found; log stopped growing | Verified full termination |

**Answers:**
- Found by command text via `pgrep -f` or `ps` + `grep`, since the PID was unknown.
- Progress confirmed by tailing the output log for new entries.
- `disown` detaches a process from the shell's job table after it is already running, so the SIGHUP sent on terminal close is never delivered to it — the process survives independently of the terminal session.
- Terminated safely with plain `kill` (SIGTERM) rather than `-9`, allowing any in-progress write to complete.
- Verified stopped via `ps -p <pid>` returning nothing and the log file no longer growing.

---

### Scenario 9 — The Unkillable Process

**Setup:** `sleep infinity &` frozen with `kill -STOP $PID`

| Step | Command | Observation | Decision/Action |
|---|---|---|---|
| 1 | `ps -eo pid,stat,cmd` | `STAT = T` | Deliberately stopped process, not blocked in the kernel |
| 2 | `kill -CONT <pid>` | Process resumed | `SIGCONT` unfreezes a stopped process |
| 3 | `kill <pid>` / `kill -9 <pid>` | Process terminated | A `T`-state process is fully killable, directly or after resuming |

**Answers:**
- `D` state, not `T` state, causes `kill -9` to genuinely fail — `T` state always accepts `SIGKILL` directly.
- `T` state = deliberately frozen (`SIGSTOP`/Ctrl+Z), alive and killable; `D` state = blocked inside a kernel call, unable to receive any signal including `SIGKILL`.
- `SIGCONT` (`kill -CONT`) resumes a stopped process.
- Distinguished via the `STAT` column of `ps -eo pid,stat,cmd`.
- Correct action: `T` state → `kill -9` directly, or `kill -CONT` then `kill`; `D` state → cannot be killed at all — inspect `wchan` to find the blocking resource and resolve the underlying blocker.

---

### Scenario 10 — The Mixed Incident

**Setup:** `stress-ng --cpu 1 --cpu-load 80`, an 8-way fork/sleep lifecycle pool, and `cat /dev/urandom > /dev/null`

| Step | Command | Observation | Decision/Action |
|---|---|---|---|
| 1 | `top` (+`1`) | Load above `nproc` but still climbing; two cores heavily loaded, `id` low | CPU flagged as a suspect |
| 2 | `top` (STAT) | `R` > `D` | Confirmed CPU contention |
| 3 | `pidstat 1 5` | Sustained high `%CPU` on the `stress-ng` and `cat` PIDs | Confirmed genuine, not a spike |
| 4 | `pkill -f cat` / `pkill -f stress-ng` | Both terminated | Resolved the CPU-contention portion first, since it directly affects response times |
| 5 | `ps -eo pid,ppid,stat,cmd` | Remaining processes were all `S` state, 0% CPU, sharing one `PPID` | No action needed on CPU grounds |
| 6 | `watch -n1 'ps -eo ppid \| sort \| uniq -c \| sort -nr \| head'` | Child count static | Ruled out a fork bomb — confirmed lifecycle issue instead |
| 7 | `kill <ppid>` → `ps -eo pid,ppid,stat,cmd \| grep python3` | No leftover children | Verified the parent's children were reparented and cleared |

**Answers:**
- Overlapping symptoms were separated by walking the flow's CPU path and lifecycle path independently rather than reacting to the alert's framing.
- CPU contention was fixed first, since it was actively driving the reported slowness; the lifecycle pool was confirmed harmless before deciding whether to clean it up.
- Each fix was verified independently (`pidstat`/`ps` re-checks) before moving to the next.
- Full recovery confirmed with `top`, `uptime`, and a final `ps -eo pid,ppid,stat,cmd` sweep.

---

### Scenario 11 — The Signal Decision

**Setup:** a bash loop trapping `SIGTERM` to run cleanup before exiting

| Signal | Command | Observation |
|---|---|---|
| SIGTERM | `kill <pid>` | Trap fired — "TERM caught, cleaning up" printed, then exited gracefully after its cleanup delay |
| SIGSTOP | `kill -STOP <pid>` | Process froze immediately, no further output |
| SIGCONT | `kill -CONT <pid>` | Process resumed exactly where it left off |
| SIGKILL | `kill -9 <pid>` | Process terminated instantly, no cleanup output |

**Takeaways:**
- `SIGTERM` is the correct first choice whenever graceful cleanup matters (avoiding data loss or partial writes) — it can be caught and handled.
- `SIGKILL` cannot be caught, ignored, or blocked; it is the last resort when a process ignores `SIGTERM` or force-termination is required.
- `SIGSTOP`/`SIGCONT` are for freezing/resuming without terminating — useful for controlling a process (e.g. a fork bomb parent) before deciding its fate.
- `SIGHUP` is used by daemons as a "reload configuration" signal.
- `SIGINT` (Ctrl+C) terminates a foreground process; `SIGTSTP` (Ctrl+Z) suspends it, alive and recoverable.

---

### Scenario 12 — The Blocked Terminal

**Setup:** an accidentally foregrounded backup loop blocking the terminal

| Step | Command | Observation | Decision/Action |
|---|---|---|---|
| 1 | `Ctrl+Z` | Process suspended, terminal freed, `STAT = T` | Process still alive, just paused |
| 2 | `bg` | Process resumed running in the background | Backup continued uninterrupted |
| 3 | `jobs` | Job listed as running | Confirmed background execution |
| 4 | `disown` | Job removed from the shell's job table | Backup now survives terminal close, without needing to have been started with `nohup` |

**Answers:**
- Suspended without killing via Ctrl+Z (`SIGTSTP`).
- Resumed in the background with `bg`.
- Listed with `jobs` (or `jobs -l` for PIDs).
- Brought back to the foreground with `fg`.
- Detached from the shell with `disown` so it survives terminal closure.
- `nohup` protects a process from the start (applied before launch); `disown` protects it after the fact (applied to an already-running background job). Both prevent `SIGHUP` from ending the process on terminal close.

---

### Scenario 13 — The Wrong Kill

**Setup:** two legitimate `python3` services plus one CPU-burning bad process

| Step | Command | Observation | Decision/Action |
|---|---|---|---|
| 1 | `uptime` | Load climbing but below `nproc` | Investigation warranted |
| 2 | `pgrep -f python3` | All three PIDs matched, including the two services | Confirmed `pkill -f python3` would be too broad and take down the services |
| 3 | `ps -eo pid,ppid,stat,cmd,%cpu` | The bad process was clearly identifiable by its near-100% CPU and its distinct command string | Isolated the correct target by evidence, not by name pattern |
| 4 | `kill <bad_pid>` | Bad process terminated | Used a precise, single-PID kill rather than a broad pattern match |
| 5 | `ps -eo pid,cmd \| grep python3` | Both service processes still present and running | Verified the services were untouched |

**Answers:**
- `pkill -f python3` is dangerous because the match string is too generic — it kills every process containing "python3" in its command line, not just the intended target.
- `pgrep -f python3` previews exactly what a matching `pkill` would hit, before anything is killed.
- The bad process was identified by its CPU usage and distinct command content in `ps -eo pid,ppid,stat,cmd,%cpu`.
- Killed with a precise `kill <pid>` rather than a name-based broad kill.
- Verified the services survived by re-checking the process table for their PIDs/commands after the kill.

---

### Scenario 14 — The Memory Pressure Mystery

**Setup:** `stress-ng --vm 2 --vm-bytes 80% --timeout 60s`

| Step | Command | Observation | Decision |
|---|---|---|---|
| 1 | `top` | CPU around 5%, nothing dominant | CPU ruled out as the cause |
| 2 | `free -h` | `available` memory dropping sharply | Real memory pressure, not just high cached usage |
| 3 | `vmstat 1 5` | `si`/`so` active and sustained | Confirmed the system was actively swapping |
| 4 | `ps aux --sort=-%mem \| head` | `stress-ng` (vm workers) at the top by `%MEM` | Identified the memory consumer |
| 5 | `kill <pid>` (controller) | Memory released | Killed the stable parent/controller rather than a transient worker |
| 6 | `free -h` / `vmstat 1 5` | `available` recovering, swap activity dropping to zero | Verified resolution |

**Answers:**
- CPU stayed low because the bottleneck was memory reclamation and swapping, not computation.
- `free -h`'s `available` column reflects realistically usable memory (including reclaimable cache); high `buff/cache` with healthy `available` is normal and not a problem on its own.
- The memory consumer was identified via `ps aux --sort=-%mem`.
- Swapping was confirmed via sustained `si`/`so` activity in `vmstat`.
- Heavy swap usage degrades performance directly, since disk is far slower than RAM — this is the primary driver of the "CPU looks fine but everything is slow" symptom.

---

### Scenario 15 — The Disk Explosion

**Setup:** 200 MB `tmpfs` mount filled to ~90% with a bloat file

| Step | Command | Observation | Decision |
|---|---|---|---|
| 1 | `df -h` | `/mnt/faketest` at ~90%+ `Use%` | Confirmed real disk pressure on that filesystem specifically |
| 2 | `du -sh /mnt/faketest/*` | `bloatfile` accounted for nearly all the used space | Located the hotspot directly rather than assuming `/var/log` was responsible |
| 3 | `rm -f /mnt/faketest/bloatfile` | File removed | Verified safe to delete before removing (test artifact, not production data) |
| 4 | `df -h` | `Use%` dropped back down | Verified space recovered |

**Answers:**
- Disk was confirmed full via `df -h`, not assumed from the alert.
- The affected filesystem was the `tmpfs` mount at `/mnt/faketest`.
- `du -sh /mnt/faketest/*` identified the fastest-growing/largest item directly.
- `/var/log` was not automatically treated as guilty — it was ruled out by checking the actual hotspot with `du`.
- Cleanup was safe because the file was a known test artifact; a real incident would additionally check `lsof <file>` to confirm no running process still had it open before assuming space was reclaimed.

---

### Scenario 16 — Mixed Resource Saturation

**Setup:** light CPU stress (`--cpu-load 20`) combined with heavy memory stress (`--vm-bytes 70%`)

| Step | Command | Observation | Decision |
|---|---|---|---|
| 1 | `top` | ~83% idle; one process consistently near its expected 20% load | CPU alone did not explain the reported slowness |
| 2 | `pidstat 1 5` | That process's CPU usage was stable and bounded, not runaway | Ruled out CPU as the sole cause |
| 3 | `vmstat 1 5` | `so` consistently above 1,000,000 across all five samples | Confirmed active, sustained swap pressure |
| 4 | `free -h` | `available` showed ~6.4 GiB, looking healthy at a glance | Recognised this metric can mask real pressure and should not override the swap evidence |
| 5 | `ps -eo pid,ppid,stat,cmd` | Stressor workers were short-lived children of stable controller PIDs | Correct kill target identified as the controller, not the transient worker |
| 6 | `kill <worker_pid>` | Failed — process already replaced by a newly forked worker | Confirmed workers are not stable kill targets |
| 7 | `kill <controller_pids>` | Both `stress-ng` controllers terminated successfully | Verified via `free -h` and `vmstat` returning to baseline |

**Answers:**
- This was a memory-driven problem masquerading as a marginal CPU issue — both metrics needed to be checked at depth.
- CPU looked fine because the load generator was deliberately light; the real cost was swap I/O, not computation.
- Swapping (`si`/`so` in `vmstat`) is ground-truth evidence of pressure; `%MEM` alone does not show whether the system is actually compensating via disk.
- `free -h`'s `available` figure can look calm while swap activity is heavy — it is not reliable in isolation and should always be cross-checked against `vmstat`.
- Memory pressure was confirmed via sustained `vmstat` swap activity even though the "available" snapshot looked healthy.

---

## Break/Fix Tasks

**Kill a child instead of the parent in a fork scenario**
- Killed one child PID directly; the remaining children and the parent were unaffected and continued running.
- Correction: re-ran the exercise killing the parent PID instead, confirming all children were reparented and cleaned up as expected.

**Run `kill -9` on a process in T state**
- Froze a `sleep infinity` process with `SIGSTOP`, then issued `kill -9`.
- Observed the process terminated immediately, unlike a D-state process, confirming `T` state is fully killable because it is alive and merely suspended, not blocked inside the kernel.

**Attempt to kill a zombie directly with `kill -9`**
- Located a zombie PID via `ps -eo pid,ppid,stat,cmd | grep Z`.
- `kill -9 <zombie_pid>` had no effect, confirming a zombie cannot be killed since it is already dead.
- Applied the correct fix: killed the parent process, which reaped the zombie entry.

**Use Ctrl+C instead of Ctrl+Z on a foreground process**
- Ctrl+C terminated the process permanently (`SIGINT`).
- Ctrl+Z suspended it instead, leaving it alive and recoverable (`SIGTSTP`).
- Confirmed Ctrl+Z is the correct choice whenever the process needs to be preserved (e.g. to background it later); Ctrl+C is correct when the intent is genuinely to stop it.

---

## Challenge Incidents

### Incident 01 — Multiple Overlapping Symptoms

**Setup:** CPU stressor, an 6-way fork/sleep lifecycle pool, and a short-lived zombie-spawning loop

| Step | Command | Observation | Decision |
|---|---|---|---|
| 1 | `watch -n1 'uptime'` | Load average climbing | Investigation triggered |
| 2 | `top` (+`1`) | Two cores at ~90% `us`, `wa` = 0 | CPU contention confirmed |
| 3 | `pidstat 1 5` | Two PIDs sustained ~90% CPU | Genuine, not a spike |
| 4 | `ps -eo pid,ppid,stat,cmd,%cpu` | Identified the `stress-ng` parent and a separate parent with sleeping fork children | Separated the CPU issue from the lifecycle pool |
| 5 | `kill <stress_ng_parent>` → `ps -eo pid,ppid,stat,cmd,%cpu` | Confirmed terminated after verification and a brief retry | Verified before moving on |
| 6 | `pstree -p <lifecycle_parent>` | Confirmed fork-tree shape | Understood structure before deciding |
| 7 | `watch -n1 'ps -eo ppid \| sort \| uniq -c \| sort -nr \| head'` | Child count stable, not growing | Ruled out a fork bomb |
| 8 | `free -h`, `vmstat 1 5`, `df -h` | No memory or disk pressure | Confirmed those paths were clean |

**Findings:** three distinct things were present — a genuine CPU stressor (action required), a fixed-size sleeping fork pool (harmless housekeeping, non-urgent), and no fork bomb or resource pressure elsewhere. The CPU stressor was the only item requiring immediate action; the sleeping pool was left in place as a defensible, evidence-based call since it matched the "not urgent" framing of the alert and consumed no CPU.

---

### Incident 02 — Memory vs Disk

**Setup:** `stress-ng --vm` memory stressor combined with a `tmpfs` disk-fill via `dd`

| Step | Command | Observation | Decision |
|---|---|---|---|
| 1 | `uptime`, `nproc` | No CPU pressure indicated | CPU ruled out early |
| 2 | `vmstat 1 5` | Sustained swap activity | Real memory pressure confirmed |
| 3 | `free -h` | `available` dropping, swap climbing | Corroborated `vmstat` |
| 4 | `df -h` | `/mnt/faketest` at high `Use%` | Separate, genuine disk pressure confirmed |
| 5 | `du -sh /mnt/faketest/*` | `bloatfile` was the hotspot | Located the disk offender |
| 6 | `kill <stress_ng_vm_pid>` | Memory stressor terminated | Fixed the memory issue first |
| 7 | `rm -f /mnt/faketest/bloatfile` | Disk file removed | Fixed the disk issue second |
| 8 | `vmstat 1 5`, `free -h`, `df -h`, `uptime` | Swap activity at zero, available memory recovering, disk usage back down, load trending down | Verified both fixes independently before closing the incident |

**Findings:** this was two separate, unrelated root causes rather than one — proven by walking the memory path and disk path independently and finding distinct evidence for each (sustained swap activity for memory; `df`/`du` hotspot for disk), rather than assuming from the alert's framing that uploads failing meant disk alone.

---

### Incident 03 — Four Simultaneous Process States

**Setup:** a `T`-state process, a `SIGTERM`-trapping critical service, an un-killable-by-policy CPU stressor, and a disowned long-running export job

| Step | Command | Observation | Decision/Action |
|---|---|---|---|
| 1 | `ps -eo pid,ppid,stat,cmd` | Four processes identified by `STAT`: one `T`, one `S` (trap handler), one `R`/`S` cycling (`stress-ng`), one `S` (export loop) | Classified each by state/behaviour rather than by name |
| 2 | `kill -CONT <T_state_pid>` then `kill <pid>` | Process resumed, then exited cleanly | Confirmed the "unstoppable" process was never actually unkillable — it was simply frozen (`T` state) and needed `SIGCONT` before a normal kill would take effect |
| 3 | `ps -eo pid,ppid,stat,%cpu,ni,pri,cmd \| grep stress-ng` → `renice 10 -p <pid>` → re-check | `NI` raised from 0 to 10, `PRI` recalculated | Since the stressor could not be killed, its scheduling priority was lowered instead, freeing CPU for the protected critical service |
| 4 | `pgrep -f export` / `tail -f /tmp/export.log` | PID located; log actively growing | Confirmed the disowned job was alive and healthy |
| 5 | `kill <export_pid>` → `ps -p <pid>` | Process exited cleanly, log stopped growing | Terminated the old job with `SIGTERM` for a clean stop, verified afterward |

**Findings:** none of the four processes were genuinely unmanageable — each simply required the correct action for its actual state: resume-then-kill for `T` state, renice instead of kill for the protected competitor, and locate-verify-terminate for the disowned job. The trapping service was left untouched entirely, as the alert did not require killing it.

---

### Incident 04 — Capstone: Four Concurrent Problems

**Setup:** CPU stressor, a `ulimit`-capped fork bomb, a zombie-spawning loop, a memory stressor, and a disk-fill via `dd`

**Full sequence executed:**

```
vmstat 1 5                                              → sustained si/so, confirmed memory pressure
ps aux --sort=-%mem | head                              → located the memory-hogging stress-ng
ps -eo pid,ppid,cmd,stat                                → mapped parent/child structure
ps -eo pid,ppid,cmd,stat,%mem                            → confirmed the memory-heavy PID
kill <vm_controller_pid>                                → terminated the memory stressor's controller
pkill -P <vm_controller_pid>                            → cleaned up its remaining children
free -h                                                  → verified swap/memory trending back down
df -h                                                    → found /mnt/faketest at ~90% Use%
du -sh /mnt/faketest/*                                   → found bloatfile as the hotspot
rm -f /mnt/faketest/bloatfile                            → removed the disk hog
watch -n1 'ps -eo pid | sort | uniq -c | sort -nr'        → checked for runaway process growth, none found
ps -eo pid,ppid,cmd,stat                                 → re-checked tree, only CPU stressors remained
top                                                       → confirmed three separate stress-ng CPU groups active
pidstat 1 5                                               → confirmed CPU pressure sustained, same PIDs every sample
pkill -f stress-ng                                        → killed all remaining stress-ng processes in one shot
ps -p <pid>                                               → verified gone
df -h, uptime                                             → final confirmation both fixes held
```

**Findings:**
- Four distinct problems were expected from the setup; three showed measurable evidence during the live investigation — CPU pressure, memory pressure, and disk pressure — and were resolved in that priority order (memory first, since active swapping was degrading everything else; then disk, which was actively failing writes; then CPU).
- The `ulimit`-capped fork bomb and the zombie-spawning loop never appeared as sustained issues in any `ps` listing — the fork bomb had immediately hit its `ulimit -u 200` ceiling and errored out, and the zombie spawner exited early, both visible as an `Exit 1` in the job log before monitoring began. This was confirmed, not assumed: the fork-bomb-growth check (`watch -n1 'ps -eo pid | ...'`) was still run and returned a clean, non-growing count, providing positive evidence of absence rather than treating "nothing found" as inconclusive.
- Each fix (memory, disk, CPU) was verified independently with its own dedicated command (`free -h`/`vmstat`, `df -h`, `pidstat`/`ps -p`) before moving to the next, and a final full-system pass (`df -h`, `uptime`, `pidstat`) confirmed nothing outstanding remained.

---

## Key Patterns Recognised

```
load climbing + one core maxed + R dominant + pidstat sustained        → runaway single process
sy high + us low + R dominant + pidstat sustained                      → kernel/syscall-heavy process
flow gives nothing + many procs share one PPID, all S                  → process lifecycle problem → kill the parent
process count climbing (watch confirms)                                → fork bomb → STOP, then kill, then verify
Z in STAT, kill -9 has no effect                                       → zombie → kill the parent to force reaping
T in STAT                                                               → frozen, fully killable (direct or after SIGCONT)
D in STAT                                                               → blocked in kernel, cannot be killed by any signal
low CPU + swap activity sustained + available memory dropping          → memory pressure incident
df shows 90%+ Use% + du identifies the hotspot                          → disk pressure incident
S state + 0% CPU + never appears in sustained pidstat                  → innocent, leave it alone
```

---

## Main Takeaways

- A single snapshot (`top`, `ps`, `free`) is never sufficient evidence — every conclusion was confirmed against sustained, repeated sampling (`pidstat 1 5`, `vmstat 1 5`, `watch`) before any process was acted on.
- Classification always preceded action: CPU contention, I/O blocking, lifecycle noise, fork bomb, zombie storm, memory pressure, and disk pressure each have a distinct, evidence-based signature and require a different response — never a default `kill -9`.
- Every kill target was identified precisely — parent vs. child, controller vs. transient worker, `T` state vs. `D` state — because the wrong target either does nothing (a zombie, a replaced worker) or causes collateral damage (a broad `pkill -f python3`, an un-frozen fork bomb parent).
- `kill` (SIGTERM) was always attempted before `kill -9` (SIGKILL), and every kill was verified with `ps -p <pid>` rather than assumed successful.
- The alert's own framing was never trusted as root cause — "logs breaking" did not mean `/var/log`; "unstoppable" did not mean unkillable; a single symptom description often masked two unrelated problems that had to be proven independently.
- When metrics disagreed (a calm `free -h` against heavy `vmstat` swap activity), the more direct, real-time evidence was trusted over the calmer-looking summary figure.