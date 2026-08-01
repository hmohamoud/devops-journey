# Challenge — Loops, Functions & Conditionals

No notes. No copying. Build everything, run everything, fix what breaks.

---

## Round 1 — Loops, Fast

Build each, run it against `bash-lab/data/fleet.txt`, confirm output, move to the next. No pausing to write explanations.

1. `while IFS=, read -r ...` loop printing every server's name + port.
2. Same loop, filtered to only `nginx` services.
3. Array built from every `ip` field, then looped with `for ip in "${ips[@]}"`.
4. Loop that counts total `running` servers into a counter variable and prints the final count.
5. Loop that prints every server whose `uptime_days` is over 100.

---

## Round 2 — Functions, Fast

Build `bash-lab/scripts/challenge-functions.sh`.

1. `is_healthy()` — takes status + cpu_load as `$1 $2`, returns `0` if running AND cpu_load < 80, `1` otherwise.
2. Write a function service_tier() that takes a service name as $1, sorts it into web (nginx/proxy), data (postgres/redis), support (auth-service/job-worker/prometheus), or other, stores the result in a local variable, and echos it back so it can be captured with $().
3. Write a function `require_arg()` that takes $# as $1, and if that value is 0, prints a usage message and returns 2 — otherwise does nothing.
4. Call `is_healthy()` in a loop over the whole file, print PASS/FAIL per server.
5. Prove one of your functions' local variable doesn't leak (call it, then check the variable name outside — should be empty/unset).

---

## Round 3 — Conditionals, Fast

Build `bash-lab/scripts/challenge-conditions.sh`.

1. `if/elif/else` over status: running / stopped / failed / unknown — 4 distinct branches.
2. `case` over service, bucketing into web/data/support/other, using `|` for at least one multi-pattern branch.
3. `[[ $ip =~ ^192\.168\.1\.[0-6][0-9]$ ]]` — flag servers in that IP range.
4. Combine `&&` to find servers that are running AND uptime_days > 100.

---

## Round 4 — break/continue, Fast

Build `bash-lab/scripts/challenge-filter.sh`.

1. `continue` past stopped/failed, print only running servers.
2. `break` the instant cpu_load exceeds 90 — confirm it stops at `cache02`.
3. Nested loop where `break` only kills the inner loop — then fix to `break 2` and confirm the difference in output.


---

## Break/Fix Gauntlet

Fix all 8. Write only the corrected line, no explanation needed unless asked.

1.
```bash
for ((i=1; i<10; i++)); do echo "$i"; done
```
Missing one number at the end. Fix it.

2.
```bash
count=0
while [ "$count" -lt 5 ]; do echo "$count"; done
```
Infinite. Fix it.

3.
```bash
case "$service" in
  nginx)
    echo "web"
  postgres)
    echo "data"
    ;;
esac
```
Fall-through. Fix it.

4.
```bash
result="ok"
set_result() { result="critical"; }
set_result
echo "$result"
```
Leaks. Fix it.

5.
```bash
for outer in a b c; do
  for inner in 1 2 3; do
    [ "$inner" -eq 2 ] && break
    echo "$outer-$inner"
  done
done
```
Should stop everything at inner=2. Doesn't. Fix it.

6.
```bash
name="proxy02"
[ "$name" == proxy* ] && echo "match"
```
Unreliable. Fix the bracket.

7.
```bash
check() {
  [ "$1" == "running" ] && return "ok"
}
result=$(check "running")
echo "$result"
```
`result` is empty. Fix the function.

8.
```bash
for s in $(cat bash-lab/data/fleet.txt); do
  echo "$s"
done
```
Breaks the comma-separated lines apart wrong. Fix it to use the correct loop pattern for this file.

---

## Pass Criteria

- All 4 rounds run clean, first try or after your own fix
- `final-fleet-report.sh` built cold, breaks on `cache02` correctly, exits `1`
- All 8 break/fix items fixed with the corrected line shown
- You can rebuild `final-fleet-report.sh` again tomorrow without looking at today's copy

If `final-fleet-report.sh` doesn't work cleanly, repeat the lab.