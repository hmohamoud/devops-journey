# Lab 12 — User Management & Ownership (Focused)

## Objective

This lab covers exactly what you've already taken notes on — nothing more. It's built to train four distinct skills separately, because they're different muscles:

- **Muscle memory** — commands you should be able to type without thinking
- **Judgment calls** — situations where two similar commands/flags exist and picking the wrong one silently breaks something
- **Troubleshooting flow** — a fixed diagnostic process you run every time you hit "permission denied," not guesswork
- **Explain it cold** — the one-sentence answers you give in an interview without hesitating

Same topics as before, restructured so each part actually drills the skill it's testing.

---

## Environment Setup

Disposable VM or container. This lab creates/deletes real users, groups, and permissions.

```text
bash-lab/
├── data/
├── scripts/
└── output/
```

---

## Part A — Muscle Memory (type it, don't think about it)

Run each back to back. No pausing.

1. `sudo useradd appuser` — user account only, no home directory.
2. `sudo useradd -m appuser2` — user account **and** home directory. Confirm the difference: `ls /home/`.
3. `sudo passwd appuser2` — set a password. Note that `useradd` never sets one automatically — this is a separate, required step.
4. `id appuser2` — read it out loud: UID, GID, and the groups list.
5. `whoami` — confirm which account you're currently logged in as.
6. `sudo groupadd dev-team` — create a group.
7. `sudo usermod -aG dev-team appuser2` — add to a group, correct flag.
8. `getent group dev-team` — list every member of that group.
9. `cat /etc/passwd | grep appuser2` — no `sudo` needed, world-readable. Confirm the `x` sitting in the password field.
10. `sudo cat /etc/shadow | grep appuser2` — `sudo` required this time. Confirm the real hash sitting in that same field position.
11. `sudo chown appuser2 file` / `sudo chown :dev-team file` / `sudo chown appuser2:dev-team file` — all three forms, on a real file.
12. `sudo -l` — list what you can run as root.
13. `sudo -i` then `whoami` then `exit` — root shell, confirm identity, leave it.
14. `sudo userdel appuser` (no `-r`) — deletes the account, home dir stays. Confirm the home directory is still there.
15. `sudo userdel -r appuser2` — deletes the account **and** home dir. Confirm both are gone.
16. `sudo groupdel dev-team` — delete the group. Confirm with `getent group dev-team` (should return nothing).

---

## Part B — Judgment Calls (pick correctly, don't default to habit)

Each of these has a "safe-looking" wrong answer. Get it right on purpose.

1. You need to check the contents of a world-readable config file. Do you `sudo` it? State the rule you're using before you run anything: *if you're only looking, and it's not protected, no sudo.*
2. You need to check the contents of `/etc/shadow`. Same question — and why is the answer different this time?
3. `appuser` is already in the `docker` group. You need to also add it to `dev-team` without losing `docker`. Which flag — `-G` or `-aG`? Run the wrong one first on a throwaway user, confirm `docker` disappears from `groups`, then fix it and confirm both show up.
4. You need to change a file's permission bits (`rwx`). Who can run that command — only root, or the file's owner too? Now do the same question for changing the file's *owner*. Different answer — know both, and know why they're different (permissions are something you can grant on your own stuff; identity/ownership is a trust boundary only root can move).
5. You want to see every user inside `dev-team`. Do you run `id` or `getent group`? Now flip it: you want to see every group a specific user belongs to. Which one now? State the direction each command reads in one sentence.
6. You need to run one single command as `deploy` and immediately return to yourself. Do you use `su - deploy` or `sudo -u deploy command`? Now: you need to actually work as `deploy` for the next twenty minutes. Which one now?

---

## Part C — Troubleshooting Flow (fixed process, every time)

Don't guess. Run the process in this exact order and say each step out loud as you do it.

**The process:**
1. `ls -ld` on the parent directory — is `x` present? If not, stop here, that's the fix.
2. `ls -l` on the file itself — does the permission mode allow what you're trying to do?
3. `id <user>` compared against the file's owner/group columns — which column (owner/group/others) actually applies to you? First match wins, nothing after it matters.

