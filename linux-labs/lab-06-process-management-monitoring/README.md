# Lab 06 — Process Management & System Monitoring

**Environment:** Docker container (`process-lab`) | Ubuntu base | Bash | `procps`, `sysstat`, `stress-ng`, `psmisc`, `python3`

---

## Problem

A production server can degrade for many different reasons — CPU contention, memory pressure, disk exhaustion, runaway forking, zombie processes, blocked I/O, or simple process-lifecycle noise — and from the outside, most of these look identical: "the system feels slow."

Without a repeatable investigation flow, an on-call engineer ends up guessing, killing the wrong process, or missing a second problem hiding behind the first one. This lab was built to remove the guesswork: every incident had to be **classified with evidence before anything was touched**, and every fix had to be **verified independently**, not assumed.

---

## What I Built

A controlled incident-simulation environment used to safely reproduce 16 individual scenarios, 4 break/fix drills, and a 4-incident challenge set (culminating in a multi-fault capstone), covering:

- CPU contention (single runaway process, kernel/syscall-heavy processes, disguised/mixed load)
- Process lifecycle noise vs. true fork bombs
- Zombie processes and zombie storms
- Blocked (`D` state) vs. frozen (`T` state) processes
- Priority inversion (`nice` / `renice`)
- Orphaned / disowned long-running jobs
- Signal behavior (`SIGTERM`, `SIGKILL`, `SIGSTOP`, `SIGCONT`, `SIGHUP`, `SIGINT`, `SIGTSTP`)
- Memory pressure and swap behavior
- Disk exhaustion via a safe `tmpfs` simulation
- Mixed/overlapping incidents requiring root-cause separation

Each scenario was run, diagnosed, and resolved using one consistent investigation flow — never a default `kill -9`.

---

## How I Solved It

**Investigation flow (used for every incident, no skipping):**

```
1. uptime + nproc          → is the system actually under pressure, and is it climbing?
2. top (+ press 1)         → CPU summary AND per-core view (a maxed single core can hide in the aggregate)
3. STAT column (R vs D)    → CPU contention vs. I/O blocking
4. pidstat 1 5             → sustained usage vs. a one-off spike — never act on a single snapshot
5. ps -eo pid,ppid,stat,cmd → parent/child structure, lifecycle vs. fork bomb vs. zombie
6. kill → verify with ps -p <pid> → escalate to kill -9 only if still present
```

Parallel paths were used when CPU wasn't the answer:

- **Memory path:** `vmstat 1 5` (sustained `si`/`so`) → `free -h` (`available`, not just `%MEM`) → `ps aux --sort=-%mem`
- **Disk path:** `df -h` (confirm the filesystem is actually full) → `du -sh /* | sort -rh` (drill to the real hotspot, never assume `/var/log`)

**Key decisions applied throughout:**

- `kill` (SIGTERM) was always tried before `kill -9` (SIGKILL), and every kill was verified with `ps -p <pid>` — never assumed successful.
- Parent vs. child was always identified before killing anything — killing a child in a fork-pool or a transient `stress-ng` worker does nothing useful; the stable parent/controller is the correct target.
- A fork bomb's parent was frozen (`kill -STOP`) **before** killing it, to stop it from forking one more child mid-cleanup.
- Zombies were never targeted directly (`kill -9` on a `Z`-state process does nothing) — the parent was killed instead, forcing the kernel to reap.
- `T` state (frozen, alive, fully killable) was never confused with `D` state (blocked in-kernel, cannot receive any signal, including `SIGKILL`).
- When a process couldn't be killed by policy (priority inversion scenario), `renice` was used instead of `kill` to free up CPU for the protected service.
- Broad matches like `pkill -f python3` were treated as dangerous by default — `pgrep -f` was always run first to preview exactly what a kill would hit.
- The alert's own wording was never trusted as root cause ("logs breaking" ≠ `/var/log`; "unstoppable" ≠ unkillable) — every claim was checked against actual evidence.
- When metrics disagreed — a calm `free -h` next to heavy `vmstat` swap activity — the more direct, real-time signal (swap) was trusted over the calmer-looking summary number.

---

## Proof

Screenshots to capture for each scenario (terminal output showing command, evidence, and post-fix verification):

### Core scenarios
1. **Runaway Worker** — `top` with per-core view showing one maxed core, plus `pidstat 1 5` showing sustained %CPU on one PID
2. **Kernel Hog** — `top` showing high `sy` / low `us`, plus `pkill -f cat` and confirmation it's gone
3. **Silent Leak** — `ps -eo pid,ppid,stat,cmd` showing multiple `S`-state children sharing one PPID, before/after killing the parent
4. **Fork Bomb** — `watch` output showing climbing process count, then `kill -STOP` → `kill` → stabilized count
5. **Zombie Factory** — `ps` showing `Z`-state entries, failed `kill -9` on a zombie, then parent kill clearing them
6. **Disguised Problem** — `pidstat 1 5` showing only the `stress-ng` PIDs sustained while `sleep infinity` never appears
7. **Priority Inversion** — `ps -eo pid,ni,pri,cmd` before and after `renice 10 -p <pid>`
8. **The Orphan** — `pgrep -f export` locating the PID, `tail -f /tmp/export.log` showing live growth, then clean termination
9. **Unkillable Process** — `ps -eo pid,stat,cmd` showing `T` state, `kill -CONT` resuming it, then successful kill
10. **Mixed Incident** — full sequence: CPU fix, lifecycle check, final `ps`/`top` sweep
11. **Signal Decision** — terminal output showing the TERM-trap firing ("cleaning up... done") vs. instant `SIGKILL` termination
12. **Blocked Terminal** — `Ctrl+Z` → `bg` → `jobs` → `disown` sequence in one terminal capture
13. **Wrong Kill** — `pgrep -f python3` showing all 3 matches, then precise single-PID kill with both services still running after
14. **Memory Pressure Mystery** — `free -h` + `vmstat 1 5` showing swap activity, then recovery after kill
15. **Disk Explosion** — `df -h` before/after, plus `du -sh` identifying `bloatfile`
16. **Mixed Resource Saturation** — `vmstat 1 5` showing sustained `so` alongside a healthy-looking `free -h`, proving the "calm metric" trap

