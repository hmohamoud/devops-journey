# Lab 13 — Service Management (systemd)

**Environment:** Ubuntu 26.04 LTS (devops-lab VM, aarch64) | SSH from macOS host (Apple Silicon)

---

## Problem

Service failures don't reduce to one fixed checklist the way file permissions do — a dead service could be a syntax error, a bad path, a crash loop, a service that's technically "up" but lying about it, or a dependency that only sometimes races on boot. This lab was built to force those five failure shapes to actually look different from each other in the journal, instead of all just reading as "it's broken, restart it" — plus a separate track for writing unit files correctly from a set of requirements, since that's a design skill, not a diagnostic one.

---

## What I Built

```text
/usr/local/bin/
├── broken1.sh / broken2.sh (repointed) / broken3.sh / broken4.sh
├── myapp.sh
├── log-shipper.sh
/opt/
├── billing/run.sh
├── deploy/agent          (built as a directory — see gap below)
/etc/systemd/system/
├── broken1–4.service
├── db.service / api.service
├── myapp.service / run.service / log-shipper.service / deploybot.service
```

Five deliberately broken services (Part C), five services built from written requirements (Part E, Sets 1–4).

---

## How I Solved It

**Config syntax error:** built a script with a real bash syntax error, confirmed it registers as `inactive` before ever being started (creating a unit file doesn't run anything), started it, read the exact file/line reference straight out of `journalctl`, fixed it. First fix attempt was incomplete on purpose — removed the syntax error but forgot the script needed a loop, and correctly told apart "inactive because it finished" from "inactive because it never started" from "failed because it crashed." Second fix added the loop and verified with the actual process tree in `status`, not just the word `active`.

**Bad path:** pointed `ExecStart` at a script that didn't exist, got systemd's specific `203/EXEC` failure code, and fixed it by repointing to a script that did exist rather than creating the missing one — same lesson, different valid path to it.

**Crash loop:** built a script that always exits `1` under `Restart=on-failure`, and this one had an extra real-world wrinkle nobody planned for — it had been crash-looping across a previous disconnected session long enough to trip systemd's built-in start-limit ("Start request repeated too quickly"). Confirmed the actual restart pattern in the logs before touching anything, correctly judged that the restart policy wasn't hiding a bug — it was doing exactly what it was supposed to against a script that was genuinely broken every time — then fixed the script to exit clean and confirmed via `Deactivated successfully` instead of the earlier `Failed with result 'exit-code'`.

**Wrong port trap:** built a service listening on a different port than a health check would expect, confirmed `status` reports healthy anyway, and started editing the script to fix the mismatch — this one's real fix and its verification aren't fully confirmed in the session (see gaps below).

**Missing dependency:** built two services with `Requires=` but no `After=`, and started them together repeatedly trying to catch the race. They came up clean every time this session — which is itself a fair result (`Requires=` without `After=` doesn't *guarantee* a race, it just doesn't prevent one), but the dependency directive was never actually corrected, so this one isn't resolved yet.

**Building services from requirements (Part E):** four different services built from four different requirement sets — a plain app, a renamed "Billing Processor," a service with an (aspirational, correctly-diagnosed-as-missing) `cache.service` dependency, and a deploy agent. Genuine mistakes surfaced and mostly got caught in real time: forgetting `sudo` for `/opt`, creating and then correctly deleting a wrongly-named user before recreating it properly, and — the best catch of the session — creating a unit file without the `.service` extension, having `systemctl` refuse it by exact filename, and diagnosing that by listing the directory instead of guessing.

---

## Break/Fix Summary

| Issue | Cause | Fix |
|---|---|---|
| `broken1` showed `inactive` right after creation | unit files only register instructions — nothing runs until `start` | expected behavior, not a bug; ran `start` |
| `broken1` failed with exit code 2 | genuine bash syntax error (`if [ true` never closed) | read the line number straight from `journalctl`, rewrote the script |
| `broken1` went `inactive` again after the first fix | syntax was valid, but the script had no loop — it ran once and exited clean | added the loop, verified with the process tree in `status` |
| `broken2` failed with `203/EXEC` | `ExecStart` pointed at a script that didn't exist | repointed to a script that did |
| `broken3` refused to start at all, `restart counter is at 3365` | systemd's start-limit rate-limiter tripped from an earlier, unrelated crash-loop session | script eventually fixed to exit clean; `systemctl reset-failed` wasn't used and probably should have been |
| `mkdir /opt/billing` denied | `/opt` isn't writable without root | re-ran with `sudo` |
| wrong dedicated user (`runapp`) created for the billing service | typo/first-pass naming mistake | deleted with `userdel`, confirmed gone, recreated correctly as `billinguser` |
| `log-shipper` unit refused to start, `Unit log-shipper.service not found` | unit file was created without the `.service` extension | listed `/etc/systemd/system` directly instead of guessing, found the real filename, removed the wrong file, recreated it correctly |
| `log-shipper` then failed with `Unit cache.service not found` | `Requires=cache.service` referenced a placeholder that was never actually built | expected — Set 3 only asked for the directive to be written correctly, not for `cache.service` to exist; re-edited and moved on |

---

## Key Snippets

```bash
# creating a unit file does NOT start anything — confirm before assuming something's broken
sudo systemctl daemon-reload
systemctl status <service>     # will show inactive until you actually run start

# the exact failure-code tell for a bad ExecStart path
# status=203/EXEC → systemd couldn't even launch the binary, different from a script's own exit code

# telling apart "finished clean" from "crashed"
# Deactivated successfully           → clean exit, script did its job and stopped
# Failed with result 'exit-code'     → the script itself returned non-zero

# confirm a fix with the process tree, not just the status word
systemctl status <service>
# look for the actual CGroup child processes, not just "active (running)"

# diagnose a "unit not found" error by looking at reality, not guessing
sudo ls /etc/systemd/system
```

---

## Improvements After Completion

- Learned that `inactive` isn't one state with one meaning — "never started," "finished cleanly," and "was fixed and re-ran clean" all show as `inactive`, and the only way to tell them apart is reading the actual log lines underneath, not the status word alone.
- Learned systemd's start-limit rate-limiter is a real thing that shows up unprompted once a crash loop runs long enough, and that it's a separate concept from `Restart=` itself — worth a dedicated redrill with `systemctl reset-failed`.
- Learned that a missing `.service` extension fails loud and specific (`Unit X.service not found`) rather than silently, and that the fastest way to diagnose a naming mistake is listing the actual directory instead of re-reading what you think you typed.
- Learned that `Requires=` without `After=` doesn't reliably *reproduce* a race in a small handful of manual attempts — it just doesn't prevent one. Not catching the race this session isn't proof the risk is fake, just that this test wasn't decisive.

**Open gaps, named directly, not smoothed over:**
- The missing-dependency scenario was never actually fixed — `After=` was never added to `api.service`.
- The wrong-port fix on `broken4` wasn't confirmed against a real check after editing the script.
- `run.service` (Billing Processor) was started but never enabled — it wouldn't survive a reboot as-is.
- `deploybot.service`'s launch target was built as a directory (`/opt/deploy/agent`) instead of an executable file, and the service was never started or verified at all.
- Part A (nginx muscle memory), Part B (judgment calls 1–4 and 6), Part D (Explain It Cold), and the Capstone weren't attempted this session.

---

## Key Takeaway

The five Part C scenarios did what they were built to do — five different failure shapes that each look genuinely different once you actually read the journal instead of pattern-matching to "it's red, restart it": a syntax error names its own line number, a bad path throws a specific exec-level code, a crash loop shows an accelerating restart counter, a wrong port hides completely behind a green status, and a missing dependency doesn't even guarantee it'll show itself on a given attempt.

The real value of this session wasn't a clean run — it was catching real mistakes as they happened instead of after the fact: a directory mistaken for an executable, a missing file extension, a user created under the wrong name and properly cleaned up rather than left behind. That's a more honest signal of progress than a session with no mistakes in it would have been.

What's actually left before calling Lab 13 done: fix the two Part C items still open (the wrong-port verification and the missing dependency), enable `run.service`, rebuild `deploybot` as a real file instead of a directory and actually run it, and then close out Part A, Part B, Part D, and the Capstone — none of which were touched this session.