# Challenge — File Operations: Permissions, Archiving & Links

No notes. No copying. Build everything, run everything, fix what breaks.

---

## Round 1 — Permissions, Fast

1. Check your current `umask`, then create a file and a directory and confirm their permissions match what the umask predicts.
2. `chmod -R 755` a directory tree containing both files and subdirectories. `ls -lR` it and identify the exact problem this causes for the files inside.
3. Fix that same tree so directories are `755` and files are `644`, in two separate commands.
4. Remove the `x` bit from a directory you can otherwise read (`chmod 600`). Try `ls` on it, then try `cat`-ing a file inside it. Explain the different results.
5. Use `find` to locate every file under a directory with `777` permissions. Create one deliberately, confirm `find` catches it, then fix it.

---

## Round 2 — Archiving, Fast

1. Create an uncompressed `tar` archive of a directory. List its contents without extracting.
2. Create a compressed (`.tar.gz`) version of the same directory. Compare file sizes between the two.
3. Extract the compressed archive into a specific target directory using `-C` — not your current directory.
4. Create a `tar.gz` backup of a directory that excludes one specific file pattern (`--exclude`). Confirm the excluded pattern is genuinely absent from the archive by listing its contents.
5. Do the same backup as a `.zip` instead. List its contents without extracting, then extract it into a named target directory.

---

## Round 3 — Links, Fast

1. Create a symlink pointing at a real directory. Confirm you can read through it.
2. Repoint that same symlink to a different target, without deleting it first, using the correct flags to force a clean repoint (not a nested mess).
3. Delete the symlink's current target. Confirm the symlink still exists but is now broken.
4. Use the correct single command to both prove the symlink is broken AND show exactly what path it was pointing at.
5. Fix the symlink by repointing it at something that still exists.

---

## Final Build — Deploy Script Cold

Build `ops-lab/scripts/deploy-challenge.sh` from a blank file. No looking at your Lab 11 version.

**Must do, in order:**

1. Accept exactly one argument (a release version). No argument → usage, distinct exit code.
2. Confirm the target release directory exists (`-d` test) before doing anything else. Missing → distinct exit code, different from the no-argument case.
3. Back up whatever the `current` symlink currently points to, as a timestamped `.tar.gz`, before touching anything.
4. Apply correct permissions to the new release: directories `755`, files `644` — never a blanket `chmod -R` that makes files executable.
5. Repoint the `current` symlink to the new release using the correct flags to force a clean repoint.
6. Verify the repoint actually worked using the command that resolves a symlink's real target.
7. Run a `find -perm 777` safety check against the newly deployed release directory and warn if anything comes back.
8. Print a clear summary: what's live now, where the backup landed.

**Prove it:**
- Run it against a real release version — confirm `current` repoints correctly
- `readlink -f` the `current` symlink and confirm it resolves to the right path
- Confirm the backup archive exists and actually contains the previous release's files (`tar -tvf` it)
- Confirm file permissions in the new release are `644`, not `755`

---

## Break/Fix Gauntlet

Fix all 6. Write only the corrected command, no explanation needed unless asked.

1.
```bash
chmod -R 755 releases/v1.0.0
```
Files inside now show as executable. Fix the command sequence so only directories get `755` and files get `644`.

2.
```bash
tar -xvf backup.tar.gz
```
Fails or produces garbage. Fix it.

3.
```bash
tar -xvf backup.tar
```
Extracted into the wrong place. Fix it to extract into `./restore/` specifically.

4.
```bash
ln -s releases/v2.0.0 current
```
Run twice, pointing at two different releases. Second run doesn't cleanly repoint. Fix the command.

5.
```bash
find /some/path -perm 777
```
Returns nothing, but you know a `777` file exists somewhere under a subdirectory. Explain the likely reason (hint: check the path you're searching from) and give the corrected command.

6. A symlink named `current` is broken — its target was deleted. Give the one command that both confirms it's broken and shows what path is missing.

---

## Pass Criteria

- All 3 rounds run clean, first try or after your own fix
- `deploy-challenge.sh` built cold, correctly backs up + repoints + sets correct permissions, all exit codes correct
- All 6 break/fix items fixed with the corrected command shown
- You can rebuild `deploy-challenge.sh` again tomorrow without looking at today's copy

If `deploy-challenge.sh` doesn't work cleanly, repeat the lab.