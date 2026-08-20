# Lab 13 — Service Management (systemd) (Focused)

## Objective

Same four muscles as before, applied to systemd:

- **Muscle memory** — commands you type without thinking
- **Judgment calls** — two similar options exist, picking wrong gives you the wrong picture or the wrong fix
- **Troubleshooting flow** — a fixed process, not guesswork
- **Explain it cold** — one-sentence interview answers

Nothing below hands you the command. Where a scenario needs setting up (writing a placeholder script, breaking something on purpose), that's given as code — because building the trap isn't the skill. Resolving it is on you.

## Environment Setup

Disposable VM or container, `sudo` available.

---

## Part A — Muscle Memory

Do each of these against nginx (install it first, however you know to). No looking anything up if you can help it — if you blank on one, that's exactly the one to redrill.

1. Start it.
2. Stop it.
3. Restart it.
4. Reload it — be ready to say why that's not the same as restart.
5. Enable it without starting it. Confirm that's actually the state it's in.
6. Disable it without stopping it. Confirm that's actually the state it's in.
7. Enable it and start it, in a single command.
8. Pull its full status — read the whole block out loud: active state, main PID, recent log lines.
9. Get a single-word, scriptable answer for "is it running right now."
10. Get a single-word, scriptable answer for "will it survive a reboot."
11. List every failed unit on the entire box.
12. Make systemd re-read a unit file you've hand-edited.
13. Follow its logs live, then stop following.
14. Show only its error-level log lines.
15. Show its logs from the last hour only.

---

## Part B — Judgment Calls

Each has a safe-looking wrong answer. Decide, then act — don't default to habit.

1. **Scenario:** you need nginx running immediately for a one-off test, but it must not survive a reboot. Do exactly that — nothing more. Then flip it: you need it wired to survive a reboot, but it doesn't need to be running this second. Do that instead. State the rule in one sentence.

2. **Scenario:** you've changed nginx's config file and need it live with zero dropped connections. Do it the right way. Confirm the process's PID didn't change before and after. Then explain: is there ever a case where the command you just used wouldn't actually apply your change, even with no error shown?

3. **Scenario:** check nginx's current running state fully, then separately check whether it's wired to survive a reboot. If those two answers disagree, is anything broken right now? What happens on the next reboot?

4. **Scenario:**
   ```bash
   sudo sed -i 's/Description=.*/Description=Test Change/' /etc/systemd/system/*.service 2>/dev/null || echo "create a placeholder service first if none exists"
   ```
   You've hand-edited a unit file. Apply the change the way you'd normally push a config update, and check whether it actually took effect. If it didn't, figure out what step you skipped, fix it, and confirm.

5. **Scenario setup** — two placeholder services, one depending on the other, wired with only a "requires" relationship and nothing about order:
   ```bash
   sudo tee /usr/local/bin/db.sh > /dev/null <<'EOF'
   #!/bin/bash
   python3 -m http.server 6543
   EOF
   sudo chmod +x /usr/local/bin/db.sh
   sudo tee /etc/systemd/system/db.service > /dev/null <<'EOF'
   [Service]
   ExecStart=/usr/local/bin/db.sh
   EOF

   sudo tee /usr/local/bin/api.sh > /dev/null <<'EOF'
   #!/bin/bash
   while true; do curl -s http://localhost:6543 > /dev/null; sleep 5; done
   EOF
   sudo chmod +x /usr/local/bin/api.sh
   sudo tee /etc/systemd/system/api.service > /dev/null <<'EOF'
   [Unit]
   Requires=db.service

   [Service]
   ExecStart=/usr/local/bin/api.sh
   EOF
   sudo systemctl daemon-reload
   ```
   Start both together, repeatedly, and try to catch a race. State out loud what the dependency directive already in the file actually guarantees — and what it doesn't. Fix it by adding whatever's missing, apply it correctly, confirm it stops racing.

6. **Scenario:** you're writing a health-check script that needs a fast, machine-readable up/down answer — not a wall of text a human reads. Decide which command belongs in that script, and explain why the human-readable one would break automation if you used it instead.

---

## Part C — Troubleshooting Flow

The fixed process, every time, in this order:
1. Is it currently active, failed, or inactive — and what's the last relevant line shown inline?
2. Pull logs scoped to that specific service to find the actual error and when it started.
3. Diagnose before touching anything — config problem, resource problem, dependency problem, or permissions problem?
4. Fix the specific thing you diagnosed.
5. Apply the fix the right way for what it needed, then check the service again to confirm it's genuinely healthy — not just "not currently showing red."

Walk all five steps out loud every time below, even when an earlier step already caught it.

1. **Config syntax error:**
   ```bash
   sudo tee /usr/local/bin/broken1.sh > /dev/null <<'EOF'
   #!/bin/bash
   if [ true
   echo "unreachable"
   EOF
   sudo chmod +x /usr/local/bin/broken1.sh
   sudo tee /etc/systemd/system/broken1.service > /dev/null <<'EOF'
   [Service]
   ExecStart=/usr/local/bin/broken1.sh
   EOF
   sudo systemctl daemon-reload
   ```
   Try to start it. Walk the five steps.

2. **Bad path:**
   ```bash
   sudo tee /etc/systemd/system/broken2.service > /dev/null <<'EOF'
   [Service]
   ExecStart=/usr/local/bin/does-not-exist.sh
   EOF
   sudo systemctl daemon-reload
   ```
   Try to start it. Walk the five steps.

