# Notes — Lab 13: Service Management (systemd)

---

## 1. The Basic Analogy

📦 Service = the box/setup
🏷️ appuser = the label showing who runs it
🔧 myapp = the actual program inside the box

---

## 2. Basic Commands — start / stop / restart / reload / enable / disable

systemctl start nginx → ✅ Starts nginx now.
systemctl stop nginx → ✅ Stops nginx now.
systemctl restart nginx → ✅ Stops it and starts it again automatically
systemctl reload nginx → ✅ Tells nginx to reload its configuration without stopping the service (assuming nginx supports the reload). Good analogy: update the program settings while keeping the program running.
systemctl enable nginx → Permanently set nginx to start automatically when the computer turns on.
systemctl disable nginx → Remove the permanent setting that makes nginx start automatically when the computer turns on.
sudo systemctl enable --now nginx → Start nginx right now AND permanently set it to start automatically whenever the computer/server turns on.

---

## 3. systemctl status — Reading the Output

systemctl status nginx

loaded → systemd recognises the service.
enabled → permanently set to start when the computer turns on.
preset: enabled → the system's default setting is to have it enabled.
* **Main PID** → nginx's process ID.
* **Memory** → RAM nginx uses.
* **Logs** → what happened / errors.

---

## 4. is-active / is-enabled

systemctl is-active nginx
tells you if program is running/active or inactive

systemctl is-enabled nginx
tells you if program is enabled or disabled

---

## 5. --failed and list-units

`systemctl --failed`
shows you which services that failed

`systemctl list-units --type=service`
list all the services systemd currently knows about (loaded)

---

## 6. daemon-reload

`sudo systemctl daemon-reload`
You use daemon-reload after editing/creating a service file so systemd loads the new instructions into memory, replacing the old ones.
Rule: Edit/create a service file → daemon-reload → then start/restart the service.

**Why you need to do this:** if you don't, systemd only has the old version of the unit file — the one before your edit. `daemon-reload` tells systemd to read the new, hand-edited version.

---

## 7. journalctl

`journalctl -u nginx`
Shows the logs explaining what happened with nginx

journalctl -u nginx -f → Shows existing nginx logs first, then continues showing new logs in real time.

---

## 8. reload vs restart — When to Use Which

reload → preferred when the program supports it; picks up config changes without stopping.
restart → use when reload isn't supported or a full restart is required.

**The fuller decision tree:**

Did you change the unit file (.service file) itself?
If it only touched metadata (Description=) → daemon-reload alone.
If it touched anything that affects how the process runs (ExecStart=, User=, etc.) → daemon-reload and restart.
Did you change the application's own config file (like nginx.conf), not the unit file?
Does the daemon support reload? → reload.
Doesn't support it, or you're not sure? → restart.

**The short rule, no yap:**
Metadata (like `Description=`) → `daemon-reload` only.
Anything that changes how the process runs (`ExecStart=`, `User=`, `Restart=`, env vars, etc.) → `daemon-reload` + `restart`.

**In my own words — restart vs reload:** restarting basically creates a new PID for the process. It basically turns off and turns it on automatically, the computer or the server. Reload basically refreshes the config files while the program is running. It doesn't turn off or turn on, and we're still keeping the same PID.

**The full workflow, start to finish:**
- Create or edit the `.service` file
- `daemon-reload` — systemd now knows about the change
- Changed the app's own config (like `nginx.conf`), daemon supports it → `reload`. Anything else (unit file, or unsure) → `restart` — the running process actually picks it up

---

## 9. failed / active / inactive — What Each State Actually Means

failed = it tried and broke. Always investigate.
active = it's alive, but not proven to be correct. Verify with a real check.
inactive = only a non-issue if that's the state it's supposed to be in right now.

**A freshly created service starts inactive:** After creating any service, systemctl status will show inactive (dead) — that's expected, not broken. Creating a unit file only registers the instructions; it does not launch anything. You always have to run start yourself before there's anything to diagnose.

---

## 10. Diagnosing From the Error Message

Simple trick: the error message names the file, not a resource or another service.

If the error mentions a file path or a line number inside your script → config. Something you wrote is wrong. You need to rewrite /usr/local/bin/broken1.sh with valid bash. Go ahead and overwrite it.

If it mentions memory, disk space, or "too many open files" → resource.
If it mentions another service, a connection refused, or "waiting on" → dependency.
If it says "permission denied" or "operation not permitted" → permissions.

---

## 11. Scenario 1 Recap — Worked Example

Quick recap of what you actually walked through, since this one had more layers than expected:
Checked state → inactive, learned the "forgot to start it" lesson.
Started it → failed, exit-code, syntax error inline in the log.
Diagnosed → config problem, correctly.
First fix attempt → syntax valid, but no loop → inactive again, different reason this time (finished, not crashed).
Second fix → added the loop → active (running), verified with the actual process tree, not just the status word.

---

## 12. Requires= vs After= — Dependency and Order

Ordering (`After=`) makes sure the program or service runs after the other one — it focuses on sequence. Dependency (`Requires=`) makes sure the other program or service gets started at all, if you want this one to start — but it doesn't guarantee order, and it doesn't guarantee it actually succeeds.

`Requires=` isn't a promise of success, just a promise of inclusion — it could still fail.

Together → the dependency exists and it comes up first.

```ini
[Unit]
Requires=db.service
After=db.service
```

**Applying it:** unit file changed → `daemon-reload`, then `restart` the dependent service (this touches how it runs, not just metadata, so both are needed).

---

## 13. How to Spot a Missing Dependency

- Behavioral: startup failures that are *intermittent* — works sometimes, fails other times, same code.
- Structural: check the unit file — `Requires=` present, `After=` missing. That's the proof.

**The fix:**
```ini
[Unit]
Requires=db.service
After=db.service
```
`Requires=` = make sure it's included. `After=` = start it first. Need both.

---

## 14. Start vs Enable — In My Own Words

Start makes a service active, which makes the program active — it basically just runs it. Enabled means the program runs automatically every time the server or computer turns on.

---

## 15. Building Your Own Service — Script, User, Unit File

When creating a file:
Write the actual program/script to somewhere like /usr/local/bin/.
Make it executable with chmod +x.
Then point ExecStart= at that path in the unit file.
/usr/local/bin/myapp.sh = where the actual program lives, made executable with chmod +x.
ExecStart=/usr/local/bin/myapp.sh in the unit file = tells systemd exactly where to find it and run it.

Then, create the dedicated user, e.g. sudo useradd -r -s /usr/sbin/nologin appuser

Open the unit file (service) in nano:
sudo nano /etc/systemd/system/myapp.service

---

## 16. WantedBy=multi-user.target

`WantedBy=multi-user.target` = "if you want this to run automatically every time it boots, put this in the file." But the line by itself does nothing — you still have to actually run `enable` for it to take effect. The line just makes `enable` *possible*; `enable` is the thing that actually does it.

---

## 17. Restart=on-failure vs Restart=always

`Restart=on-failure` — only restarts on a crash, doesn't restart on a manual stop.
`Restart=always` — restarts no matter what, including a manual stop.