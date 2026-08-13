# Lab 12 — Challenge (Focused Mastery Check)

No notes. No copying. Commands aren't given to you here — you produce them. If you're rereading a command to remember its flags, that's a signal, not a failure; go redrill that spot in instructions.md after.

---

## Round 1 — Fast Execution (muscle memory, timed in your head)

Don't explain, just do these back to back:

1. Create a user with a home directory, set its password, confirm identity.
2. Create a group. Add that user to it without wiping any group it's already in.
3. Prove membership two different ways — from the group's side and from the user's side.
4. Set a file's owner and group in a single command. Then, separately, change only its group.
5. List what you're allowed to run as root. Then open a root shell, confirm who you are, leave it.
6. Delete a user without touching its home directory. Then delete a different user and remove its home directory too. Prove the difference on disk.

---

## Round 2 — Judgment Under Pressure

For each situation, state the correct command (and flag, if relevant) before you type anything. Getting the command right after guessing wrong doesn't count.

1. You're just checking whether a config file exists and what's in it. It's not permission-restricted. What do you run — with or without `sudo`?
2. Same question, but now it's `/etc/shadow`. What changed, and why?
3. A user is already in two groups. You need to add a third without losing the other two. Name the flag. Now name the flag that would silently wipe the other two — and predict, before running it, exactly what `groups` will show afterward if you use the wrong one.
4. You need to change who owns a file. Can you do it as the file's regular owner, or does it require elevated privileges? Now answer the same question for changing the file's *permission bits* instead. The answers differ — say why.
5. You want a full member list of a group. You want a full group list for one user. Which command answers which — and which "direction" does each one read in?
6. You need to run a single command as another user and immediately be back to yourself, no lingering session. Name the command. Now name the different command you'd use if you needed to actually operate as that user for a while.

---

## Round 3 — Diagnose the Symptom

You're given a broken scenario. Run the three-step process (directory → file → ownership) out loud, then fix it. No skipping to the fix.

1. **Symptom:** `cat file.txt` inside a directory returns "permission denied," but `ls -l file.txt` shows `-rw-r--r--` — wide open. What's actually blocking you, and where do you look first?
2. **Symptom:** You can `cd` into a directory and `ls` it fine, but `cat somefile` inside it fails. The directory's permissions are fine. What's the next thing you check, and what are you comparing it against?
3. **Symptom:** A file is owned by `root:root`, mode `600`. You have `sudo`. What's the correct fix — and what's the fix you should *not* reach for, even though it would also "work"?
4. **Symptom:** You just ran `usermod -aG` to add yourself to a new group. `groups` in your current terminal doesn't show it. Is anything actually broken? What's the real fix?
5. **Symptom:** You're the owner of a file, and it's also `rwx` for your group and for others. You still can't do the thing you're trying to do. Walk through why "owner" being the most permissive column doesn't automatically mean you get the widest access — what actually determines which column applies to you?

---

## Round 4 — Explain It Cold (rapid fire, one sentence each)

1. Why is the password field in `/etc/passwd` just `x`?
2. Why does a directory need `x` specifically — not `r`, not `w` — to let you read a file inside it?
3. State the ownership hierarchy and the rule for which column applies to you.
4. Why can a file's owner run `chmod` on their own file, but not `chown`?
5. What's the actual functional difference between `sudo somecommand` and `sudo -i`?
6. What does checking `$EUID -ne 0` actually verify, and why is it better than checking the output of `whoami`?

---

## Round 5 — Capstone, Cold, No Notes

Build this straight through. If you hit a permission error anywhere in the process, that's not a failure — run the three-step flow and fix it as part of the build, don't restart.

1. Create a service-style setup: a user with a home directory and a group, correctly linked (no group wipeouts).
2. Prove the link from both directions.
3. Create a directory this user should own. Set ownership (owner + group, one command). Then, separately, correct only the group with the dedicated command.
4. Deliberately break access to it (missing execute bit), diagnose it with the full three-step process, fix it.
5. Confirm — from `id`, not from memory — exactly which permission column would apply to a totally unrelated third user trying to access that same directory.
6. Write the root-check guard block from memory. Prove it blocks and passes correctly.
7. Tear down the user and its home directory in one command.

---

## Pass Criteria

- Round 1 done with zero hesitation on any command or flag
- Round 2 answered *before* typing, not corrected after a wrong guess
- Round 3 diagnosed in the full three-step order every time, no shortcutting to the fix
- Round 4 answered in one sentence each, no re-reading notes
- Capstone built once, cleanly, start to finish, no notes open

If any round needed a peek at instructions.md, that's the part to redrill — not a pass.