# Evidence — Server Health Check Reporter

Real bugs hit while building this script, in the order they were found, with the actual broken code and the actual fix. Test results section still needs real captured output filled in once the final version is run against all scenarios.

---

## Error Fixes (in the order they were actually hit)

### Error 1 — Missing space before closing bracket
**What I tried:**
```bash
if [ "$actual" == "-h"] || [ "$actual" == "--help" ]; then
```
**What happened:** syntax error — Bash treats `]` as its own argument to `[`, so `"-h"]` with no space breaks it.

**Why it happened:** `[` is actually a command, not special syntax — it needs its closing `]` as a separate, space-delimited argument.

**How I fixed it:**
```bash
if [ "$actual" == "-h" ] || [ "$actual" == "--help" ]; then
```

---

### Error 2 — Mismatched quotes in an echo string
**What I tried:**
```bash
echo "Usage: "Usage: ./health-check.sh [FILE]"
```
**What happened:** broken string — quote marks didn't pair up correctly.

**Why it happened:** copy/paste error while writing the usage message, ended up with an extra `"Usage: "` fragment stuck in the middle.

**How I fixed it:**
```bash
echo "Usage: ./health-check.sh [FILE]"
```

---

### Error 3 — Comparing an argument count against a string
**What I tried:**
```bash
validate_args(){
  local actual="$1"
  local required="$2"
  if [ "$actual" -gt "$required" ] || [ "$actual" == "-h" ] || [ "$actual" == "--help" ]; then
```
called as `validate_args "$#" 1`.

**What happened:** the `-h`/`--help` branch could never match, because `$actual` was `$#` — a number like `0` or `1` — not the actual text someone typed.

**Why it happened:** didn't realize the function only receives what's explicitly passed to it — `$#` and `1` were the only two things going in, so there was no way to check the actual argument text from inside this function without also passing it in.

**How I fixed it:** removed the `-h`/`--help` check from this function entirely. Handled it separately at the script level:
```bash
if [ "$#" -ge 1 ] && [ "$fleet_file" == "-h" ] || [ "$fleet_file" == "--help" ]; then
  echo "Usage: ./health-check.sh [FILE]" >> "$error_file"
  exit 2
fi
```

---

### Error 4 — Inverted file-existence check
**What I tried:**
```bash
if [ -f "$fleet_file" ]; then
  echo "$fleet_file - doesn't exist" >> "$error_file"
  exit 1
fi
```
**What happened:** logic backwards — `-f` means the file *does* exist, so this fired the "doesn't exist" error on every file that was actually present.

**Why it happened:** misread `-f` as meaning "file missing" instead of "file exists."

**How I fixed it:**
```bash
if [ ! -f "$fleet_file" ]; then
  echo "$fleet_file - doesn't exist" >> "$error_file"
  exit 1
fi
```

---

### Error 5 — Redirect operator swallowed inside a quoted string
**What I tried:**
```bash
echo "Usage: ./health-check.sh [FILE] >> $error_file"
```
**What happened:** this just printed the literal text `>> errors/health-check-error-....log` — it never actually wrote to the file, because the `>>` was inside the quotes and treated as plain text, not a redirect.

**Why it happened:** didn't separate the message from the redirect operator.

**How I fixed it:**
```bash
echo "Usage: ./health-check.sh [FILE]" >> "$error_file"
```

---

### Error 6 — Directory name typo
**What I tried:**
```bash
report_file="report/health-check-error-$timestamp.log"
```
**What happened:** pointed at `report/` (singular), a directory that doesn't exist — the real directory created in setup was `reports/` (plural).

**How I fixed it:**
```bash
report_file="reports/health-check-report-$timestamp.log"
```
(also fixed the filename itself, which had been copy-pasted from the error-file name)

---

### Error 7 — Counters reset inside the function
**What I tried:**
```bash
is_healthy() {
  local result
  count_healthy=0
  count_warn=0
  if [ "$1" == "stopped" ] || [ "$1" == "failed" ]; then
    result="DOWN"
  ...
```
**What happened:** would have reset the running totals back to `0` on every single call, since the function runs once per server.

**Why it happened:** put accumulator variables inside something that runs repeatedly.

**How I fixed it:** removed the counters from the function entirely — `is_healthy()` only classifies, it doesn't count anything.

---

### Error 8 — Counters reset inside the loop
**What I tried:**
```bash
while IFS=, read -r name ip status port service cpu uptime; do
  health=$(is_healthy "$status" "$cpu")
  count_healthy=0
  count_warning=0
  count_down=0
  if [ "$health" == "HEALTHY" ]; then
    count_healthy=$((count_healthy + 1))
  ...
```
**What happened:** same bug, one level up — counters wiped back to `0` at the start of every loop iteration, so the final counts only ever reflected the *last* server processed, not the whole file.

**Why it happened:** same underlying scope mistake as Error 7, moved to a different spot instead of actually fixed.

