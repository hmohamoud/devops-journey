# Notes — Lab 12: User Management & Ownership

---

## 1. `sudo` — When to Use It

If the command is changing the system → sudo.
If the command is just looking at something → no sudo.

unless what you're looking at is protected then you would need sudo
whoami - tells you which account you logged in as!

---

## 2. Creating Users — `useradd` / `passwd`

> `sudo useradd appuser` → creates a **user account**.
>
> `sudo useradd -m appuser` → creates a **user account + creates a user directory for the user as well**.

sudo passwd appuser
gives the appuser account a password (or changes its password if it already has one). because it doesnt automatically give it a password when you create a user account

---

## 3. `id` — Checking User Identity

id appuser is used for troubleshooting permissions by checking which group(s) they belong to.
uid = user id
gid = group id
groups = which group the user belongs to (it can belong to multiple)

---

## 4. Group Management — `groupadd`, `usermod -G` vs `-aG`

 # Creates group
sudo groupadd dev-team

sudo usermod -G dev-team ameen
* **`-G`** → adds the user to the new group (dev-team) **and removes them from their old groups**. (if ameen was apart of any other groups that will be removed)
sudo usermod -G dev-team ameen
* **`-aG`** → adds the user to the new group **and keeps their old groups**.

---

## 5. `getent group` vs `id user` — Direction

getent group groupname → tells you all the users in a group
id appuser → tells you all the groups a user is in
So they're basically opposites in terms of direction:
getent group → group → users
id user → user → groups

---

## 6. `/etc/passwd` and `/etc/shadow`

sudo etc/passwd | grep appuser
/etc/passwd tells you who the user is, their UID/GID, where their home directory is (use this to check if it has a ), and which shell they use. x means the password hash is stored in /etc/shadow, not in /etc/passwd.
cat /etc/group | grep appuser shows you the members in the group, you could do id appuser but that tells you which group this id belongs too but if you want the vice versa where you are seeing all the members in a group

cat /etc/passwd | grep appuser
is great for checking the shell field if its interactive or non interactive

**1. `/etc/shadow` vs `/etc/passwd`**
I'd sudo it because this info is protected — it stores the hash of the user's password. If I'm looking for a specific user in that file, it'll show me the hash value. Not `x` — `/etc/passwd` shows `x`, that's just a placeholder. `/etc/shadow` shows the actual hash.

---

## 7. Deleting Users and Groups

sudo userdel ameen deletes a **user account**.
sudo useradd -m appuser deletes a **user account and deletes the user directory in the user as well**.

to delete a group it is
sudo groupdel groupname

---

## 8. Troubleshooting Flow — Permission Denied

> When a user can't access a file or perform a certain action, first run `ls -l file1.txt` to see **the file's owner, group, and permissions**. Then run `id user` to see **the user's identity and groups**, and compare them to the file's owner and group to determine whether the user is the **owner, part of the group, or others**. Finally, check the matching permissions to see **what the user is allowed to do**.

Compare yourself to the file's ownership labels.
It stops at first match — everything else is irrelevant:
give an example here:


whatever you are thats the permission that applies to you.
you are the owner → owner column applies  (rwx------)
you are in group  → group column applies  (---rwx---)
neither           → others column applies (------rwx)

Permission denied (Follow this all the time)
1. Check directory permission first — no x on the directory means nothing inside is reachable at all. File permissions are irrelevant until the directory lets you in.
2. File permission second — once you are inside, does the file permission set allow what you are trying to do?
3, Ownership third — which permission set actually applies to you? Owner, group, or others? Compare who you are or the group you belong to the columns for the ownership labels and the permission columns.

---

## 9. Directory Permissions

r = list files in the directory (ls)
x = enter and traverse the directory (cd)
w = create, delete, rename files in the directory (mkdir, rm, touch)

Without x, you cannot read, write, or do anything inside:

```bash
chmod 600 project/

cd project/                    # Permission denied
ls project/                    # Permission denied
cat project/app.log            # Permission denied
nano project/app.log           # Permission denied
mv project/app.log ./app.log   # Permission denied
./project/script.sh            # Permission denied
```

**Any operation applied to what's inside that directory gets denied if there is no x on that directory.**
Check if the directory has x before looking at the file permissions inside that directory.

---

## 10. Changing Ownership — `chown`, `chgrp`, `chmod`

Only **root or sudo** can run these.
Only use them when file ownership is wrong and needs fixing.

```bash
chown newuser file        # change the owner
chgrp newgroup file       # change the group
chown newuser:newgroup file  # change both at once
```

chmod (permissions) → owner of the file or sudo
chown (ownership)   → sudo only
chgrp (group)       → sudo only

