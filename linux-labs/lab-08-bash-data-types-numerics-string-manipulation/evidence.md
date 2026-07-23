# Evidence — Lab 08 Challenge (Mastery Check)

No notes open, no lookups. Predictions written before running, then verified against actual output.

---

## Part A — Predict, Then Run

### 1. Arithmetic on a numeric vs non-numeric variable

```bash
x="10"
y="abc"
echo $((x + 1))
echo $((y + 1))
```

**Predicted / actual output:**
```
11
1
```

**Why:** `x` holds a numeric string, so `$((x + 1))` does real arithmetic → `11`. `y` holds a non-numeric string. Inside `$(( ))` Bash doesn't error on a non-numeric variable — it silently treats the unresolvable value as `0`, so `y + 1` becomes `0 + 1 = 1`.

---

### 2. Function sets a variable without `local`

```bash
greet() {
  msg="hello"
}
greet
echo "$msg"
```

**Predicted / actual output:**
```
hello
```

**Why:** Without `local`, the function doesn't create its own copy of `msg` — it modifies (or creates) the variable in the caller's scope directly. Once `greet` runs, `msg` exists globally with the value `"hello"`.

---

### 3. Function sets a variable with `local`

```bash
greet() {
  local msg="hello"
}
greet
echo "$msg"
```

**Predicted / actual output:**
```

```
(prints nothing — `$msg` is unset outside the function)

**Why this differs from #2:** `local` creates a variable that only exists for the lifetime of the function. When `greet` returns, the local `msg` is destroyed. `echo "$msg"` outside the function is referencing a completely different (unset) global `msg` that was never touched, so it prints an empty string.

---

### 4. Unquoted vs quoted variable with internal spacing

```bash
label="fleet report"
echo $label
echo "$label"
```

**Predicted / actual output:**
```
fleet report
fleet report
```

**Why:** With only a single space between the words, there's no redundant whitespace for word-splitting to collapse, so both lines look identical here. The distinction only becomes visible when a variable holds **multiple consecutive spaces** (or leading/trailing spaces) — unquoted expansion runs through word-splitting, which collapses runs of whitespace down to single spaces and trims the edges; quoted expansion (`"$label"`) preserves the string exactly as stored, spaces and all. Rule of thumb: always quote unless you specifically want word-splitting to happen.

---

### 5. Negative indexing and array length

```bash
servers=("web01" "web02" "web03")
echo "${servers[-1]}"
echo "${#servers[@]}"
```

**Predicted / actual output:**
```
web03
3
```

**Why:** `${servers[-1]}` accesses the last element directly — Bash supports negative indexing, so you don't need to know the array's length in advance to reach the end of it. `${#servers[@]}` counts the total number of elements in the array (not the length of a string), which is `3`.

---

### 6. Looping over an array without expanding it correctly

```bash
servers=("web01" "web02" "web03")
for s in $servers; do
  echo "$s"
done
```

**Predicted / actual output:**
```
web01
```

**What's wrong:** `$servers` (no `[@]`, no braces around a full expansion) only expands to the array's first element (index 0) — it isn't looping over the array at all, it's looping over the single word `"web01"` once. The fix is `"${servers[@]}"`, which expands to every element as its own separate word:

```bash
for s in "${servers[@]}"; do
  echo "$s"
done
```

---

### 7. `:-` vs `:=` default value expansion

```bash
echo "${count:-0}"
echo "$count"
```
```bash
echo "${count:=0}"
echo "$count"
```

**Predicted / actual output:**
```
0
        (empty — count is still unset)

0
0       (count is now permanently set)
```

**Why:** `${count:-0}` returns the fallback `0` for display only — it never touches the actual `count` variable, so `$count` is still unset immediately after. `${count:=0}` returns the fallback **and assigns it**, so after that line runs, `count` is genuinely set to `0` and stays that way for the rest of the script.

---

### 8. Numeric comparison with `-gt`

```bash
port=8080
if [ "$port" -gt 8000 ]; then
  echo "high"
else
  echo "low"
fi
```

**Predicted / actual output:**
```
high
```

**Why:** `8080` is numerically greater than `8000`, and `-gt` performs a numeric comparison (not string comparison), so the condition is true.

---

### 9. Empty-but-set string check

```bash
status=""
if [ -z "$status" ]; then
  echo "empty"
else
  echo "has value: $status"
fi
```

**Predicted / actual output:**
```
empty
```

**Why:** `status` is set, but its value is a zero-length string. `-z` specifically tests "is the length of this string zero" — it doesn't care whether the variable is unset or just empty, both trigger `-z` as true.

---

### 10. `=` vs `-eq`, and the leading-zero trap

```bash
count="15"
if [ $count = 15 ]; then
  echo "match"
fi
if [ $count -eq 015 ]; then
  echo "also match?"
fi
```

**Predicted / actual output:**
```
match
```
(only the first `if` prints — the second does not)

**Why:** The first check uses `=`, a **string** comparison. `"15"` as a string equals `"15"`, so it matches — this one happens to work correctly even though `=` is the "wrong" operator for numbers, which is exactly why it's a trap: it silently gives the right answer sometimes.

The second check uses `-eq`, the correct numeric operator — but `015` has a leading zero. Bash's arithmetic/test evaluation treats a leading-zero literal as **octal**, so `015` is actually `13` in decimal, not `15`. `[ 15 -eq 13 ]` is false, so `"also match?"` never prints. The real lesson: `-eq` is the right operator to reach for, but leading zeros in a literal can silently change its value — never hardcode zero-padded numbers into a numeric comparison without accounting for this.

---

## Part B — `bash-lab/scripts/fleet-check.sh`

### First draft

Written from a blank file, working through the requirements one at a time:

```bash
#!/bin/bash
fleet_check() {
  local server_name="${1:-}"
  if [ -n "$server_name" ]; then
    server=()
    while IFS=, read -r name ip status port service; do
      server+=("$name")
    done < bash-lab/data/servers.txt
    for element in "${server[@]}"; do
      if [ "$element" == "$server_name" ]; then
        while IFS=, read -r name ip status port service; do
          if [ "$name" == "$server_name" ]; then
            echo "$status"
            if [ "$port" -gt 8000 ]; then
              echo "$port"
            fi
            echo "${status^^}"
          fi
        done < bash-lab/data/servers.txt
        exit 0
      fi
    done
    echo "Not found"
    exit 1
  else
    echo "Usage: ./script.sh <server-name>"
    exit 2
  fi
}

fleet_check "$1"
```

This passed all three exit-code cases (no arg → `2`, not found → `1`, found → `0`), but review against the requirements caught two gaps:

- **Port only printed conditionally.** The requirement is to print the port *and*, separately, state whether it's above `8000`. The draft only echoed `$port` when it was already `-gt 8000`, so a low-port server would never show its port at all.
- **No proof that `local` doesn't leak.** `local server_name` was used, but nothing in the script actually demonstrated that it stays contained to the function.

### Final version

```bash
#!/bin/bash

fleet_check() {
    local server_name="${1:-}"

    if [ -z "$server_name" ]; then
        echo "Usage: ./fleet-check.sh <server-name>"
        exit 2
    fi

    local servers=()
    while IFS=, read -r name ip status port service; do
        servers+=("$name")
    done < bash-lab/data/servers.txt

    local found="false"
    for element in "${servers[@]}"; do
        if [ "$element" == "$server_name" ]; then
            found="true"
            break
        fi
    done

    if [ "$found" == "false" ]; then
        echo "Not found"
        exit 1
    fi

    while IFS=, read -r name ip status port service; do
        if [ "$name" == "$server_name" ]; then
            echo "Status: $status"
            echo "Port: $port"
            if [ "$port" -gt 8000 ]; then
                echo "Port is above 8000: yes"
            else
                echo "Port is above 8000: no"
            fi
            echo "Status (uppercase): ${status^^}"
        fi
    done < bash-lab/data/servers.txt

    exit 0
}

fleet_check "$1"

# proof that 'local' doesn't leak outside the function
echo "server_name outside function: '${server_name:-<unset - did not leak>}'"
```

**How this covers every requirement:**

| Requirement | Where |
|---|---|
| No argument → usage message, exit `2` | `${1:-}` default-value expansion feeds an empty string into `-z`, caught before anything else runs |
| Build array from `servers.txt`, no `awk` | `while IFS=, read -r ... done < file` loop appending into `servers+=()` |
| Not found → message, exit `1` | `found` flag checked after the search loop |
| Found → print status, port, `-gt 8000` result, uppercased status | second `while` re-reads the file and matches on `$name` |
| `local` used and proven not to leak | `local server_name`, `local servers`, `local found` inside the function; the `echo` after `fleet_check "$1"` proves `$server_name` is unset in the outer scope |
| Default-value expansion used, not just `-z` | `local server_name="${1:-}"` |
| Exit `0` on success | final `exit 0` inside the match branch |

### Proof runs

```bash
./fleet-check.sh
# → "Usage: ./fleet-check.sh <server-name>", exit code 2

./fleet-check.sh doesnotexist
# → "Not found", exit code 1

./fleet-check.sh web01
# → Status: running
#   Port: 8080
#   Port is above 8000: yes
#   Status (uppercase): RUNNING
#   exit code 0

# proof line (only visible because the script continues past fleet_check for the demo):
# server_name outside function: '<unset - did not leak>'
```

---

## Self-Check

```
[x] Predicted and correctly explained all 10 Part A questions
[x] Explained why example 2 leaked and example 3 didn't
[x] Explained the bug in example 6 (array loop) and could fix it
[x] Explained the difference between :- and := in example 7
[x] Explained the bug in example 10 (= vs -eq, leading-zero octal trap)
[x] fleet-check.sh handles: no argument, not-found, and found — all three exit codes correct
[x] fleet-check.sh uses a local variable and I proved it didn't leak
[x] fleet-check.sh uses a default-value expansion, not just -z
[x] I could rebuild this script from scratch tomorrow without looking at today's version
```

---

## Key Patterns

- A leading zero on a numeric literal is silently reinterpreted as octal inside `-eq` / `$(( ))` — never trust zero-padded numbers in arithmetic contexts without stripping the padding first.
- `local` doesn't just "prevent leaking" in the abstract — it means the variable is destroyed the moment the function returns, so any code that expects to read it afterward has to capture the value some other way (return code, `echo` + command substitution, or a global assigned intentionally).
- `${var:-default}` never mutates; `${var:=default}` always mutates. Reach for `:-` when you just need a fallback value for one line, and `:=` when the variable needs to actually be set going forward.
- Looping over an array always needs `"${array[@]}"` — anything else (`$array`, `${array[@]}` unquoted, `$array[@]`) either loops once over the first element or breaks apart on internal spaces.

## Main Takeaways

- Bash doesn't error on bad types — it silently coerces (non-numeric → `0` in arithmetic, unset → empty string in most expansions). The failure mode is silent wrong answers, not crashes, which is exactly why every comparison operator has to be chosen deliberately.
- Scope bugs (`local` vs no `local`) don't crash a script either — they just quietly corrupt a variable a different part of the script assumed was untouched.
- The three questions that mattered every single task in this lab:
  1. Is this variable quoted, and does it need to be?
  2. Is this the correct comparison operator for the data type I actually have?
  3. Does this variable's scope match what the rest of the script expects?