**How I fixed it:** moved `count_healthy=0` / `count_warning=0` / `count_down=0` to before the `while` loop starts, so they're initialized once and only ever incremented, never reset, inside the loop.

---

### Error 9 — Checking exit status instead of captured output
**What I tried:**
```bash
if is_healthy "$status" "$cpu"; then
```
**What happened:** would have always been true, since `is_healthy()` never returns a non-zero exit code — this branch could never distinguish HEALTHY from WARNING from DOWN.

**Why it happened:** confused "the function ran successfully" with "the function's output tells me what I need to know" — these are different things in Bash.

**How I fixed it:**
```bash
health=$(is_healthy "$status" "$cpu")
```
then compared `$health` against `"HEALTHY"`, `"WARNING"`, `"DOWN"` in separate `if`/`elif` branches.

---

### Error 10 — Missing space in a `-z` check
**What I tried:**
```bash
if [ -z "$name" ] || [ -z "$ip" ] || [ -z "$status"] || [ -z "$port" ] ...
```
**What happened:** same class of bug as Error 1 — missing space before `]`.

**How I fixed it:** added the missing space: `[ -z "$status" ]`.

---

### Error 11 — Redundant file-existence re-check
**What I tried:**
```bash
zero_lines=$(wc -l < "$fleet_file")
if [ -f "$fleet_file" ] && [ "$zero_lines" -eq 0 ]; then
```
**What happened:** not a functional bug, but unnecessary — by this point in the script, the earlier `-f` check had already guaranteed the file exists (the script would have exited already if it didn't).

**How I fixed it:**
```bash
if [ "$zero_lines" -eq 0 ]; then
```

---

### Error 12 — Missing `$` on trap variables
**What I tried:**
```bash
trap 'echo "Health check complete. Healthy: $count_healthy, Warning: count_warning, Down: count_down"' EXIT
```
**What happened:** would have printed the literal text `count_warning` and `count_down` instead of their actual values.

**How I fixed it:** added the missing `$` to both.

---

### Error 13 — EXIT trap writing to the wrong destination
**What I tried:**
```bash
trap 'echo "Health check complete. Healthy: $count_healthy, Warning: $count_warning, Down: $count_down" >> "$report_file' EXIT
```
**What happened:** two problems — a mismatched quote (missing closing `"` before the final `'`), and redirecting the summary into the report file instead of printing it to the terminal, which contradicted the project's own design (the EXIT trap's job is a visible on-screen confirmation, separate from the permanent report file).

**How I fixed it:**
```bash
trap 'echo "Health check complete. Healthy: $count_healthy, Warning: $count_warning, Down: $count_down"' EXIT
```

---

### Error 14 — Dead code after `exit`
**What I tried:**
```bash
if [ "$count_down" -gt 0 ]; then
  exit 1
else
  exit 0
fi
echo "Healthy: $count_healthy" >> "$report_file"
echo "Warning: $count_warning" >> "$report_file"
echo "DOWN: $count_down" >> "$report_file"
```
**What happened:** the three `echo` lines could never run — `exit` stops the script immediately in whichever branch fires, so the final summary counts never actually got written into the report file.

**Why it happened:** didn't trace the script top to bottom before assuming it was finished.

**How I fixed it:** moved the three `echo` lines to *before* the final `if [ "$count_down" -gt 0 ]` block, so they always run first, and the exit-code decision happens last.

---

## Test Results

Fill in with real output once each scenario below is actually run:

### Test 1 — No argument, default file
**Command:**
**Output:**
**Pass/Fail:**

### Test 2 — Valid file, full run
**Command:**
**Output:**
**Pass/Fail:**

### Test 3 — Manual count vs report count
**Manual count:**
**Report count:**
**Pass/Fail:**

### Test 4 — Missing file
**Command:**
**Exit code:**
**Confirmed logged to errors/:**
**Confirmed EXIT trap still printed:**

### Test 5 — Empty file
**Command:**
**Output:**

### Test 6 — Malformed line
**Broken line used:**
**Output:**

### Test 7 — Run twice in a row
**Confirmed two separate report files:**

### Test 8 — `echo $?` with a DOWN server present
**Result:**

### Test 9 — `echo $?` with a fully healthy fleet
**Result:**

### Test 10 — shellcheck
**Warnings before:**
**Warnings after:**

---

## Proof of Completion

- [ ] Report generated successfully with correct counts
- [ ] Missing-file scenario produces exit `1`, logged error, EXIT trap still fires
- [ ] Empty-file scenario handled cleanly
- [ ] Malformed-line scenario handled without crashing
- [ ] Script run twice produces two separate, correctly timestamped reports
- [ ] Exit code `1` confirmed when a DOWN server is present
- [ ] Exit code `0` confirmed when the fleet is fully healthy
- [ ] `shellcheck` reports zero warnings
- [ ] I can explain every line of `health-check.sh` without notes