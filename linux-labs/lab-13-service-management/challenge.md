# Lab 13 — Challenge (Final Mastery Check)

No notes. No rounds, no categories — one continuous build, straight through, in order. Narrate every judgment call and run the full five-step flow (state → logs → diagnose → fix → verify) the instant anything breaks, even if you already know the fix. If you have to open instructions.md at any point, that's the redrill signal, not a pass.

---

## The Build

**1. Design and write the unit file, from these requirements, whole — not directive names in isolation:**
Runs as a dedicated non-root user you create for it. Restarts automatically on crash, but does not fight you when you deliberately stop it. Waits for basic networking before it starts. Description reads "Placeholder Worker."

**2. Apply it and prove both halves separately:**
`daemon-reload`, then get it running *now* and wired to survive the *next* reboot — confirm each one with its own correct one-word command, not `status`'s full output for either.

**3. Break it — genuine syntax error in the script.**
Full five-step flow, no shortcuts. Fix it. Verify.

**4. Break it a different way — `ExecStart` pointing at a path that no longer exists.**
Full five-step flow. Fix it. Verify.

**5. Break it a third way — starts, exits immediately, set to restart on failure.**
Full five-step flow. Before touching the fix, say out loud whether the restart policy is hiding a real bug or doing its job. Fix it. Verify it's genuinely stable, not just quiet for the moment.

**6. Make it "up" but wrong — active by every internal measure, listening on the wrong port relative to what a real check expects.**
Prove `status` alone would have missed this. Fix the mismatch. Verify with the actual check, not the unit's state.

**7. Add a second, real dependency — a placeholder service this one genuinely needs, wired with inclusion only, no ordering.**
Start both together, repeatedly, until you catch the race. State out loud what the directive already there guarantees and what it doesn't — before you touch anything. Fix it correctly. Confirm the race is gone.

**8. Make a live change that needs zero downtime — update the description text.**
Apply it the right way. Confirm the PID didn't change.

**9. Make a different live change that actually requires the process to restart.**
Apply it the right way. Confirm the PID *did* change this time. Say out loud why the "just push it live" instinct from step 8 would have been wrong here.

**10. Write a one-line health check for it** — the kind of thing a real monitoring script would call.
Explain why the human-readable status command would break that script if you used it instead.

**11. Tear everything down** — this service and its dependency.
Confirm with the box-wide failed-unit check that nothing's left lingering or broken behind you.

---

## Close It Out — Explain It Cold

One sentence each, no hedging, before this counts as done:

1. Actual difference between starting and enabling a service?
2. Actual difference between restart and reload?
3. "Enabled" and "active" are two separate things — what does each one actually tell you?
4. Why do you have to make systemd re-read a unit file after hand-editing it?
5. What does an ordering directive guarantee that a bare dependency directive doesn't, and vice versa?
6. What's the fixed troubleshooting order, and why does diagnosis have to come before the fix?

---

## Pass Criteria

- Every command came from memory — zero lookups, zero hesitation.
- Every judgment call was stated *before* acting on it, not corrected after guessing wrong.
- The five-step flow ran in full, in order, every single time — including the times you already knew the fix.
- The unit file in step 1 was written whole, correctly, from the requirements alone.
- All six closing questions answered cold, one sentence each.

If any of these needed a peek at instructions.md, that's exactly what to redrill — not a pass yet.