**Drill it:**
1. Build: a directory `chmod 600`'d (no `x`), with a normal `644` file inside. Try to `cat` the file. Walk all three steps out loud even though step 1 already caught it. Fix it, confirm access.
2. Build: a directory with proper `x`, but a file inside owned by `root:root` at `600`. You are not root. Walk all three steps — this time step 1 passes clean, step 2 catches it. Fix it with `sudo chown`, not by loosening the mode to something wide open.
3. Build: a file owned by `appuser2:dev-team` at `640`. You are not `appuser2` and not in `dev-team`. Walk all three steps — confirm you land on the "others" column and explain why the owner/group columns don't apply to you at all, even though they're more permissive.
4. Build: same file as #3, but now add yourself to `dev-team`. Before doing anything else, predict whether `groups` will show `dev-team` in your *current* shell. Run it, confirm your prediction, and state the actual fix if you were wrong.

---

## Part E — Service Accounts (a distinct topic, don't skip it)

This is its own block because it's a different mental model than a normal human user account.

**Muscle memory:**
1. `sudo useradd -r -m -s /usr/sbin/nologin svcuser` — creates a service account in one command: `-r` = system/service account, `-m` = still give it a home dir, `-s /usr/sbin/nologin` = the actual lock that blocks interactive login.
2. `su - svcuser` — confirm it's refused.
3. `id svcuser` — read the UID out loud, confirm it's under `1000`.
4. Create a second, normal user (`useradd -m normaluser`, no `-r`, no `nologin`). `id normaluser` — confirm its UID is `1000` or above.

**Judgment call:**
5. You have an *existing* user with a normal `/bin/bash` shell, and you need to lock it down to non-interactive. What command? (Hint: it's not the same command as step 1, and it does **not** take `-r` — that flag doesn't exist on this command. Only the shell changes; the UID stays whatever it already was.)

**Explain it cold:**
6. What does the `-r` flag on `useradd` actually do, and why doesn't the equivalent exist on `usermod`?
7. What determines whether an account can log in interactively — its UID number, or its shell field? (Only one of these actually enforces anything.)
8. In one sentence: what is a service account, conceptually — not the commands, the idea?

---

## Part D — Explain It Cold (say it, don't look it up)

Answer each out loud, one sentence, no hedging:

1. Why does `/etc/passwd` show `x` in the password field instead of an actual hash?
2. What's the actual difference between what `id user` shows you and what `getent group groupname` shows you?
3. Why do you need `x` — not `r`, not `w` — on a directory just to read a file that's sitting inside it?
4. Ownership hierarchy: state the three columns in order and the rule for which one applies to you.
5. `chmod` vs `chown` — who's allowed to run each, and why is that boundary drawn where it is?
6. `sudo command` vs `sudo -i` — what's the actual difference in what happens after the command finishes?
7. What does `$EUID -ne 0` check, and why is it more reliable than checking `whoami` for "am I root"? (only the root can run this script)

---

## Capstone — Cold Build

No notes. Build this straight through, narrating your judgment calls (Part B) and running the troubleshooting flow (Part C) any time something doesn't work on the first try.

1. Create a user `opsuser` with a home directory, set its password, confirm its identity with `id`.
2. Create a group `platform`, add `opsuser` to it without touching any other groups it might already have.
3. Confirm `opsuser` is in `platform` two different ways — once from the group's side, once from the user's side.
4. Create `bash-lab/output/service/`. Set its owner to `opsuser` and its group to `platform` in one command.
5. Change your mind — you only want to fix the group, not touch the owner. Do that with the dedicated command for it.
6. Deny yourself access on purpose: strip the directory's execute bit. Try to read a file inside it. Run the full three-step troubleshooting flow before fixing it.
7. Write the `$EUID -ne 0` guard block from memory at the top of a throwaway script. Prove it blocks you as yourself and passes under `sudo`.
8. Now build the actual service account for whatever "process" would use this directory: one command, correct flags, non-interactive from the start. Confirm it can't log in.
9. Clean up: delete both users (with home directories removed) and the group.

If you had to stop and think about which flag or which command at any point — that's the part to redrill, not the part to move past.