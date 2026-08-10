# Evidence — Lab 11: File Operations, Permissions, Archiving & Links

Same format as Lab 10's evidence.md: predictions written before running, then verified against actual output. Fill in the blank sections with real terminal output as you work through Block 1–3 and the Break/Fix Gauntlet — don't fill in "Actual output" until you've genuinely run the command.

---

## Part A — Predict, Then Run

### 1. `umask` and default permissions

```bash
umask
touch test.txt
mkdir testdir
ls -l test.txt
ls -ld testdir
```

**Predicted output:**


**Actual output:**


**Why:** the default for a file is `666`, the default for a directory is `777` — umask subtracts from each. Predict what the current umask value subtracts before running, then confirm the real permission bits match.

---

### 2. `chmod -R 755` on a mixed tree

```bash
chmod -R 755 ops-lab/app/releases
ls -lR ops-lab/app/releases
```

**Predicted output:**


**Actual output:**


**Why:** `chmod -R` applies the same mode to every file and directory alike — predict specifically whether `app.txt` ends up executable, and why that's a problem for a real deployment.

---

### 3. Directory `x` bit removed

```bash
chmod 600 ops-lab/configs
ls ops-lab/configs
cat ops-lab/configs/app.conf
```

**Predicted output:**


**Actual output:**


**Why:** predict which of the two commands (`ls` or `cat`) succeeds and which fails once the `x` bit is gone, and explain the difference between listing names and traversing into a directory.

---

### 4. `find -perm 777`

```bash
find ops-lab/ -perm 777
touch ops-lab/backups/oops.txt && chmod 777 ops-lab/backups/oops.txt
find ops-lab/ -perm 777
```

**Predicted output (before creating oops.txt):**


**Predicted output (after):**


**Actual output:**


---

### 5. Compressed vs uncompressed archive size

```bash
tar -cvf ops-lab/backups/configs.tar ops-lab/configs
tar -czvf ops-lab/backups/configs.tar.gz ops-lab/configs
ls -lh ops-lab/backups/configs.tar ops-lab/backups/configs.tar.gz
```

**Predicted output:**


**Actual output:**


**Why:** predict which file is smaller before checking, and explain in one line why.

---

### 6. Extracting a `.tar.gz` with the wrong flag

```bash
tar -xvf ops-lab/backups/configs.tar.gz
```

**Predicted output:**


**Actual output:**


**Why:** predict whether this succeeds, fails outright, or produces garbled output — and what flag is actually needed for a compressed archive.

---

### 7. Repointing a symlink without `-f -n`

```bash
ln -s ops-lab/app/releases/v1.1.0 ops-lab/app/current
ln -s ops-lab/app/releases/v1.2.0 ops-lab/app/current
ls -l ops-lab/app/
```

**Predicted output:**


**Actual output:**


**Why:** predict whether the second `ln -s` cleanly repoints the link or does something unexpected (check carefully whether it nested instead), and what the fix looks like using `-sfn`.

---

### 8. A broken symlink

```bash
rm -rf ops-lab/app/releases/v1.1.0
ls -l ops-lab/app/current
readlink -f ops-lab/app/current
```

**Predicted output:**


**Actual output:**


**Why:** predict what `readlink -f` shows even though the target no longer exists — this is the one command that proves it's broken and tells you exactly what's missing, in a single step.

---

## Break/Fix Write-Ups

Fill in one of these per Break/Fix item from `instructions.md`. Use the exact same structure as Lab 10's break/fix entries: what you tried, what happened, why, and the fix.

### Break/Fix 1 — `chmod -R 755` making files executable

**What I tried:**


**What happened:**


**Why it happened:**


**How I fixed it:**


---

### Break/Fix 2 — Wrong extraction command on a `.tar.gz`

**What I tried:**


**What happened:**


**Why it happened:**


**How I fixed it:**


---

### Break/Fix 3 — Extracting into the wrong location

**What I tried:**


**What happened:**


**Why it happened:**


**How I fixed it:**


---

### Break/Fix 4 — Symlink repoint without `-f -n`

**What I tried:**


**What happened:**


**Why it happened:**


**How I fixed it:**


---

### Break/Fix 5 — `umask 000` and a dangerously open file

**What I tried:**


**What happened:**


**Why it happened:**


**How I fixed it:**


---

### Break/Fix 6 — Diagnosing a broken symlink in one command

**What I tried:**


**What happened:**


**Why it happened:**


**How I fixed it:**


---

## Deploy Script Proof (`ops-lab/scripts/deploy.sh`)

```bash
./ops-lab/scripts/deploy.sh v1.0.0
readlink -f ops-lab/app/current
cat ops-lab/app/current/app.txt
ls -lh ops-lab/backups/
```

**Actual output:**


**Confirmed:**
- [ ] `current` now points at `v1.0.0`
- [ ] A timestamped backup of the previous release exists in `backups/`
- [ ] New release directories are `755`, files are `644` — not a blanket `755`
- [ ] `find ... -perm 777` safety check runs and reports correctly

---

## Self-Check

```
[ ] Predicted and correctly explained all 8 Part A questions before checking actual output
[ ] Explained the file-vs-directory gotcha in chmod -R with a real example, not just in theory
[ ] Explained the directory x-bit distinction (ls works, cat fails) with real output
[ ] All 6 Break/Fix items fixed with real broken → fixed output captured
[ ] deploy.sh built and passes all 4 proof checks above
[ ] I could rebuild deploy.sh from scratch tomorrow without looking at today's version
```

---

## Key Patterns

- `chmod -R` treating files and directories identically is the recurring trap in this lab — the fix is always `find -type d -exec chmod ... +` and `find -type f -exec chmod ... +` run separately, never one blanket recursive command for a real deployment.
- Compressed vs uncompressed `tar` isn't just a size difference — forgetting the `-z` flag on either side (creating or extracting) produces a real failure, not a silent success.
- `ln -sfn` (not plain `ln -s`) is the only safe way to repoint an existing symlink — plain `ln -s` on an existing link name either fails or nests unexpectedly depending on whether the target is a directory.
- `readlink -f` is the single command that diagnoses a broken symlink — it works precisely because it doesn't require the target to still exist.

## Main Takeaways

- Every "gotcha" in this lab traces back to the same root idea: **broad, blanket commands (`chmod -R`, plain `ln -s` on an existing link) are convenient but dangerous**, because they don't distinguish between cases that actually need different treatment.
- The correct fix is almost always to be more specific — `find -type d` vs `-type f`, `-sfn` instead of `-s`, `-C` instead of extracting into whatever directory you happen to be standing in.
- This is the same discipline carried over from Lab 10's `set -euo pipefail`/`trap` material: don't rely on a command's default, permissive behavior — be explicit about exactly what you want to happen.