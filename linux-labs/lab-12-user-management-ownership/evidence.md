# Evidence — Lab 12 Challenge (Mastery Check)

No notes open for the judgment-call predictions. Predictions stated before running, then verified against actual terminal output from the session transcript.

---

## Round 1 — Fast Execution

### 1–3. User + group creation, membership proven both directions

```bash
sudo useradd -m opsuser
sudo passwd opsuser
# New password: / Retype new password: → passwd: password updated successfully

sudo groupadd platform
sudo usermod -aG platform opsuser

id opsuser
# uid=1007(opsuser) gid=1007(opsuser) groups=1007(opsuser),1014(platform)

getent group platform
# platform:x:1014:opsuser
```
Membership confirmed from both directions: `id opsuser` (user → groups) and `getent group platform` (group → users).

### 4. Set owner+group in one command, then change only the group

```bash
sudo chown appuser2:dev-team footballiq.txt
ls -l footballiq.txt
# -rw-rw-r-- 1 appuser2 dev-team 6 Aug 12 14:48 footballiq.txt

sudo chown :dev-team bash-lab/output/service
ls -ld bash-lab/output/service
# drwxr-xr-x 2 opsuser dev-team 4096 Aug 12 15:18 bash-lab/output/service
```
First command sets owner and group together; the second changes only the group (owner `opsuser` untouched).

### 5. `sudo -l`, `sudo -i`, confirm identity, leave

```bash
sudo -l
# User hamzamohamoud825 may run the following commands on devops-lab:
#     (ALL : ALL) ALL

sudo -i
root@devops-lab:~# whoami
# root
root@devops-lab:~# exit
# logout
```

### 6. `userdel` with and without `-r`, proven on disk

```bash
sudo useradd ameen            # no -m, no home dir created
sudo userdel -r ameen
# userdel: ameen mail spool (/var/mail/ameen) not found
# userdel: ameen home directory (/home/ameen) not found   ← confirms none existed

sudo useradd -m appuser2      # -m, home dir created
sudo userdel -r appuser2
# userdel: appuser2 mail spool (/var/mail/appuser2) not found

/home/appuser2
# -bash: /home/appuser2: No such file or directory   ← confirms home dir removed
```

---

## Round 2 — Judgment Under Pressure

### 1. World-readable config file — no `sudo`

```bash
cat /etc/passwd | grep ameen
# ameen:x:1001:1001::/home/ameen:/bin/sh
```
No `sudo` needed — the file is world-readable and this is a read-only look.

### 2. `/etc/shadow` — `sudo` required

```bash
sudo cat /etc/shadow | grep ameen
# ameen:$y$j9T$euuSRCYxsaB1rqg3VhDAz/$KGYkic4J0WXg...:20675:0:99999:7:::
```
Different answer because the file is protected — it holds the actual password hash, not a placeholder.

### 3. `-G` vs `-aG` — predicted before running, then proven

**Prediction:** `-G` will wipe `dev-team` from `ameen`'s membership; `-aG` will restore it and keep `hamza` too.

```bash
sudo usermod -G hamza ameen
id ameen
# uid=1001(ameen) gid=1002(ameen) groups=1002(ameen),1003(hamza)   ← dev-team is gone

sudo usermod -aG dev-team ameen
id ameen
# uid=1001(ameen) gid=1002(ameen) groups=1002(ameen),1001(dev-team),1003(hamza)   ← both present
```
Prediction confirmed exactly.

### 4. `chown` vs `chmod` — who can run each

```bash
chmod +x test_dir/file1.txt
ls -l test_dir/file1.txt
# -rwxrwxr-x 1 hamzamohamoud825 hamzamohamoud825 ...   ← ran as the owner, no sudo, succeeded

chown justin:dev-team test_dir/file1.txt
# chown: changing ownership of 'test_dir/file1.txt': Operation not permitted (os error 1)

sudo chown justin:dev-team test_dir/file1.txt
ls -l test_dir/file1.txt
# -rw-rw-r-- 1 justin dev-team ...   ← required sudo
```
`chmod` succeeded as the plain file owner; `chown` failed until `sudo` was used. Confirms permission bits are something the owner controls, while ownership/identity is a trust boundary only root can move.

