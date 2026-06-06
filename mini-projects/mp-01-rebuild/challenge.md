cat > challenge.md <<'EOF'
# Challenge

## Challenge: Warning Summary Script

Build a second small script called `warning_summary.sh`.

The goal is to prove I understand the core logic from the incident report project without copying the original script.

## Requirements 

- [ ] Read `logs/app.log`
- [ ] Read `logs/auth.log`
- [ ] Detect WARNING lines only
- [ ] Search case-insensitively
- [ ] Count total WARNING lines
- [ ] Create a timestamped report inside `reports/`
- [ ] If no WARNING lines are found, write `No warnings found`
- [ ] If a log file is missing, write an error log inside `errors/`
- [ ] Print a useful message to the terminal

## Skills Tested

- Bash variables
- Command substitution
- File checks with `-f`
- `if` statements
- `grep`
- `wc -l`
- Redirection
- Quoting variables
- `mkdir -p`
- Error handling

## Pass Criteria

I pass this challenge if I can build the script, run it, explain each part, and generate a warning summary report without needing the full solution.
EOF
