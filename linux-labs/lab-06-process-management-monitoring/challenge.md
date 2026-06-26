# Challenge — Process Management & System Monitoring
## The standard: production-grade instinct, no hand-holding

These challenges give you a situation. Not a list of commands to run.
You decide what to run, in what order, and why.
If you finish a challenge and can't explain every decision, you haven't passed it.

---

## Rules

- No notes. No looking at previous scripts.
- Before every command: write down what you expect to see.
- After every command: write down what you actually saw and whether it matched.
- If something surprises you, stop and figure out why before moving on.
- Every answer must include the actual command you ran and the actual output.
- "I think it works" is not a pass. Show the verification.

---

## Challenge 1 — Ancestry Investigation

You have a running terminal. Without being told which commands to use:

1. Find your shell's PID and its parent's PID.
2. Find your parent's parent's PID. Keep going until you hit PID 1.
3. Name every process in that chain and explain what each one does.
4. Start a subshell. Inside it, start another subshell. Map the full three-level ancestry tree with actual PIDs.

You pass when you can draw this on paper from memory:

```
PID 1 (what process?) → PID ? (what?) → PID ? (your shell) → PID ? (subshell) → PID ? (subshell's subshell)
```

Harder question: PID 1 is the ancestor of every process on the system. What happens to a process whose parent dies before it does? What adopts it and why does that matter?

---

## Challenge 2 — ps Output Forensics

Run `ps aux` and pick five processes you don't recognise.

For each one:
- What is it?
- Who started it?
- Why is it running?
- Is it normal for it to be running on this machine?
- What would happen if you killed it?

You are not allowed to kill any of them. You are only allowed to observe and reason.

Then answer: `ps aux` shows `%CPU` as a percentage. A process shows `143.2%`. How is that possible? What does it actually mean?

---

## Challenge 3 — The Orphan Problem

This is not guided. Figure it out.

1. Write a script that forks a child process (hint: run a background job from inside the script itself).
2. Make the parent script exit while the child is still running.
3. Prove the child is still alive after the parent is gone.
4. Find the child's new parent PID and explain why it changed.
5. Now find and kill the orphan using only its name, not its PID.

Write down every command you used and why. If you had to try something twice, record the first failure and explain it.

---

## Challenge 4 — Signal Mastery

You need to know these signals cold, not just SIGTERM and SIGKILL.

Without looking anything up, explain what each of these signals does, when you'd use it, and what the process experiences:

- SIGTERM (15)
- SIGKILL (9)
- SIGSTOP (19)
- SIGCONT (18)
- SIGHUP (1)
- SIGINT (2)

Then do this practically:

1. Start `long_task.sh` in the background.
2. Freeze it with a signal (not kill it — freeze it).
3. Confirm it is frozen using `ps aux`. What does the STAT column show? What does that letter mean?
4. Resume it with a signal.
5. Send it SIGHUP. What happens? Why is SIGHUP interesting for server daemons specifically?

Hard question: if a process catches SIGTERM and ignores it (some processes do this), what are your options short of SIGKILL? What's the right order of escalation?

---

## Challenge 5 — The Noisy Neighbour Scenario

This simulates a real incident. Do not skip steps.

**Setup** (run this yourself — do not read ahead):

```bash
for i in 1 2 3; do
  ./process-lab/scripts/long_task.sh &
done
```

Now, without using `jobs`:

1. Find all three processes. How many methods can you use? Use at least two different ones.
2. Determine which of the three is using the most CPU right now.
3. Kill only that one. Leave the other two running.
4. Verify it is dead. Verify the other two are still alive.
5. Now kill the remaining two — but using a single command, not two separate kills.
6. Verify nothing remains.

If at any point you kill the wrong process, record it, explain why it happened, and continue. That failure is part of the exercise.

---

## Challenge 6 — Terminal Survival Test

You have a long-running job. Your goal is to make it survive in every scenario below. Do each one separately.

**Scenario A:** The job is already running in the background. Your terminal is about to close. Make it survive without restarting it.

**Scenario B:** You haven't started the job yet. Start it in a way that it survives terminal closure, and redirect its output to `process-lab/logs/survivor.log`.

**Scenario C:** You used nohup and the job is running. Prove it is actually detached — not just backgrounded — and explain the specific mechanism that keeps it alive.

**Scenario D:** You need the job's output in real time even though it's detached. How do you watch it without re-attaching to the process?

For each scenario, after you complete it, close your terminal (or simulate it), reopen it, and verify the process is still running.

---

## Challenge 7 — Load Average Under Pressure

**You cannot just read the numbers. You have to reason about them.**

Generate some artificial load:

```bash
yes > /dev/null &
yes > /dev/null &
```

Wait 60 seconds. Then run `uptime` and answer:

