# Lab 09 — Loops, Functions & Conditionals

## Objective

Build the muscle memory for the patterns you'll actually type on the job, over and over: reading files line by line, writing functions that validate and exit correctly, and branching on real conditions. Less explaining, more typing.

---

## Environment Setup

```text
bash-lab/
├── data/
│   └── fleet.txt
├── scripts/
└── output/
```

`bash-lab/data/fleet.txt`:

```text
web01,192.168.1.10,running,8080,nginx,42,120
web02,192.168.1.11,running,8080,nginx,55,120
web03,192.168.1.12,stopped,8080,nginx,0,0
db01,192.168.1.20,running,5432,postgres,68,300
db02,192.168.1.21,failed,5432,postgres,0,0
cache01,192.168.1.30,running,6379,redis,30,90
cache02,192.168.1.31,running,6379,redis,97,90
auth01,192.168.1.40,running,9000,auth-service,45,60
auth02,192.168.1.41,stopped,9000,auth-service,0,0
worker01,192.168.1.50,running,7000,job-worker,60,15
worker02,192.168.1.51,running,7000,job-worker,72,15
worker03,192.168.1.52,failed,7000,job-worker,0,0
proxy01,192.168.1.60,running,443,nginx,25,200
proxy02,192.168.1.61,running,443,nginx,28,200
monitor01,192.168.1.70,running,9090,prometheus,15,365
```

Fields: `name,ip,status,port,service,cpu_load,uptime_days`

---

## Block 1 — Loops You'll Actually Use (do all of these, back to back)

Build each as its own tiny script. No essay answers — just build it, run it, confirm it works, move on.

1. `while IFS=, read -r name ip status port service cpu uptime; do ...; done < fleet.txt` — print every server name and status one after the other e.g. web01 running etc.
2. `while IFS=, read -r name ip status port service cpu uptime; do ...; done < fleet.txt` — print every server name one go and then print all status one go web 1 web 02 web 03 ... running etc.
3. Same loop, but only print servers where `status == "running"`.
4. Same loop, but print only `name` and `cpu_load`, formatted as `name: cpu%`.
5. `for f in bash-lab/data/*.txt; do echo "$f"; done` — loop over files by glob.
6. Build an array from `fleet.txt`'s server names (`servers+=("$name")` inside a `while read` loop), then `for s in "${servers[@]}"; do echo "$s"; done`.
7. Loop through `fleet.txt` and count how many servers are `running` vs not, using a counter variable incremented inside the loop.

Do all 6. Don't skip any — this is the loop you will write constantly: `while IFS=, read -r ... done < file`.

---

## Block 2 — Functions You'll Actually Use

Build these as functions inside one script, `bash-lab/scripts/fleet-functions.sh`. Call each one and confirm output before moving to the next.

1. `is_running()` — takes a status string as `$1`, returns `0` if `"running"`, `1` otherwise. Call it in an `if is_running "$status"; then ... fi`.
2. `cpu_tier()` — takes a cpu_load number as `$1`, `local`-scopes its result variable, `echo`s back `low`/`medium`/`high`/`critical` based on thresholds (<40 / 40-69 / 70-89 / 90+). Capture it with `tier=$(cpu_tier "$cpu")`.
3. `validate_args()` — takes `$#` and a required count as arguments, prints a usage message and returns `2` if the count doesn't match.
4. Write a function called `log_line` that takes one message as input, and prints that message with the current time stuck `$(date +%H:%M:%S)` on the front of it — so instead of just printing "server check started," it prints something like "14:32:07 server check started."
5. Prove `cpu_tier()`'s internal variable doesn't leak: call it, then `echo "$result"` (or whatever you named it) outside the function and confirm it's empty.
6. Write the same function again without `local`, call it, and confirm the variable now **does** leak. One line: why does that matter in a 200-line script?

Run all 6, in order, in the same script file.

---

## Block 3 — Conditionals You'll Actually Use

Build `bash-lab/scripts/fleet-conditions.sh`.