3. **Crash loop:**
   ```bash
   sudo tee /usr/local/bin/broken3.sh > /dev/null <<'EOF'
   #!/bin/bash
   echo "starting"
   exit 1
   EOF
   sudo chmod +x /usr/local/bin/broken3.sh
   sudo tee /etc/systemd/system/broken3.service > /dev/null <<'EOF'
   [Service]
   ExecStart=/usr/local/bin/broken3.sh
   Restart=on-failure
   RestartSec=2
   EOF
   sudo systemctl daemon-reload
   sudo systemctl start broken3
   ```
   Watch it loop. Walk the five steps. Decide: is the restart policy hiding a real bug, or doing its job?

4. **Wrong port (the "status lied to me" trap):**
   ```bash
   sudo tee /usr/local/bin/broken4.sh > /dev/null <<'EOF'
   #!/bin/bash
   python3 -m http.server 9099
   EOF
   sudo chmod +x /usr/local/bin/broken4.sh
   sudo tee /etc/systemd/system/broken4.service > /dev/null <<'EOF'
   [Service]
   ExecStart=/usr/local/bin/broken4.sh
   EOF
   sudo systemctl daemon-reload
   sudo systemctl enable --now broken4
   ```
   A health check expects port 8081. Confirm `status` shows healthy while the real check fails. Walk why step 1 alone would have missed this entirely.

5. **Missing dependency:**
```bash
sudo tee /usr/local/bin/db.sh > /dev/null <<'EOF'
#!/bin/bash
python3 -m http.server 6543
EOF
sudo chmod +x /usr/local/bin/db.sh
sudo tee /etc/systemd/system/db.service > /dev/null <<'EOF'
[Service]
ExecStart=/usr/local/bin/db.sh
EOF

sudo tee /usr/local/bin/api.sh > /dev/null <<'EOF'
#!/bin/bash
while true; do curl -s http://localhost:6543 > /dev/null; sleep 5; done
EOF
sudo chmod +x /usr/local/bin/api.sh
sudo tee /etc/systemd/system/api.service > /dev/null <<'EOF'
[Unit]
Requires=db.service

[Service]
ExecStart=/usr/local/bin/api.sh
EOF
sudo systemctl daemon-reload
```

---

## Part D — Explain It Cold

Out loud, one sentence, no hedging:

1. Actual difference between starting and enabling a service?
2. Actual difference between restart and reload?
3. "Enabled" and "active" are two separate things — what does each one actually tell you?
4. Why do you have to make systemd re-read a unit file after hand-editing it?
5. What does an ordering directive guarantee that a bare dependency directive doesn't, and vice versa?
6. What's the fixed troubleshooting order, and why does diagnosis have to come before the fix?

---

## Part E — Building Your Own Service

For every item: name the **directive** and the **section** it belongs in (`[Unit]`, `[Service]`, or `[Install]`). Nothing else — no terminal, no file writing, just the translation.

Do one set, check your answers against yourself out loud, then move to the next set. Don't look ahead.

---

## Set 1

1. Runs as a dedicated non-root user.
2. Restarts automatically if it crashes.
3. Does not fight you when you deliberately stop it.
4. Comes up automatically after a reboot (needs a directive *and* a separate command).
5. Waits for basic networking before it tries to do anything.
6. The exact command systemd should run to launch it.
7. A human-readable name shown when someone checks its status.

---

## Set 2

1. Should always come back after any exit — including a deliberate stop — no matter the reason.
2. Runs the program located at `/opt/billing/run.sh`.
3. Must run as the user `billinguser`, not root.
4. Should wait 10 seconds before attempting a restart after a crash.
5. Must not start before another specific service, `db.service`, has been pulled in.
6. Must not start before that same service is actually running first, not just included.
7. Should be identifiable in `status` as "Billing Processor."

---

## Set 3

1. A log-shipping service that must never run as root under any circumstances.
2. Should restart if it crashes, but leave it alone if someone runs `systemctl stop` on it deliberately.
3. Needs to be wired into the normal boot sequence so it survives every future reboot.
4. Depends on a caching service called `cache.service` — needs both the inclusion guarantee and the ordering guarantee, not just one.
5. Should launch by running `/usr/local/bin/log-shipper.sh`.
6. Should wait 5 seconds between crash and restart attempt.
7. Should not attempt to start until basic networking is available.

---

## Set 4 — mixed, no repeats of the same requirement twice

1. Runs as `deploybot`.
2. Restarts no matter what, even on a manual stop.
3. Depends on `queue.service` — both included and guaranteed to start first.
4. Description should read "Deploy Automation Worker."
5. Launch command is `/opt/deploy/agent`.
6. Wait 3 seconds before any restart attempt.
7. Wired to start automatically on every future boot — name both the directive and the command needed afterward.

---

Once you've done all 4 sets cold, pick any one item from Set 3 or Set 4, and actually write out the full unit file for it from scratch — all three sections, correctly assembled — using only your own answers, no looking back at earlier sets.

**Explain it cold:**
1. What does the boot-target directive actually wire your service into?
2. Why does the user field matter even though the file itself has to be created by root?
3. One sentence: what's the actual difference between a "service" and a "process," conceptually?

---

## Capstone — Cold Build

No notes. Narrate every judgment call and run the full troubleshooting flow any time something doesn't work first try.

1. Write a unit file for a placeholder service, non-root user, restarts on crash but not on manual stop.
2. Apply it, get it running now and wired for the next reboot, confirm both independently.
3. Break it yourself with a bad path. Full five-step flow before fixing.
4. Break it a second way — make it crash-loop. Full flow again, confirm the fix by watching it come back up clean, live.
5. Add a second placeholder service it depends on, without declaring the dependency at all. Watch it race, fix it properly.
6. Shut everything down. Confirm nothing from this capstone is still loaded or lingering.

If you had to stop and think about which directive or which command at any point — that's what to redrill, not what to move past.