### 5. `getent group` vs `id user` — direction

```bash
getent group dev-team
# dev-team:x:1009:hamzamohamoud825   ← group → its members

id hamzamohamoud825
# uid=1000(hamzamohamoud825) ... groups=...,1009(dev-team)   ← user → its groups
```

### 6. Run once as another user vs. work as that user

```bash
sudo whoami
# root   ← one command as root, immediately back to the normal user
```
The single-command form is `sudo -u user command` (or `sudo whoami` for root itself) — no lingering session. To actually operate as that user for a stretch, `su - user` is the correct call instead (drilled in Round 1, item 5, via `sudo -i` for root).

---

## Round 3 — Diagnose the Symptom

### 1. `cat` denied despite `-rw-r--r--` on the file

```bash
mkdir -p troubleshoot && touch troubleshoot/trouble1.txt
chmod 700 troubleshoot && chmod 644 troubleshoot/trouble1.txt
chmod 600 troubleshoot

cat troubleshoot/trouble1.txt
# cat: troubleshoot/trouble1.txt: Permission denied

ls -l troubleshoot
# -????????? ? ? ? ?            ? trouble1.txt   ← can't even stat the file

ls -ld troubleshoot
# drw------- 2 hamzamohamoud825 hamzamohamoud825 4096 ...   ← no x on the parent directory
```
**Diagnosis:** the file's own mode is irrelevant — the parent directory has no `x`, so nothing inside is reachable. Look at the directory first, always.

```bash
chmod +x troubleshoot
ls -l troubleshoot
# -rw-r--r-- 1 hamzamohamoud825 hamzamohamoud825 0 ... trouble1.txt   ← now visible/readable
```

### 2. `cd`/`ls` work, `cat` fails — directory is fine, check the file next

```bash
ls -ld football
# drwxrwxr-x 2 hamzamohamoud825 hamzamohamoud825 4096 ...   ← directory access is fine

sudo chown root:root football/touch3.txt
sudo chmod 600 football/touch3.txt
ls -l football/touch3.txt
# -rw------- 1 root root 0 ... touch3.txt
```
**Diagnosis:** step 1 (directory) passes clean; step 2 (file mode) is what's actually blocking access — comparing `id hamzamohamoud825` against the file's `root:root` ownership shows neither owner nor group applies, so the "others" column (`---`) governs.

### 3. `root:root` file at `600`, you have sudo — correct fix vs. the tempting wrong one

```bash
sudo chown hamzamohamoud825:users football/touch3.txt
ls -l football/touch3.txt
# -rw------- 1 hamzamohamoud825 users 0 ... touch3.txt
```
**Correct fix:** `sudo chown` to reclaim ownership, matching the file's mode to who's actually supposed to have it.
**Fix to avoid:** loosening the mode (`chmod 666`/`777`) instead of fixing ownership — it "works" but opens the file to everyone rather than just the person who should own it.

### 4. `usermod -aG` doesn't show up in `groups` right away

```bash
sudo usermod -aG dev-team hamzamohamoud825
groups
# hamzamohamoud825 adm cdrom sudo dip plugdev users lxd   ← dev-team missing

newgrp dev-team
groups
# dev-team adm cdrom sudo dip plugdev users lxd hamzamohamoud825
```
**Diagnosis:** nothing is actually broken. The current shell's group list was cached when it opened; `usermod` doesn't refresh it live. `newgrp dev-team` (or a fresh login shell) picks up the change.

### 5. Owner has the widest bits, but a non-owner still hits a different column

```bash
ls -l test_dir/file1.txt
# -rw-rw-r-- 1 justin dev-team 12 ... file1.txt

id hamzamohamoud825
# uid=1000(hamzamohamoud825) ... groups=...,1009(dev-team)
```
`hamzamohamoud825` is not the owner (`justin`) but is in the file's group (`dev-team`), so the **group** column (`rw-`) applies — not the owner column, even though the owner column happens to be more permissive. The match is positional (owner → group → others, first match wins), not "whichever column is most generous."

---

## Round 4 — Explain It Cold

