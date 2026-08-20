# Evidence — Lab 13 (Service Management)

Built directly from the real terminal session. Where something wasn't actually run in this session, that's flagged as a gap rather than filled in — same rule as Lab 12's evidence.md.

---

## Part C — Troubleshooting Flow

### 1. Config syntax error (`broken1.service`)

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

Created but not started yet:
```
systemctl status broken1
○ broken1.service
     Loaded: loaded (/etc/systemd/system/broken1.service; static)
     Active: inactive (dead)
```
Confirms the lesson that creating a unit file only registers it — nothing runs until `start` is actually called. `systemctl --failed` also came back with `0 loaded units listed` at this point, correctly showing nothing has failed yet because nothing has been attempted yet.

Started it, it failed:
```
systemctl status broken1
× broken1.service
     Active: failed (Result: exit-code) ...
    Process: 2095 ExecStart=/usr/local/bin/broken1.sh (code=exited, status=2)
```
```
journalctl:
broken1.sh: line 4: syntax error: unexpected end of file from `if' command on line 2
```
**Diagnosis:** config problem — real bash syntax error, correctly identified from the file/line reference in the journal.

**First fix attempt** — removed the syntax error but the script still had no loop, so it ran once, printed `unreachable`, and exited cleanly:
```
Active: inactive (dead)
...
broken1.sh[2178]: unreachable
broken1.service: Deactivated successfully.
```
This is a genuinely useful catch — `inactive` here doesn't mean broken, it means the script *finished*, which is a different reason than the earlier `failed` state. Correctly told apart.

**Second fix** — added a loop, restarted, and verified with the actual process tree instead of just the status word:
```
● broken1.service
     Active: active (running) ...
   Main PID: 2319 (broken1.sh)
     CGroup: /system.slice/broken1.service
             ├─2319 /bin/bash /usr/local/bin/broken1.sh
             └─2324 sleep 5
```

### 2. Bad `ExecStart` path (`broken2.service`)

```bash
sudo tee /etc/systemd/system/broken2.service > /dev/null <<'EOF'
[Service]
ExecStart=/usr/local/bin/does-not-exist.sh
EOF
sudo systemctl daemon-reload
sudo systemctl start broken2
```
```
× broken2.service
     Active: failed (Result: exit-code) ...
    Process: 2436 ExecStart=/usr/local/bin/does-not-exist.sh (code=exited, status=203/EXEC)
...
(does-not-exist.sh)[2436]: broken2.service: Unable to locate executable '/usr/local/bin/does-not-exist.sh': No such file or directory
```
**Diagnosis:** bad path — `status=203/EXEC` is systemd's specific code for "couldn't even launch the executable," a different failure shape than `broken1`'s syntax error.

**Fix:** rather than creating the missing script, re-pointed `ExecStart` at the already-working `broken1.sh`:
```bash
sudo tee /etc/systemd/system/broken2.service > /dev/null <<'EOF'
[Service]
ExecStart=/usr/local/bin/broken1.sh
EOF
sudo systemctl daemon-reload
sudo systemctl start broken2
```
```
● broken2.service
     Active: active (running) ...