**2. `chmod` (permissions)**
Root can modify any file's permissions. And if I'm the owner of the file, I can also modify the permissions myself — because I'm the one who created it.

**3. `chown` (ownership)**
Only root can do it. Sudo is needed — because you're modifying who the system says the file belongs to, not just your own access to it. Only root, a hundred percent.

sudo chown -R hamzamohamoud825:dev-team bash-lab
this recursively changes the owner and group in the bash-lab directory everything in it including the directory itself.

---

## 11. `sudo -l` / `sudo command` / `sudo -i`

sudo -l
A list of commands you're allowed to run as root (probably ALL)

```bash
# Run one command as root
sudo whoami  # Prints "root", then you're back to your user

# Open a root shell (like su - similar to you switching to root)
sudo -i
whoami       # Prints "root"
exit         # Back to your user
```

sudo command = one command, then back to your user
sudo -i = root shell, stay as root until you exit

---

## 12. Root Check in Scripts — `$EUID`

```bash
   if [ "$EUID" -ne 0 ]; then 
     echo "Run as root" >&2
     exit 1
   fi
```
//EUID = 0 means its the root account, if the user account running the script isnt the root, it prints an error and exits otherwise the script can proceed sequentially

---

## 13. Service Accounts — Correction & Consolidated Notes

Good catch on wanting this cleaned up — but there's one real error in there I need to fix before you lock it in: **`usermod` does not have a `-r` flag** for converting an account to a service account. That's a `useradd`-only flag. `sudo usermod -r -s /usr/sbin/nologin appuser` would actually error out or do something unintended — it's not a valid way to "retroactively" make something a service account.

Here's the corrected, consolidated version:

---

**Shell field in `/etc/passwd`:**
- `/bin/bash` at the end → interactive account. Can `su - user` or `ssh user@host` and get a real shell.
- `/usr/sbin/nologin` (or `/bin/false`) at the end → non-interactive. Authentication can still succeed, but the shell immediately exits — no terminal, no interaction.

**What a service account actually is:**
A service account is just a regular Linux user account that a *program* runs as instead of a human. It's not a special account type — it's a label/identity used to scope ownership and permissions to that process. E.g., a web app runs as `appuser`; a second app can run as that same `appuser` or its own separate account, depending on whether you want to isolate them from each other.

**`su - user` vs `sudo -u user command`:**
- `su - user` → fully become that user until you exit (needs their password, unless you're root).
- `sudo -u user command` → run one command as that user, then you're immediately back to yourself.

**Creating a new service account from scratch:**
```bash
sudo useradd -r -m -s /usr/sbin/nologin appuser
```
- `-r` → system account (assigns a UID in the system range, by convention usually below 1000 — this varies by distro, it's a convention not a hard rule).
- `-m` → still create a home directory, in case the app needs it for config/state.
- `-s /usr/sbin/nologin` → the actual lock. Blocks interactive login regardless of UID.

**Converting an existing interactive user into non-interactive:**
```bash
sudo usermod -s /usr/sbin/nologin appuser
```
- This blocks login (same effect as above) but does **not** change the UID range — the account stays in whatever UID it already had.
- **There is no `-r` flag on `usermod`.** You cannot cleanly "retroactively" flip an existing user into the system-UID range this way. Changing an existing user's UID is a separate, risky operation (`usermod -u`) because it can orphan file ownership across the filesystem — not something you do casually, and not part of this workflow.
- **Bottom line:** `usermod -s /usr/sbin/nologin` makes the account non-interactive. Whether its UID happens to look like a "service account" or a "user account" by number is a separate, cosmetic detail — the thing that actually matters (can it log in?) is fully handled by `-s` alone.

**UID convention (not a rule, just a signal):**
- UID `< 1000` → system/service account.
- UID `>= 1000` → human user account.
- This is a naming/numbering convention that tools like `useradd -r` follow — it's not what makes something "actually" a service account. The `nologin` shell is what makes it non-interactive; the UID is just a label.

---

Everything else in your notes was accurate. The one thing to strike from memory: **no `-r` on `usermod`.**

---

## 14. `ls -ld`

ls -ld = list the directory itself, not what's inside it.
Breaking down the flags:
ls -l → long format (permissions, owner, group, size, date)
-d → "directory" — show the directory entry itself, don't expand into its contents
Why this matters: if you run ls -l somedir/ (no -d), you get a listing of everything inside somedir/. If you run ls -ld somedir/, you get one line — the permissions/owner/group of somedir/ itself.

---

## 15. `newgrp` — Refreshing Group Membership

Your terminal already has a list of your groups from when you opened it. Adding a new group doesn't update that list automatically. You have to run newgrp groupname to get a fresh list