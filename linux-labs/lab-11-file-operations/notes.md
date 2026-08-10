# Notes — Lab 11: File Operations, Permissions, Archiving & Links

---

## 1. Default Permissions & `umask`

**The starting/default permission for a file is `666`.**
**The starting/default permission for a directory is `777`.**

When you create a file or directory, Bash doesn't just hand it the full default — it applies your **umask** first, which subtracts permission bits from that default. `umask` is what actually decides the real permissions a newly created file or directory ends up with.

You can change your umask for the current session: `umask 077`. This makes anything you create from that point on much more restrictive — a stricter umask means fewer bits get handed out from the 666/777 starting point.

---

## 2. `chmod -R` — The File-vs-Directory Trap

`chmod -R 755 ops-lab` applies the exact same permission to **every file in it, including the directory itself** — no distinction between files and directories. This is the actual gotcha: a blanket `-R` doesn't know or care that files and directories usually need *different* permission patterns (directories need the execute bit to be traversable; regular files almost never should be executable).

---

## 3. Archiving — What "Archive" and "Compressed" Actually Mean

**Archive** means putting multiple files/directories into one package.

**Uncompressed** means packaging them without trying to make the package smaller.

**Compressed** means packaging them while also making the package smaller.

### Creating an archive

```bash
tar -cvf ops-lab/backups/configs.tar ops-lab/configs
```

Read this command as: *I want the archive to be in this location, and I want to name the archive `configs.tar`* (`ops-lab/backups/configs.tar`), *and `ops-lab/configs` is the thing being archived.* The path before the source directory is where the finished archive gets written and what it gets called — not the thing being packaged.

### Looking inside an archive without extracting it

```bash
tar -tvf ops-lab/backups/configs.tar
```

Lets you see what is inside the archive you created, without pulling any of it out onto disk.

### Extracting into a specific directory

```bash
tar -xvf ops-lab/backups/configs.tar -C ops-lab/extracts
```

Lets me extract the contents inside the archive into a specific target directory using `-C`, and I can choose the directory — e.g. a directory I made called `ops-lab/extracts`.

### Compressing an archive

```bash
tar -czvf ops-lab/backups/configs.tar.gz ops-lab/configs
```

This creates an archive but compresses it, reducing its size.

### Compressing while excluding a pattern

```bash
tar -zcvf ops-lab/testdir/app-structure.tar.gz --exclude="*.txt" ops-lab/app
```

This creates a compressed archive but excludes any `.txt` files inside `ops-lab/app`.

### The three `tar` letters that matter most

```
c = Create 📦
t = Tell me what's inside 👀
x = eXtract 📤
```

### `zip` — same ideas, different format

```bash
zip -r ops-lab/backups/configs.zip ops-lab/configs
```

The same as `tar -cvf`, just a different format.

```bash
unzip ops-lab/backups/configs.zip -d ops-lab/backups/unzipped-configs
```

The same as `tar -xvf`, just a different format.

---

## 4. Symlinks

### Creating a symlink

```bash
ln -s ops-lab/app/releases/v1.2.0 ops-lab/app/current
```

This creates the link called `ops-lab/app/current`, and it points to `ops-lab/app/releases/v1.2.0`.

### How reading through a symlink actually works

```bash
cat ops-lab/app/current/app.txt
```

This will first go to the target, which is `ops-lab/app/releases/v1.2.0`, then read what's inside it. In other words, just think of the target as *replacing* `ops-lab/app/current` in the path. Imagine: `cat ops-lab/app/current/app.txt` → this will go to the target and read `app.txt` from there.

### Repointing a symlink

```bash
ln -sfn ops-lab/app/releases/v1.0.0 ops-lab/app/current
```

If you want to repoint a symlink you've already created to a different target, this is how — `-f` forces the overwrite, `-n` stops it from nesting inside the old target instead of cleanly replacing it.

### Absolute vs relative targets

When creating symlinks, it's better to make the target absolute than relative, so there are no path-resolution errors later:

```bash
ln -s "$(pwd)/ops-lab/app/releases/v1.0.0" ops-lab/app/current
```

### Finding what a symlink actually points to

```bash
readlink -f ops-lab/app/current
```

Tells you what the symlink points at — basically, the target of the symlink. This works even if the target no longer exists, which is exactly how you diagnose a broken symlink.

---

## 5. `find ... -exec` — Applying a Command to Every Match

```bash
find ops-lab/app/releases -type d -exec chmod 755 {} +
```

- `find ops-lab/app/releases` → search this directory tree
- `-type d` → applies to only directories inside the directory tree
- `-exec chmod 755 {} +` → apply `chmod 755` to everything found

```bash
find ops-lab/app/releases -type f -exec chmod 644 {} +
```

Same idea — `-type f` means it applies to only files inside the directory tree.

This is the *correct* way to fix the `chmod -R` gotcha from section 2: instead of one blanket command that treats files and directories the same, `find -type d` and `find -type f` let you target each one separately with the right permission.

---

## Quick-Reference Summary

| Concept | Meaning |
|---|---|
| Default file permission | `666` |
| Default directory permission | `777` |
| `umask` | Subtracts from the default to decide real starting permissions |
| `chmod -R` | Applies the same mode to files AND directories alike — doesn't distinguish |
| Archive | Multiple files/directories packaged into one |
| Uncompressed | Packaged without size reduction |
| Compressed | Packaged with size reduction |
| `tar -cvf dest.tar source/` | Create an archive at `dest.tar` from `source/` |
| `tar -tvf archive.tar` | List contents without extracting |
| `tar -xvf archive.tar -C dir/` | Extract into a specific target directory |
| `tar -czvf` | Create, compressed |
| `--exclude="*.txt"` | Leave matching files out of the archive |
| `zip -r` / `unzip -d` | Same ideas as `tar -cvf` / `tar -xvf`, different format |
| `ln -s target link` | Create a symlink |
| `ln -sfn target link` | Repoint an existing symlink cleanly |
| `readlink -f link` | Show what a symlink actually points to, even if broken |
| `find path -type d -exec chmod 755 {} +` | Apply a permission only to directories |
| `find path -type f -exec chmod 644 {} +` | Apply a permission only to files |