1. **Why is `/etc/passwd`'s password field just `x`?** It's a placeholder — the real hash is stored in `/etc/shadow`, which only root can read.
2. **Why does a directory need `x` to read a file inside it?** `x` is what lets you traverse/enter the directory at all; without it, nothing inside — read, write, or otherwise — is reachable, regardless of the file's own permissions.
3. **Ownership hierarchy and which column applies:** owner → group → others, and whichever one you actually are is the one that applies — first match wins, the rest don't matter even if they're more permissive.
4. **Why can the owner run `chmod` but not `chown`?** Permissions are something you're allowed to grant on your own stuff; ownership/identity is a trust boundary that only root is allowed to move.
5. **`sudo command` vs `sudo -i`?** `sudo command` runs one thing as root and drops you straight back to your own shell; `sudo -i` opens a full root shell that you stay in until you `exit`.
6. **What does `$EUID -ne 0` verify, and why is it better than `whoami`?** It checks the *effective* UID directly — `0` means root — which can't be spoofed the way parsing `whoami`'s text output could be.

---

## Round 5 — Capstone, Cold

```bash
sudo useradd -m opsuser
sudo passwd opsuser
sudo groupadd platform
sudo usermod -aG platform opsuser

id opsuser
# uid=1007(opsuser) gid=1007(opsuser) groups=1007(opsuser),1014(platform)
getent group platform
# platform:x:1014:opsuser
```
Link proven from both directions — no group wipeout (`-aG` used throughout).

```bash
mkdir -p bash-lab/output/service
# mkdir: Permission denied   ← bash-lab was owned by a different user:group (deploy2:ops2) from an earlier drill

sudo mkdir -p bash-lab/output/service
sudo chown opsuser:platform bash-lab/output/service
ls -ld bash-lab/output/service
# drwxr-xr-x 2 opsuser platform 4096 Aug 12 15:18 bash-lab/output/service
```

**Deliberate break + three-step diagnosis:**

```bash
sudo chmod -x bash-lab
ls -ld bash-lab/output/service
# ls: cannot open file 'bash-lab/output/service': Permission denied

ls -ld bash-lab
# drw-rw-r-- 5 deploy2 ops2 4096 ...   ← step 1: no x on the parent — this is the whole problem, nothing past this matters

sudo chmod +x bash-lab
ls -ld bash-lab
# drwxrwxr-x 5 deploy2 ops2 4096 ...   ← fixed
```

**Root-check guard block, proven both ways:**

```bash
# throwaway.sh
if [ "$EUID" -ne 0 ]; then
    echo "Run as root"
    exit 1
fi
echo "Running as root"
```

```bash
./throwaway.sh
# Run as root          ← blocked as a normal user

sudo -i
root@devops-lab:~# ./throwaway.sh
# Running as root       ← passes as root
```

**Notes / gaps for follow-up (being honest about what wasn't fully closed in this session):**
- The dedicated "change only the group" step for `bash-lab/output/service` was run against `dev-team` (`sudo chown :dev-team bash-lab/output/service`) instead of `platform` — a real slip from an earlier drill bleeding into the capstone. Worth re-running cleanly against `platform` to lock in the correct habit.
- Item 5 of the capstone (confirming from `id`, not memory, which column a totally unrelated third user would land in against this directory) wasn't explicitly drilled against `bash-lab/output/service` in this session — flagged as a redrill target, not skipped on purpose.
- Full `opsuser` + home-directory teardown in one command wasn't run in this session; the `userdel -r` pattern itself was proven repeatedly elsewhere (Round 1, item 6) but not against `opsuser` specifically.

---

## Self-Check

```
[x] Round 1 — every command run back to back, correct flags on first attempt
[x] Round 2 — every judgment call stated as a prediction before running, then verified against real output (esp. -G vs -aG group wipeout)
[x] Round 3 — full three-step diagnostic order (directory → file → ownership) walked out loud every time, no skipping to the fix
[x] Round 4 — one sentence each, no notes reopened
[~] Capstone — built end to end; two gaps identified above and logged as redrill targets rather than glossed over
```

If a round needed a peek at `notes.md`, that's the part to redrill — not a pass. The capstone gaps above are exactly that: named, not hidden.