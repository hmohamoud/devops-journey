# Lab 12 — User Management & Ownership

**Environment:** Ubuntu 26.04 LTS (devops-lab VM, aarch64) | Bash | SSH from macOS host (Apple Silicon)

---

## Problem

User and permission management is the kind of thing that looks simple until the wrong flag silently breaks something — `-G` instead of `-aG` wipes a user's other groups with no warning, `chown` and `chmod` look interchangeable but are gated by completely different rules, and "permission denied" can mean three different things depending on whether the problem is the directory, the file, or which ownership column actually applies to you.

This lab was built to train four separate muscles instead of one blurred set of commands:

- **Muscle memory** — commands typed without hesitation
- **Judgment calls** — picking the right flag/command when two similar ones exist and the wrong one fails silently
- **Troubleshooting flow** — a fixed, three-step diagnostic process for "permission denied," run in order every time, not guessed at
- **Explain it cold** — one-sentence, no-hedging answers for an interview setting

Then a distinct fifth block for service accounts, since a service account is a different mental model from a normal human user account, not just a variant of the same commands.

---

## What I Built

```text
bash-lab/
├── data/
├── scripts/
└── output/
    ├── app2/
    └── service/
```

Users, groups, and files created and destroyed live on a disposable VM: `appuser`/`appuser2`, `ameen`, `justin`, `xl`, `hello123`, `xyz`/`deploy2` (service accounts), and the capstone's `opsuser` + `platform` group, plus supporting groups `dev-team`, `docker`, `hamza`, `ops2`, `platform`.

---

## How I Solved It

**Muscle memory (Part A):** Ran `useradd` with and without `-m` back to back and confirmed the difference directly against `ls /home/`. Set a password separately with `passwd` and confirmed `useradd` never does this automatically. Read `id` output out loud (UID/GID/groups), then worked through the full group lifecycle — `groupadd`, `usermod -aG`, `getent group`, `groupdel` — ending each drill by confirming state with `getent group <name>` returning nothing.

**Judgment calls (Part B):** Deliberately ran the "safe-looking" wrong command first, on a throwaway user, to see the failure before fixing it — most notably `usermod -G hamza ameen`, which silently dropped `ameen` from `dev-team`, confirmed via `id ameen` before restoring correct membership with `-aG`. Same pattern for `chmod` vs `chown`: ran `chown` as a plain user first and watched it fail with `Operation not permitted`, then re-ran with `sudo` to confirm the boundary is real, not just a style preference.

**Troubleshooting flow (Part C):** Built each broken scenario on purpose — a `600` directory hiding a normal file, a `root:root` `600` file behind an otherwise-open directory, a file whose owner/group don't match the current user at all — and walked the fixed three-step process (`ls -ld` on the parent → `ls -l` on the file → `id` compared against owner/group columns) out loud every time, even when an earlier step already caught the problem. Fixed each with the *correct* tool (`sudo chown` to fix ownership, not a wide-open `chmod` to paper over it).

**Service accounts (Part E):** Built a service account in one shot (`useradd -r -m -s /usr/sbin/nologin`) and confirmed both the login block (`su -` refused) and the UID convention (`< 1000`). Then deliberately tried the wrong pattern — assuming `usermod` has an equivalent `-r` flag for converting an existing user — confirmed it doesn't exist, and corrected the mental model: `usermod -s /usr/sbin/nologin` is the real (UID-preserving) conversion path, and the `nologin` shell — not the UID — is what actually blocks interactive access.

**Explain it cold (Part D) + Capstone:** Answered the one-sentence rapid-fire questions without reopening notes, then built the capstone (`opsuser` + `platform`, linked without wiping groups, ownership set and later corrected with the dedicated group-only command, access deliberately broken and diagnosed with the full three-step flow, `$EUID` guard block proven both blocked and passing) straight through, narrating every judgment call as it came up.

---

## Break/Fix Summary