### Break/Fix drills
17. Killing a child instead of the parent — surviving siblings, then corrected parent kill
18. `kill -9` on a `T`-state process — instant termination
19. `kill -9` on a zombie — no effect, followed by correct parent-kill fix
20. Ctrl+C vs Ctrl+Z on a foreground process — side-by-side outcome

### Challenge incidents
21. **Incident 01** — full multi-symptom triage output (CPU stressor isolated from harmless lifecycle pool)
22. **Incident 02** — memory path and disk path proven independently as two separate root causes
23. **Incident 03** — all four process states (`T`, protected competitor, disowned job, trap handler) resolved correctly
24. **Incident 04 (Capstone)** — full end-to-end sequence: memory → disk → CPU, with final verification sweep

---

## Break/Fix Summary

| Issue | Cause | Fix |
|---|---|---|
| Killed a child PID in a fork pool, parent/siblings unaffected | Wrong target in the hierarchy | Re-ran against the parent PID; children reparented and cleared |
| `kill -9` on a zombie had no effect | Zombie is already dead — nothing left to signal | Killed the parent instead, forcing the kernel to reap it |
| Fork bomb kept spawning between kill attempts | Parent wasn't frozen first | `kill -STOP` before `kill`, preventing one last fork mid-termination |
| `pkill -f python3` would have taken down two live services | Match string too generic | Used `pgrep -f` to preview matches, then killed only the confirmed bad PID |
| `free -h` looked healthy while system was still slow | `available` can look calm even under real swap pressure | Cross-checked `vmstat 1 5` for sustained `si`/`so` before ruling out memory |
| Assumed `/var/log` was the disk culprit | Alert wording ≠ root cause | Ran `du -sh /* | sort -rh` and found the actual hotspot (`bloatfile` in `/mnt/faketest`) |
| Tried to `renice` a D-state process expecting improvement | D state is blocked on I/O, not CPU scheduling | Recognized renice only affects scheduling priority, not kernel-blocked processes |

---

## Key Patterns Recognized

```
load climbing + one core maxed + R dominant + pidstat sustained   → runaway single process
sy high + us low + R dominant + pidstat sustained                 → kernel/syscall-heavy process
flow gives nothing + many procs share one PPID, all S             → lifecycle noise → kill the parent
process count climbing (watch confirms)                           → fork bomb → STOP, then kill, then verify
Z in STAT, kill -9 has no effect                                   → zombie → kill the parent to force reaping
T in STAT                                                          → frozen, fully killable
D in STAT                                                          → blocked in kernel, unkillable by any signal
low CPU + sustained swap activity + available memory dropping     → memory pressure incident
df shows 90%+ Use% + du identifies the hotspot                    → disk pressure incident
S state + 0% CPU + never appears in sustained pidstat              → innocent, leave it alone
```

---

## Improvements After Completion

- Learned that a single snapshot (`top`, `ps`, `free`) is never sufficient evidence — every conclusion needs sustained sampling (`pidstat 1 5`, `vmstat 1 5`, `watch`) before acting.
- Learned to classify before acting, every time: CPU contention, I/O blocking, lifecycle noise, fork bomb, zombie storm, memory pressure, and disk pressure each have a distinct signature.
- Learned that the correct kill target is not always obvious — parent vs. child, controller vs. transient worker, `T` vs. `D` state — and picking the wrong one either does nothing or causes collateral damage.
- Learned to always try `SIGTERM` before `SIGKILL`, and to verify every kill with `ps -p <pid>` rather than assume it worked.
- Learned to never trust an alert's framing as root cause — "unstoppable" didn't mean unkillable, and "logs breaking" didn't mean `/var/log`.
- Learned that when metrics disagree, the more direct real-time signal (e.g., sustained swap activity) should be trusted over a calmer-looking summary figure.

---

## Key Takeaway

Before this lab, I killed processes.

After this lab, I diagnosed systems.

Every incident has:

- a classification (CPU, memory, disk, lifecycle, fork bomb, zombie, blocked)
- a correct target (parent, child, controller, worker)
- a correct signal (SIGTERM, SIGKILL, SIGSTOP, SIGCONT)

The three questions before every action are:

1. What is this, actually — proven by evidence, not assumed from the alert?
2. Is this the right target — parent or child, controller or worker?
3. How do I verify the fix actually worked, independently, before moving on?

That is the difference between reacting to an alert and running an incident like an SRE.

---

## Next Step

[Lab 07 — Advanced Text Processing & Wildcards](../lab-07-advanced-text-processing-wildcards/)