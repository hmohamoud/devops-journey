# Mini Project 1: Automated Incident Report System

## What I'm Building

I am building a Bash incident report script that scans sample log files, detects ERROR and WARNING events, and generates a readable incident report.
The project will use log files from the `logs/` directory as input and create a report inside the `reports/` directory as output.

## Why

Application logs can contain many lines, which makes it slow to manually find important errors and warnings.
This project helps practise how a junior DevOps, SRE, cloud, or platform engineer could use Linux tools to filter logs, identify useful incident information, and create a report automatically.

## Rules

- Use Bash only.
- Use only commands and skills learned from the completed Linux labs.
- Do not use Python, Docker, AWS, Terraform, Kubernetes, or external tools.
- Design the project before writing the script.
- Test commands manually before adding them to the script.
- Document mistakes, tests, and fixes in `evidence.md`.
- Write `README.md` last after the project works.
- The `logs/` files are inputs.
- The `reports/` and `errors/` folders are output locations.
- Do not manually create the final report file; the script should create it.

## Requirements

- [ ] Read log files from the `logs/` directory.
- [ ] Scan `logs/app.log`.
- [ ] Scan `logs/auth.log`.
- [ ] Detect ERROR lines.
- [ ] Detect WARNING lines.
- [ ] Make detection case-insensitive.
- [ ] Count ERROR lines.
- [ ] Count WARNING lines.
- [ ] Include a timestamp in the report.
- [ ] Save the report inside the `reports/` directory.
- [ ] Send script-related errors to the `errors/` directory.
- [ ] Handle the case where no ERROR or WARNING lines are found.
- [ ] Test what happens when an input log file is missing.
- [ ] Test what happens when the script is run more than once.

## Success Criteria

The project is complete when:

- The script can scan the sample log files.
- The script creates a readable incident report in the `reports/` directory.
- The report contains ERROR and WARNING information only, not normal INFO lines.
- The report includes counts of ERROR and WARNING lines.
- The report includes a timestamp showing when it was generated.
- The script handles basic problems without confusing output.
- I can explain how the project works without needing to copy anyone else's answer.