| Issue | Cause | Fix |
|---|---|---|
| `id ameen` showed `dev-team` missing after a group change | used `usermod -G hamza ameen` — `-G` replaces the group list instead of appending | re-ran with `usermod -aG dev-team ameen` to restore it alongside `hamza` |
| `chown` failed as the file's plain owner | `chown` requires root/sudo regardless of ownership — unlike `chmod` | re-ran with `sudo chown` |
| `cat file` denied even though `ls -l` showed `-rw-r--r--` | parent directory had no `x` (`chmod 600` on the dir) | `ls -ld` on the parent caught it immediately; `chmod +x` on the directory fixed it |
| `ls -l` on a file inside a no-`x` directory printed all `?` fields | the shell couldn't even `stat` the file without traverse permission on the parent | same fix — directory `x` first, always, before touching the file |
| Root-owned file at `600` still inaccessible after `sudo` regained control | tempting fix was to loosen the mode (`chmod 666`) instead of reclaiming ownership | `sudo chown <user>` to correctly attribute the file, leaving the mode untouched |
| `groups` didn't show a newly added group right after `usermod -aG` | the current shell's group list is cached at login and doesn't auto-refresh | `newgrp <group>` to pick up the change in the current session |
| Assumed `usermod -r -s /usr/sbin/nologin` would convert an existing user to a service account | `-r` is a `useradd`-only flag — doesn't exist on `usermod` | corrected to `usermod -s /usr/sbin/nologin` (UID stays as-is; the shell alone blocks login) |
| `mkdir -p bash-lab/output/service` denied | `bash-lab` was owned by a different user:group pair from an earlier drill | `sudo mkdir`, then `sudo chown opsuser:platform` to correctly attribute the new directory |

---

## Key Snippets

```bash
# create + password + identity, the standard sequence
sudo useradd -m opsuser
sudo passwd opsuser
id opsuser

# add to a group WITHOUT wiping existing membership
sudo usermod -aG platform opsuser

# prove membership from both directions
id opsuser                    # user → groups
getent group platform         # group → users

# owner + group in one command, then group only
sudo chown opsuser:platform bash-lab/output/service
sudo chown :platform bash-lab/output/service

# the fixed troubleshooting order — every time, no skipping
ls -ld <parent_dir>            # 1. directory x?
ls -l <file>                   # 2. file mode allow it?
id <user>                      # 3. which column — owner/group/others — applies?

# service account, correct in one command
sudo useradd -r -m -s /usr/sbin/nologin svcuser

# converting an EXISTING user to non-interactive (no -r on usermod)
sudo usermod -s /usr/sbin/nologin appuser

# root-only guard block for scripts
if [ "$EUID" -ne 0 ]; then
    echo "Run as root" >&2
    exit 1
fi
```

---

## Improvements After Completion

- Learned that `-G` and `-aG` look almost identical but do opposite things to existing group membership — the only way this actually sticks is watching `-G` silently wipe a group on a throwaway user before trusting `-aG` by default.
- Learned `chmod` and `chown` are gated by genuinely different rules, not just "both need permissions" — `chmod` is something the owner controls on their own file, `chown` is a trust boundary only root can move, and that distinction held up under direct testing.
- Learned the three-step troubleshooting order matters more than any individual command: jumping straight to the file's permissions without checking the parent directory's `x` bit wastes time chasing the wrong fix.
- Learned a service account isn't a separate account type — it's a normal account plus a `nologin` shell, and that the UID range is convention, not enforcement. The one wrong assumption caught here (`usermod -r`) was worth catching before it became muscle memory.
- Learned `groups` is a point-in-time snapshot of the current shell, not a live view — `newgrp` or a fresh login is required to see a just-added group, which explains a whole category of "it says I'm not in the group but I just added myself" confusion.

---

## Key Takeaway

Before this lab, I could run the individual commands — `useradd`, `chown`, `usermod` — but treating them as interchangeable-enough tools meant the wrong flag or the wrong command could fail silently: a wiped group list, a "permission denied" chased in the wrong file, a UID that looked right but a shell that didn't actually block login.

After this lab, each command has a specific, tested boundary: `-G` vs `-aG`, `chmod` vs `chown`, directory-first vs file-first, `useradd -r` vs the nonexistent `usermod -r`. None of these were guessed at — each was proven by deliberately triggering the wrong behavior first, then fixing it, on a disposable account, before trusting the right one by default.

The three questions that mattered every single task in this lab:

1. Do these two similar-looking commands/flags actually do the same thing — or does one of them silently break something the other doesn't?
2. When something's denied, am I following the fixed diagnostic order, or guessing at which layer is the problem?
3. Could I explain *why* the rule is drawn where it is — not just *that* it exists — without looking it up?