1. Loop through `fleet.txt`. For each server, `if [ "$status" == "running" ]; then ... else ... fi` — print "UP" or "DOWN".
2. Same loop, add `elif` for a third status value (`failed`) so you get three distinct outputs, not just two.
3. Use `case "$service" in nginx|proxy*) ... ; postgres|redis) ... ; *) ... ; esac` to bucket every service into web/data/other. Do this for all 15 lines.
4. Use `[[ $ip =~ ^192\.168\.1\.(1|2)[0-9]$ ]]` to flag servers in the `.10–.29` range specifically — this is the one regex pattern worth knowing cold, everything else is a bonus.
5. Combine two conditions with `&&` in a single `if` to find servers that are BOTH `running` AND have `cpu_load` over `50`.

Run all 5 against the real file, not fake data.

---

## Block 4 — break/continue in Real Filtering (this is what you'll actually do with them)

Build `bash-lab/scripts/fleet-filter.sh`.

1. Go through every server in `fleet.txt` one at a time. If a server's status is stopped or failed, skip it immediately using continue — don't print anything for it, just move straight to the next one. Only print the servers whose status is running.
2. Same loop, `break` the instant you hit a server with `cpu_load` over `90` — print an alert and stop. (It should stop at `cache02`.)
3. Write an outer for loop over 3 service names (e.g. nginx postgres redis) Inside it, write an inner for loop over disk memory cpu Inside the inner loop, add a break somewhere (e.g. when it hits memory). Run the script. Look at the output — check whether the outer loop still processed all 3 services, even though the inner loop stopped early each time

Run all 4. Confirm outputs by eye each time — don't just assume it worked.

---

## Capstone Build — Fleet Health Reporter

Build `bash-lab/scripts/fleet-report.sh`. This is where Blocks 1–4 combine into one real tool.

**Requirements:**

1. Accepts zero arguments — validate this with your `validate_args()` pattern from Block 2. (No args needed here, but structure it so adding a filter argument later would be trivial.)
2. `while IFS=, read -r ...` loop through `fleet.txt`.
3. `continue` past `stopped`/`failed` servers.
4. For each running server: call `cpu_tier()` to get its load tier, use a `case` statement to get its service tier.
5. Print one line per server: `name | service_tier | cpu_tier`
6. `break` the loop and print a clear alert the moment a `critical` tier is hit — no further servers processed after that.
7. At the end, print a total count of servers actually processed.
8. Exit `0` if it completes without hitting critical, exit `1` if it had to break early.

Run it. Confirm:
- `cache02` triggers the break (it's the planted `cpu_load=97`)
- Nothing after `cache02` in the file gets processed
- `echo $?` shows `1` because it broke early

Then comment out `cache02`'s row temporarily, rerun, confirm it processes everything and exits `0`. Restore the row after.

---

## Break/Fix — Fix All of These, No Skipping

### 1
```bash
for ((i=0; i<=5; i++)); do echo "$i"; done
```
Meant to print exactly 5 numbers. Fix it.

### 2
```bash
i=10
until [ "$i" -eq 0 ]; do echo "$i"; done
```
Never stops. Fix it.

### 3
```bash
case "$status" in
  running)
    echo "ok"
  stopped)
    echo "down"
    ;;
esac
```
Fall-through bug. Fix it.

### 4
```bash
tier="unset"
set_tier() { tier="web"; }
set_tier
echo "$tier"
```
Leaks. Fix it.

### 5
```bash
for outer in a b c; do
  for inner in 1 2 3; do
    if [ "$inner" -eq 2 ]; then break; fi
    echo "$outer-$inner"
  done
done
```
Was supposed to stop everything once `inner` hits 2. Doesn't. Fix it.

### 6
```bash
name="proxy02"
if [ "$name" == proxy* ]; then echo "match"; fi
```
Unreliable glob match. Fix the bracket.

### 7
```bash
check_status() {
  if [ "$1" == "running" ]; then return "ok"; fi
}
result=$(check_status "running")
echo "$result"
```
`result` is empty. Fix the function so it actually is useful.

---