```
Valid fix — the scenario only requires the path to resolve to something real, and this does.

### 3. Crash loop (`broken3.service`, `Restart=on-failure`)

```bash
sudo tee /usr/local/bin/broken3.sh > /dev/null <<'EOF'
#!/bin/bash
echo "starting"
exit 1
EOF
sudo tee /etc/systemd/system/broken3.service > /dev/null <<'EOF'
[Service]
ExecStart=/usr/local/bin/broken3.sh
Restart=on-failure
RestartSec=2
EOF
sudo systemctl daemon-reload
sudo systemctl start broken3
```
This one had an extra, unplanned layer: the service had been crash-looping since an earlier session, and systemd's start-limit rate-limiter had kicked in:
```
Job for broken3.service failed because the control process exited with error code.
...
broken3.service: Scheduled restart job immediately on client request, restart counter is at 3365.
broken3.service: Start request repeated too quickly.
```
`journalctl -u broken3.service` confirmed the actual crash-loop pattern — repeated `Main process exited, code=exited, status=1/FAILURE` → `Scheduled restart job, restart counter is at N` cycles, seconds apart. Correctly pulled `systemctl cat broken3.service` and `cat /usr/local/bin/broken3.sh` to confirm both the unit's restart policy and the script's actual `exit 1` before touching anything.

**Diagnosis, live:** the restart policy wasn't hiding a bug — it was correctly restarting a script that was genuinely broken every time, exactly as designed.

**Fix:** changed the script to `exit 0`. First couple of restarts still showed old cached log lines, but the clean state confirmed:
```
broken3.service: Deactivated successfully.
```
(clean exit, not `Failed with result 'exit-code'`) — correctly distinguished from the earlier failing state.

**Gap:** the start-limit hit (`Start request repeated too quickly`) is a real, separate concept — `systemctl reset-failed <service>` is the actual command for clearing that counter, and it doesn't look like it was used here; the eventual successful restart may have just been outside the rate-limit window rather than a deliberate reset. Worth a dedicated redrill.

### 4. Wrong port trap (`broken4.service`)

```bash
sudo tee /usr/local/bin/broken4.sh > /dev/null <<'EOF'
#!/bin/bash
python3 -m http.server 9099
EOF
sudo systemctl start broken4
```
```
● broken4.service
     Active: active (running) ...
     CGroup: ... python3 -m http.server 9099
```
Confirmed `status` shows healthy while listening on the wrong port (9099 instead of the scenario's expected 8081). The script was opened in `nano` immediately after confirming the mismatch, which is consistent with fixing the port — but the session doesn't show the corrected file content or a follow-up `curl`/port check to prove the fix.

**Gap:** the actual verification step (confirming the *real* check passes after the port fix, not just that `status` still says healthy) isn't visible in the transcript. This is the exact trap the scenario is built to test, so it's worth deliberately re-running with the verification step made explicit.

### 5. Missing dependency (`db.service` / `api.service`, `Requires=` only)

```bash
sudo tee /etc/systemd/system/db.service > /dev/null <<'EOF'
[Service]
ExecStart=/usr/local/bin/db.sh
EOF
sudo tee /etc/systemd/system/api.service > /dev/null <<'EOF'
[Unit]
Requires=db.service

[Service]
ExecStart=/usr/local/bin/api.sh
EOF
sudo systemctl daemon-reload
sudo systemctl start db api
```
Started and restarted both together several times (`start db api`, `stop db api`, `start db api` again), checking `status` on each — both consistently came up `active (running)` every time this session.

**Gap — this is the important one:** no `After=db.service` was ever added, and no race was actually caught or fixed in this session. The scenario asks specifically to catch the race and correct it; right now the evidence only shows repeated attempts that happened to succeed, not a confirmed fix. This is the single biggest item to redo before calling Lab 13 done — starting them together many more times, or deliberately slowing `db.service` down, until the race actually shows itself.

---

## Part E — Building Your Own Service

### Set 1 example — `myapp.service`

Script tested standalone before wiring to systemd — good practice, catches script bugs before systemd adds a layer on top:
```bash
sudo bash /usr/local/bin/myapp.sh
Running
Running
^C
```
Dedicated user created and confirmed in the system UID range:
```bash
sudo useradd -r -s /usr/sbin/nologin appuser
id appuser
uid=994(appuser) gid=982(appuser) groups=982(appuser)
```
Enabled and started in one command, confirmed both the boot-wiring and the running state in a single `status` call:
```bash
sudo systemctl enable --now myapp
Created symlink '/etc/systemd/system/multi-user.target.wants/myapp.service' → '/etc/systemd/system/myapp.service'.
```
```
● myapp.service - My app
     Loaded: loaded (...; enabled; preset: enabled)
     Active: active (running) ...
