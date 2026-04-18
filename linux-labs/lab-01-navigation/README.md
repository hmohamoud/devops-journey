cat > linux-labs/lab-01-navigation/README.md << 'EOF'
# Linux Lab 01 — Navigation & File Management

## Problem
Needed to efficiently navigate and manage files in a Linux system without relying on trial-and-error or manual searching.

---

## What I Built
Created a structured filesystem with directories (logs, reports, drafts, scripts, archive) and implemented workflows to organise, move, copy, and manage files across the system.

---

## How I Solved It
- Used `cd`, `pwd`, `ls` for precise navigation
- Applied relative (`../`) and absolute (`~/...`) paths for efficiency
- Used `mv`, `cp`, `rm`, `mkdir`, `rmdir` for file operations
- Verified every step using `ls` to avoid errors

---

## Tools Used
- `cd`, `pwd`, `ls`
- `mv`, `cp`, `rm`
- `mkdir`, `rmdir`
- `cat`, `echo`

---

## Result
- Navigated filesystem without guessing
- Reduced inefficient multi-step movement into single commands
- Managed files across directories with consistent verification

---

## Proof

### Structure
\`\`\`bash
ls -R
\`\`\`

### File Movement
\`\`\`bash
mv reports/file1.txt archive/
ls archive
\`\`\`

### Efficient Navigation
\`\`\`bash
cd ../reports
pwd
\`\`\`

---

## Key Takeaway
Linux does not guess — everything depends on correct paths.  
Efficiency comes from understanding structure, not memorising commands.

---

## Next Step
Permissions and execution control (Lab 02)
EOF