1. What are the three numbers now versus before you ran those jobs?
2. Which number changed most and why?
3. You have N cores (check with `nproc`). At what load average would you start to be concerned? At what point is it definitively a problem? At what point is it a crisis?
4. The 1-minute average is higher than the 15-minute average. What does that tell you about the trend? What action do you take versus if it were the other way around?
5. Kill those `yes` processes. Watch the load average recover over the next few minutes. Why doesn't it drop instantly?

Hard question: load average counts both CPU-bound and I/O-wait processes. A system with a load average of 8 on a 4-core machine might be completely fine or completely dying. What additional check tells you which it is?

---

## Challenge 8 — Memory Pressure Simulation

You need to understand memory under real pressure, not just read the columns.

1. Run `free -h` and record every column. Write down in plain English what each number means — not the definition, what it means right now on your specific machine.
2. The "free" column is almost certainly very low. Explain why this is not a problem.
3. The "available" column is the one that matters. How much headroom do you actually have?
4. Swap: if `used` is greater than zero, is that automatically bad? When does it become bad?

Now find the top 5 memory-consuming processes on your machine. For each one, answer: is this memory usage expected? Could you kill it if you had to?

Hard question: a process shows 8% in the `%MEM` column of `ps aux`. Your machine has 16GB of RAM. How many MB is that process actually using? Now explain why even that number is misleading and what VSZ vs RSS actually tell you.

---

## Challenge 9 — Disk Forensics Without a Map

Your task is to find the largest thing on your filesystem without being told where to look.

Rules:
- Start at `/`
- Use only `df` and `du`
- Drill down until you find the single largest file or directory consuming space
- Record every command you ran and the output that told you to go deeper

Then answer:
- `df -h` shows 60% used on `/dev/sda1`. `du -sh /` shows only 20GB used. The filesystem is 100GB. Where is the missing ~40GB? (This is a real phenomenon — explain what causes it.)
- A disk is at 95% and you need to free space fast. What's your decision tree? Walk through it step by step.

---

## Challenge 10 — Process Substitution: Real Use Cases

Process substitution is not just for `diff`. Find three real use cases where `<(...)` solves something that would otherwise require temp files or multiple steps.

Write each one as:
- The problem
- The naive solution (with temp files)
- The process substitution solution
- Why it's better

Then explain under the hood: when you write `<(ls /tmp)`, what does the shell actually create? What path does it give to the receiving command? What happens to it after the command finishes?

---

## Challenge 11 — Build the Diagnostic Tool, Harder Version

You built `health_snapshot.sh` in the lab. Throw it away. Build `system_check.sh` from scratch with these additional requirements that weren't in the lab:

1. It must detect if any filesystem is above 85% usage and print a WARNING line for each one.
2. It must detect if load average (1-min) exceeds the number of CPU cores and print a WARNING.
3. It must detect if available memory is below 15% of total and print a WARNING.
4. All WARNINGs must also be written to a separate `process-lab/logs/alerts.log` with a timestamp.
5. If there are zero warnings, it prints: `System healthy — no alerts.`
6. It must exit with code `0` if healthy, `1` if any warnings were generated.
7. Every section must be separated clearly in the output report.
8. The script must handle the case where `process-lab/logs/` doesn't exist yet.

Pass condition:
- Script runs clean with `bash -x` (trace mode) and you can explain every line the trace shows
- You force a warning condition artificially (e.g. fake a high load) and confirm the alert fires
- Exit code is correct in both the healthy and warning cases
- You can explain every line without reading from it

---

## Challenge 12 — Cold Incident Simulation

This is the final challenge. No structure given. No hints.

**The scenario:**

You SSH into a server. A teammate has told you: "it's been slow for the last 20 minutes, I don't know why."

You have no dashboard. You have no prior knowledge of what should be running.

Document your full investigation as if writing a real incident report:

- What you checked first and why
- What each tool showed you
- What hypotheses you formed
- How you confirmed or ruled out each one
- What the actual cause was (you decide — simulate it yourself and then diagnose it)
- What you did to fix it
- How you verified the fix worked
- What you'd do to prevent it in future

The report must be written as if handing it to a senior engineer who will read it critically. Vague statements like "I checked memory and it looked fine" will not pass. Show the numbers. Show the commands. Show the reasoning.

---

## What separates 0.01% from the rest

The engineers who pass these challenges aren't faster at typing commands.
They're better at three things:

**1. They predict before they act.**
Before every command they have a hypothesis. The command either confirms it or forces them to revise. They never run commands hoping something useful appears.

**2. They verify everything.**
Killing a process and assuming it's dead is not the same as killing a process and confirming it's dead. Every action has a corresponding verification step.

**3. They understand the why, not just the what.**
`kill -9` works. But knowing *why* SIGKILL cannot be caught or ignored — that it bypasses the process entirely and goes straight to the kernel — is what lets you reason about edge cases, explain decisions to teammates, and design systems that handle failure gracefully.

If you can do all twelve challenges above with no notes, explain every decision, and write a clean incident report at the end: you're there.