# Challenge — Process Management & System Monitoring

---

## Incident 01

**Alert:** "Server feels sluggish and a bit unstable. CPU looks busy in places. Process count seems higher than usual, but nothing is obviously exploding. Not urgent, but it's been like this for a while."

```bash
stress-ng --cpu 2 --cpu-load 90 &

python3 -c "
import os, time
for i in range(6):
    p = os.fork()
    if p == 0:
        time.sleep(9999)
        os._exit(0)
while True:
    time.sleep(9999)
" &

python3 -c "
import os, time, subprocess
for i in range(4):
    p = subprocess.Popen(['sleep', '0.1'])
    time.sleep(0.3)
" &
```

- [ ] There are at least three distinct things happening here. Identify each one correctly before touching anything.
- [ ] Which one(s) actually need action, and which are just noise you should leave alone? Justify each call with evidence, not a guess.
- [ ] What's your kill order, and how do you verify each fix independently before declaring the whole incident resolved?

---

## Incident 02

**Alert:** "App is slow, and now uploads are starting to fail intermittently. Users are seeing timeouts. Nobody's sure yet if this is one problem or two."

```bash
stress-ng --vm 2 --vm-bytes 75% --timeout 90s &

mkdir -p /mnt/faketest
mount -t tmpfs -o size=200M tmpfs /mnt/faketest
dd if=/dev/zero of=/mnt/faketest/bloatfile bs=10M count=18 oflag=direct status=progress
```

- [ ] Is this one root cause or two separate ones? Prove it — don't assume from the alert's framing.
- [ ] Walk both relevant paths from your flow. What's the actual evidence for each?
- [ ] What do you fix, in what order, and how do you confirm both are actually resolved (not just one)?

---

## Incident 03

**Alert:** "A background job apparently can't be stopped — engineer says it's not responding to any kill attempts. Separately, a critical service is being starved by something we're not allowed to kill. There's also an old process someone left running that nobody's checked on in hours."

```bash
sleep infinity &
PID1=$!
kill -STOP $PID1

bash -c 'trap "echo cleaning up; sleep 2; echo done" TERM; while true; do sleep 1; done' &

stress-ng --cpu 2 --cpu-load 50 &

nohup bash -c 'while true; do echo exporting >> /tmp/export.log; sleep 2; done' &
disown
```

- [ ] Four distinct things are running. Identify each by state/behavior — don't just search by name.
- [ ] The "unstoppable" one — is it actually unkillable, or does it just need a different action first?
- [ ] The competing process you can't kill — what's your alternative, and how do you prove it worked?
- [ ] The old disconnected job — how do you find it, confirm it's healthy, and stop it cleanly if needed?

---

## Incident 04 — Capstone

**Alert:** "Everything at once. CPU is spiking somewhere, the system feels like it's grinding to a halt, process count is climbing and won't stop, and something is filling up disk. Multiple engineers are arguing about what's actually wrong. You have one shot at this — treat it like a live page."

```bash
stress-ng --cpu 2 --cpu-load 85 &

ulimit -u 200 && python3 -c "
import os, time
def fork_forever():
    while True:
        os.fork()
        time.sleep(0.1)
fork_forever()
" &

python3 -c "
import os, time, subprocess
while True:
    p = subprocess.Popen(['sleep', '0.1'])
    time.sleep(0.3)
" &

stress-ng --vm 1 --vm-bytes 60% --timeout 90s &

mkdir -p /mnt/faketest
mount -t tmpfs -o size=200M tmpfs /mnt/faketest
dd if=/dev/zero of=/mnt/faketest/bloatfile bs=10M count=18 oflag=direct status=progress
```

- [ ] How many independent problems are actually present? Name each one's category — by evidence from your flow, not by guessing from this alert.
- [ ] Which one is the most urgent, and why — what makes something jump the queue over another?
- [ ] What's your complete action sequence, start to finish, in the order you'd actually execute it live?
- [ ] After every individual fix, how do you confirm it worked without losing track of what's still outstanding?
- [ ] At the very end — full system check. Is everything actually clear, or did something get missed?

---

## Record format (use for every incident)

→ Command used at each step
→ What you saw
→ Decision you made
→ Action you took

**Check your reasoning against `notes.md` only after you've fully worked each incident — not before, and not mid-way.**