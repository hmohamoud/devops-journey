# Lab 11 — File Operations: Permissions, Archiving & Links

## Objective

Build muscle memory for the parts of file operations you'll actually use on the job: fixing permission drift across a deployed directory, packaging/backing up files correctly, and the release-directory symlink pattern real deploy scripts use. Less explaining, more typing.

**Scope, deliberately narrow:** `umask`, `chmod -R`, directory traversal (`x` bit), `find -perm`, `tar` (with compression, exclude, `-C`), `zip`/`unzip`, `ln -s`, identifying broken symlinks with `readlink -f`. setuid/setgid/sticky bit/hard links are mentioned once each at the end — no tasks, you won't use them on the job.

---

## Environment Setup

```text
ops-lab/
├── app/
│   └── releases/
│       ├── v1.0.0/
│       │   └── app.txt
│       ├── v1.1.0/
│       │   └── app.txt
│       └── v1.2.0/
│           └── app.txt
├── configs/
│   ├── app.conf
│   └── database.conf
├── logs/
│   └── app.log
├── backups/
└── scripts/
```

```bash
mkdir -p ops-lab/app/releases/v1.0.0 ops-lab/app/releases/v1.1.0 ops-lab/app/releases/v1.2.0 ops-lab/configs ops-lab/logs ops-lab/backups ops-lab/scripts

echo "release 1.0.0" > ops-lab/app/releases/v1.0.0/app.txt
echo "release 1.1.0" > ops-lab/app/releases/v1.1.0/app.txt
echo "release 1.2.0" > ops-lab/app/releases/v1.2.0/app.txt

cat > ops-lab/configs/app.conf << 'EOF'
APP_ENV=production
PORT=8080
EOF

cat > ops-lab/configs/database.conf << 'EOF'
DB_HOST=localhost
DB_PORT=5432
EOF

echo "$(date) INFO app started" > ops-lab/logs/app.log
```

---

## Block 1 — Permissions Reps (do all of these, back to back)

1. Run `umask` alone — note the current value. Create a new file and a new directory right after (`touch test.txt`, `mkdir testdir`), then `ls -l` both — confirm the permissions match what the umask predicts (umask is subtracted from the default 666/777).
2. Change your umask for this session: `umask 077`. Create another test file. `ls -l` it — confirm it's now much more restrictive than before. Set it back: `umask 022`.
3. `chmod -R 755 ops-lab/app/releases` — apply recursively, then `ls -lR ops-lab/app/releases` and confirm every file AND directory got `755` — including `app.txt`, which almost never should be executable. This is the actual gotcha: `-R` applies the same mode to files and directories alike, whether that's correct or not.
4. Fix the gotcha from #3 properly: `chmod -R 755 ops-lab/app/releases` for directories, then separately `chmod 644 ops-lab/app/releases/*/app.txt` for the files, so directories are traversable but files aren't executable.
5. Directory `x` bit test: `chmod 600 ops-lab/configs` (removes `x`), then try `ls ops-lab/configs` (should still list names) and `cat ops-lab/configs/app.conf` (should fail — no traversal permission). Restore with `chmod 755 ops-lab/configs`. Confirm `cat` works again.
6. `find ops-lab/ -perm 777` — should find nothing yet. Deliberately create a dangerously open file: `touch ops-lab/backups/oops.txt && chmod 777 ops-lab/backups/oops.txt`. Rerun the `find` — confirm it's now caught. Fix it: `chmod 644 ops-lab/backups/oops.txt`, then `rm ops-lab/backups/oops.txt`.

---

## Block 2 — Archiving Reps

