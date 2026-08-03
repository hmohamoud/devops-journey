# Notes — Lab 09: Loops, Functions & Conditionals

---

## 1. Loop Fundamentals

Each loop iteration of `while IFS=, read -r ...` reads **one full line at a time**.

This is why, if you want to print one variable in full (all values) before moving to the next variable, you need **two separate loops** (or two arrays built in a single pass) — you cannot get "all of column A, then all of column B" out of a single straight-through loop, because each pass only ever has access to one line's worth of data at a time.

---

## 2. `printf` vs `echo`

### `printf` format string pieces

| Piece | Meaning |
|---|---|
| `%s` | slot #1 — "put a string here" |
| `:` | literal text — prints exactly as-is |
| `%s` | slot #2 — "put another string here" |
| `%%` | literal `%` character — because `%` normally means "here comes a slot," you have to write it twice to print an actual `%` |
| `\n` | newline — `printf` does **not** auto-add one, you have to ask for it yourself |

### Key difference

- `echo` automatically puts a newline at the end of whatever you print — you never have to ask for it, it's built in.
- `printf` is the opposite — nothing is added automatically, including the newline. If you want one, you write `\n` yourself.

---

## 3. Exit Codes

**`0` always means success. Any non-zero value means failure.**

`if` never reads "true/false" directly — it always reads this exit code number.

---

## 4. Brackets — When to Use Them

**Rule of thumb:** brackets (`[ ]` or `[[ ]]`) are only for when you're **testing a value** — comparing strings, checking numbers, checking if a file exists.

When you're running an **actual command or function** and just want to know if it succeeded, no brackets — the command itself goes straight after `if`.

```bash
# Testing a value → brackets
if [ "$status" == "running" ]; then ... fi

# Running a command/function → no brackets
if check_status "running"; then ... fi
```

---

## 5. Passing Arguments to a Function

You call the function, then space-separate the arguments:

```bash
function_name "Hello" "Whatsup"
```

- The first argument passed is stored in `$1`
- The second argument passed is stored in `$2`
- The third argument passed is stored in `$3`
- ...and so on.

You can also store a function call's output in a variable — this is command substitution:

```bash
tier=$(cpu_tier "$cpu")
```

---

## 6. Function Definition Order — Define Before You Call

**The rule:** when calling or mentioning a function, the function's definition needs to appear **before** the line that calls it. Bash reads a script top to bottom, and it has to already know a function exists — because it already read the definition — before it can run a call to that function.

**This is INCORRECT — the function is called before it's defined:**

```bash
#!/bin/bash

is_running "running"

is_running() {
    if [ "$1" = "running" ]; then
        return 0
    else
        return 1
    fi
}
echo $?
```

At the point `is_running "running"` runs, Bash hasn't read the function definition yet — it doesn't exist as far as the script knows, so the call fails.

**This is CORRECT — the definition comes first, the call comes after:**

```bash
#!/bin/bash

is_running() {
    if [ "$1" = "running" ]; then
        return 0
    else
        return 1
    fi
}

is_running "running"

echo $?
```

Now, by the time `is_running "running"` runs, Bash has already read and registered the function definition above it, so the call works correctly.

**One-sentence rule to remember:** function definitions always go at the top (or at least earlier in the script than any line that calls them) — never call a function before Bash has had a chance to read its definition.

---

## 7. Global vs Local Variables

### Global variables

One variable, shared by the entire script. A function can reach out and change it, and that change is **permanent** — it's not a copy, it's the same variable everywhere.

```bash
x=5

change_it() {
    x=9        # no "local" — this touches the SAME x
}

change_it
echo "$x"      # prints: 9
```

### Local variables

A brand new, separate variable that only exists while the function is running. Even if a variable with the identical name exists outside, `local` makes them two completely unrelated variables that happen to share a name — like two different people both named "Sam." Nothing you do to the local one touches the outside one.

```bash
x=5

change_it() {
    local x=9   # "local" — this is a DIFFERENT x, trapped inside this function
}

change_it
echo "$x"       # prints: 5  ← unchanged, the "9" version never left the function
```

**And this part matters separately:** you cannot print a local variable from outside its function at all — not even to see it exist. Once the function ends, that variable is completely gone, like it was never created.

```bash
make_something() {
    local secret="hello"
}

make_something
echo "$secret"    # prints: nothing — $secret was never accessible out here, ever
```

### The one thing to remember, forever

- **No `local`** → same variable, shared everywhere, changes are permanent.
- **`local`** → a separate variable, trapped inside the function, dies when the function ends, and can never be read from outside — not before, not after.

---

## 8. `case` vs `if`/`elif`

**Same variable, multiple values → `case`.**
**Different checks entirely → `if`/`elif`.**

### When to use `case`

Use `case` when you're checking **one variable** against **multiple possibilities** — this is the same job an `elif` chain would otherwise be doing.

```bash
case "$service" in
    nginx|proxy*) tier="web" ;;
    postgres|redis) tier="data" ;;
    *) tier="other" ;;
esac
```

- `in` basically means `=`.
- `case` is doing the exact same job as `if` — just inside one pattern slot instead of chaining separate `[ ]` tests.
- Every branch is asking the exact same question: *"is `$service` equal to ___?"* Only the value being compared changes.

### When to use `if`/`elif`

Use `if`/`elif` when each branch is checking **something different**, not just a different value of the same thing.

| Pattern | Meaning |
|---|---|
| Attached to text (`proxy*`, `*.txt`) | "starts with / ends with this specific text, plus anything else" |
| Alone, as the entire pattern (`*)`) | "match literally anything / otherwise" — the fallback, same role as `else` |

### Order matters

In an `if`/`elif` chain, Bash checks **top to bottom** and stops at the **first match**. It never checks anything after that, even if a later branch would also technically be true.

---

## 9. `return` vs `echo`

**`return` is only for true/false/status codes.**

How to capture a true/false/status code:

```bash
check_status() {
    if [ "$1" == "running" ]; then
        return 0
    else
        return 1
    fi
}

if check_status "running"; then
    echo "status check passed"
else
    echo "status check failed"
fi
```

This replaces `if check_status "running"` with the exit code the function returned — in this case, `0`.

`if` treats `0` as **"true → run the `then` branch"** and anything non-zero (`1`, `2`, etc.) as **"false → run the `else` branch."**

If you want to hand back **actual data/text**, you need `echo`, and you capture it with `$()`:

```bash
check_status() {
    if [ "$1" == "running" ]; then
        echo "ok"
    fi
}

result=$(check_status "running")
echo "$result"
```

---

## Quick-Reference Summary

- `while IFS=, read -r ...` reads one line per iteration — two loops (or two arrays) needed to print "all of column A, then all of column B."
- `printf` needs an explicit `\n`; `echo` adds a newline automatically.
- Exit codes: `0` = success, non-zero = failure. This is what `if` actually checks.
- Brackets (`[ ]`/`[[ ]]`) are for testing values only; commands/functions go straight after `if` with no brackets.
- Function arguments: `$1`, `$2`, `$3`... in call order; capture output with `result=$(function_name args)`.
- A function must be **defined before** it's called — Bash reads top to bottom, and a call to a function it hasn't read yet will fail.
- No `local` → variable is global, changes are permanent and visible everywhere.
- `local` → variable is scoped to the function, cannot be read outside it, ever.
- `case` → one variable checked against many known values/patterns.
- `if`/`elif` → different kinds of checks; stops at the first match, top to bottom.
- `return` → status codes only (0–255), captured with `if function_name` or `$?`.
- `echo` → actual data, captured with `$()`.