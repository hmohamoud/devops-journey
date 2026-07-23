# Lab 08 — Challenge (Mastery Check)

Matches the trimmed instructions.md — Tasks 1–11 plus the 5 kept Break/Fix patterns. No notes, no looking anything up. If you can do all of this cleanly, you've mastered what this lab was actually trying to teach you.

---

## Part A — Predict, Then Run (10 questions)

For each one: write down what you think will happen *before* you run it, then run it and check yourself. Don't skip the prediction step — that's the actual test.

1. What does this print?
   ```bash
   x="10"
   y="abc"
   echo $((x + 1))
   echo $((y + 1))
   ```

2. What does this print?
   ```bash
   greet() {
     msg="hello"
   }
   greet
   echo "$msg"
   ```

3. What does this print, and why is it different from question 2?
   ```bash
   greet() {
     local msg="hello"
   }
   greet
   echo "$msg"
   ```

4. What does this print?
   ```bash
   label="fleet report"
   echo $label
   echo "$label"
   ```

5. What does this print?
   ```bash
   servers=("web01" "web02" "web03")
   echo "${servers[-1]}"
   echo "${#servers[@]}"
   ```

6. What does this print, and what's actually wrong with it?
   ```bash
   servers=("web01" "web02" "web03")
   for s in $servers; do
     echo "$s"
   done
   ```

7. Given `count` is unset, what does this print — and what's the difference between the two lines?
   ```bash
   echo "${count:-0}"
   echo "$count"
   ```
   ```bash
   echo "${count:=0}"
   echo "$count"
   ```

8. What does this print for `port=8080`?
   ```bash
   if [ "$port" -gt 8000 ]; then
     echo "high"
   else
     echo "low"
   fi
   ```

9. Given `status=""` (empty, but set), what does this print?
   ```bash
   if [ -z "$status" ]; then
     echo "empty"
   else
     echo "has value: $status"
   fi
   ```

10. What does this print, and what's the bug?
    ```bash
    count="15"
    if [ $count = 15 ]; then
      echo "match"
    fi
    if [ $count -eq 015 ]; then
      echo "also match?"
    fi
    ```

---

## Part B — Build It

One script: `bash-lab/scripts/fleet-check.sh`. No copy-pasting from the instructions — write it from a blank file.

**Requirements:**

1. Accept a server name as `$1`
   - No argument → print a usage message, exit `2`
   - Argument given → continue

2. Build an array of every server name from `bash-lab/data/servers.txt` (pure Bash line-splitting, no `awk`)

3. Search the array for the name passed in
   - Not found → print a clear "not found" message, exit `1`
   - Found → continue

4. Once found, look up that server's full record (all 5 fields) and print:
   - The server's status
   - The server's port
   - Whether the port is above `8000` (numeric comparison)
   - The status uppercased

5. Use a `local` variable inside at least one function in this script, and prove — by testing it — that it doesn't leak outside that function

6. Use `${var:-default}` (or `:=`) somewhere in your validation logic, not just a plain `if [ -z ]` check

7. Exit `0` on a successful lookup

**Prove it:**
- Run with no argument — capture exit code `2`
- Run with a name that doesn't exist — capture exit code `1`
- Run with a real name (e.g. `web01`) — capture exit code `0` and the full printed output

---

## Self-Check

Check nothing off unless you actually ran it and it worked, no notes open.

```
[ ] Predicted and correctly explained all 10 Part A questions
[ ] Explained why example 2 leaked and example 3 didn't
[ ] Explained the bug in example 6 (array loop) and could fix it
[ ] Explained the difference between :- and := in example 7
[ ] Explained the bug in example 10 (= vs -eq)
[ ] fleet-check.sh handles: no argument, not-found, and found — all three exit codes correct
[ ] fleet-check.sh uses a local variable and I proved it didn't leak
[ ] fleet-check.sh uses a default-value expansion, not just -z
[ ] I could rebuild this script from scratch tomorrow without looking at today's version
```

If every box is checked honestly — Lab 08 is mastered at the level that actually matters for the job.