1. `tar -cvf ops-lab/backups/configs.tar ops-lab/configs` — create an uncompressed archive. `ls -lh` it and note the size.
2. `tar -tvf ops-lab/backups/configs.tar` — list its contents without extracting anything. Confirm both config files show up.
3. `tar -xvf ops-lab/backups/configs.tar -C ops-lab/backups/` — extract it into a specific target directory using `-C` (don't just extract into your current directory). Confirm the files landed inside `ops-lab/backups/ops-lab/configs/`.
4. Now do it compressed: `tar -czvf ops-lab/backups/configs.tar.gz ops-lab/configs`. Compare file sizes: `ls -lh ops-lab/backups/configs.tar ops-lab/backups/configs.tar.gz` — confirm the `.gz` version is smaller.
5. Extract the compressed one: `tar -xzvf ops-lab/backups/configs.tar.gz -C ops-lab/backups/`. Confirm it works — note that you needed `-z` this time, unlike step 3.
6. Back up the whole `ops-lab/app` directory, but exclude the actual release contents to save space (a realistic scenario — you often want structure, not bulk data): `tar -czvf ops-lab/backups/app-structure.tar.gz --exclude='*.txt' ops-lab/app`. `tar -tvf` it and confirm the directories are listed but no `.txt` files are inside.
7. `zip -r ops-lab/backups/configs.zip ops-lab/configs` — same idea as `tar`, different format. `unzip -l ops-lab/backups/configs.zip` — list contents without extracting (this is `zip`'s version of `tar -tvf`).
8. `unzip ops-lab/backups/configs.zip -d ops-lab/backups/unzipped-configs` — extract into a specific target directory. Confirm the files landed there.

---

## Block 3 — Links Reps

1. Build the real deployment pattern: `ln -s ops-lab/app/releases/v1.2.0 ops-lab/app/current`. `ls -l ops-lab/app/` — confirm you see the `l` flag and the `-> ops-lab/app/releases/v1.2.0` target notation.
2. Confirm the symlink actually works: `cat ops-lab/app/current/app.txt` — should transparently read through to `v1.2.0`'s file.
3. Simulate a new deployment: repoint the symlink to a different release without deleting and recreating from scratch — `ln -sfn ops-lab/app/releases/v1.1.0 ops-lab/app/current` (the `-f` forces overwrite, `-n` prevents a subtle bug where it'd otherwise nest inside the old target if it's a directory). `cat ops-lab/app/current/app.txt` again — confirm it now reads `v1.1.0`.
4. Break a symlink on purpose: `rm -rf ops-lab/app/releases/v1.1.0`. Run `ls -l ops-lab/app/current` — the symlink still exists but is now broken (often shown in a different color, or just fails when accessed).
5. Confirm it's broken and identify what it was pointing at: `readlink -f ops-lab/app/current` — this resolves the symlink's target path even when that target no longer exists, telling you exactly what's missing.
6. Fix it by repointing to a release that still exists: `ln -sfn ops-lab/app/releases/v1.2.0 ops-lab/app/current`. Confirm with `cat ops-lab/app/current/app.txt`.

---

## Capstone — Deploy Script

Build `ops-lab/scripts/deploy.sh`. This combines all three blocks into one realistic tool.

**Requirements:**

1. `set -euo pipefail`, standard `validate_args()` pattern — script takes exactly one argument: a release version (e.g. `v1.0.0`)
2. Confirm the target release directory (`ops-lab/app/releases/<version>`) exists using `-d` — exit with a distinct code if it doesn't
3. Before switching, back up the CURRENT release (whatever `ops-lab/app/current` currently points to) into `ops-lab/backups/` using `tar -czvf`, named with a timestamp
4. Apply correct permissions to the new release directory: directories `755`, files `644` — not a blanket `chmod -R` that makes everything executable
5. Repoint the `ops-lab/app/current` symlink to the new release using `ln -sfn`
6. Verify the symlink resolves correctly using `readlink -f` and print the confirmed target
7. Run `find ops-lab/app/releases/<version> -perm 777` as a safety check — if anything comes back, print a warning (shouldn't normally happen, but prove the check exists)
8. Print a summary: which release is now live, where the backup was saved

**Prove it:**
```bash
./ops-lab/scripts/deploy.sh v1.0.0
readlink -f ops-lab/app/current
cat ops-lab/app/current/app.txt
ls -lh ops-lab/backups/
```
Confirm: `current` now points at `v1.0.0`, a timestamped backup of the previous release exists in `backups/`, and file/directory permissions in the new release are correct (`644`/`755`, not blanket `755`).

---

## Break/Fix — Fix All of These, No Skipping

### 1
```bash
chmod -R 755 ops-lab/app/releases
```
Run this, then check: does `app.txt` now show as executable in `ls -l`? Explain why, and fix it so directories are `755` but files stay `644`.

### 2
```bash
tar -xvf ops-lab/backups/configs.tar.gz
```
This fails or produces garbled output. Explain why, and give the correct command.

### 3
```bash
tar -xvf ops-lab/backups/configs.tar
```
Files extracted into your current directory instead of where you meant them to go. Fix it using the flag that controls the extraction target.

### 4
```bash
ln -s ops-lab/app/releases/v1.1.0 ops-lab/app/current
```
Run this a second time, pointing at a different release, without any extra flags. Explain what actually happens (hint: check `ls -l ops-lab/app/` carefully — did it repoint, or nest?). Fix it using the correct flags to force a clean repoint.

### 5
```bash
umask 000
touch ops-lab/backups/newfile.txt
ls -l ops-lab/backups/newfile.txt
```
Explain exactly why this file's permissions are dangerous, and fix both the file's permissions and your umask back to something safe.

### 6
A symlink at `ops-lab/app/current` points at a release directory that was deleted. Write the one command that proves it's broken and tells you exactly what path it was pointing at.

---

## Notes / Evidence / README

Same format as previous labs. `notes.md` explains `umask`, `chmod -R` (and its file-vs-directory gotcha), directory traversal, `find -perm`, `tar` (all flag variants used), `zip`/`unzip`, `ln -s`, and broken-symlink detection — in your own words. `evidence.md` needs at least 6 break/fix write-ups. `README.md` — same structure as Lab 05–10.

---

## Awareness Only — No Tasks

- **setuid/setgid** — special permission bits that let a program run with the file owner's/group's privileges instead of the invoking user's. You'll rarely if ever set these yourself in cloud/DevOps work.
- **Sticky bit** — the reason `/tmp` lets any user create files but only the file's own owner can delete them. Recognize it if you see it (`ls -ld /tmp`), you won't be setting it.
- **Hard links** — a second name pointing at the exact same file data (not a path, the actual inode). Real, but essentially never used in real cloud/DevOps work — symlinks are what you'll actually reach for.

---

## Pass Standard

You pass when you can build `deploy.sh` from a blank file, no notes, and it correctly backs up, repoints the symlink, and applies correct (not blanket) permissions every time.