```
Clean — description, user, enable, and running state all verified in one pass.

### Set 2 example — `run.service` ("Billing Processor")

```bash
mkdir -p /opt/billing
mkdir: Permission denied
sudo mkdir -p /opt/billing
```
Real, useful mistake — confirms `/opt` needs root, not something to assume. Script tested manually first, same as `myapp`. First attempt created a user `runapp`, then deliberately deleted it (`userdel runapp`, confirmed gone with `id runapp`) and re-created the dedicated user correctly as `billinguser` instead — a genuine course-correction, not a leftover mistake.
```
● run.service - Billing Processor
     Loaded: loaded (...; disabled; preset: enabled)
     Active: active (running) ...
```
**Gap:** description and running state confirmed, but `disabled` here means the reboot-survival requirement from Set 2 wasn't wired — no `systemctl enable run` shown anywhere in the session for this one.

### Set 3 example — `log-shipper.service`

Real, instructive mistake: created the unit file without the `.service` extension twice in a row, and `systemctl start log-shipper` correctly refused with `Unit log-shipper.service not found`. Diagnosed it properly by listing the directory instead of guessing:
```bash
sudo ls /etc/systemd/system
```
Spotted `log-shipper.service` was missing from the listing (only a bare `log-shipper` file existed), removed the wrong one, recreated it with the correct filename. Good use of "look at the actual state of the system" instead of re-guessing.

Then hit a second, different error after adding the `cache.service` dependency from Set 3's requirements:
```
Failed to start log-shipper.service: Unit cache.service not found.
```
This is expected — Set 3 never asked for `cache.service` to actually exist as a placeholder, only to write the *directive* correctly. Re-edited the unit file and it started clean. Boot-wiring done as its own explicit step, exactly matching the "directive plus separate command" requirement:
```bash
sudo systemctl enable log-shipper
Created symlink '.../multi-user.target.wants/log-shipper.service' → ...
```
```
● log-shipper.service - Log shipper
     Loaded: loaded (...; enabled; preset: enabled)
     Active: active (running) ...
```
Full credit here — description, user, dependency directive, and boot-wiring all correctly separated and confirmed.

### Set 4 example — `deploybot.service`

```bash
sudo useradd -r -s /usr/sbin/nologin deploybot
sudo mkdir -p /opt/deploy/agent
sudo chmod +x /opt/deploy/agent
```
**Likely mistake worth flagging directly:** Set 4's requirement was a launch command at `/opt/deploy/agent` — a single executable *file*. What actually got created is a *directory* named `agent` (via `mkdir -p /opt/deploy/agent`), then `chmod +x` was applied to that directory. A directory being executable is a normal, different thing (it controls whether you can `cd` into it) — it doesn't make it a runnable program. `ExecStart=/opt/deploy/agent` pointed at a directory would fail the same way `broken2` failed pointing at a missing file.

**Gap:** the unit file was opened in `nano` three times in a row and the session ended there — no `daemon-reload`, no `start`, no `status` check. This one wasn't actually run or verified at all this session.

---

## What Wasn't Covered This Session

Being direct about this rather than letting it hide:

- **Part A (muscle memory against nginx)** — no evidence nginx was installed or exercised at all this session.
- **Part B (judgment calls)** — items 1–4 and 6 (start-vs-enable independence, reload-vs-restart PID check, enabled/active disagreement, daemon-reload-after-edit, the is-active health-check judgment) have no evidence of being run as their own exercises. Item 5 overlaps with the Part C dependency scenario above, and that one's still unresolved.
- **Part D (Explain It Cold)** — no evidence of the six rapid-fire answers being done this session.
- **Capstone** — not attempted this session.

None of this means it didn't happen — it means it isn't *in this transcript*, so it can't honestly go in evidence.md as done. Real progress this session: all five Part C troubleshooting scenarios attempted with the right diagnostic instincts (check state, check logs, read the actual error text, distinguish failure shapes), and four of the Part E design translations built and mostly verified, with specific, nameable gaps in each rather than vague ones.