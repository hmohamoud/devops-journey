#!/bin/bash
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
report_file="process-lab/output/health-snapshot-$timestamp.txt"
uptis=$(uptime)
mem=$(free -h)
dis=$(df -h)
cp=$(ps aux --sort=-%cpu | head -n 6)
mu=$(ps aux --sort=-%mem | head -n 6)
echo "Report title $timestamp" > "$report_file"
echo "System uptime" >> "$report_file"
echo ""  >> "$report_file"
echo "$uptis"  >> "$report_file"
echo "Memory usage"  >> "$report_file"
echo ""  >> "$report_file"
echo "$mem"  >> "$report_file"
echo "Disk Usage"  >> "$report_file"
echo ""  >> "$report_file"
echo "$dis"  >> "$report_file"
echo ""  >> "$report_file"
echo "TOP 5 processes by CPU Usage"  >> "$report_file"
echo ""  >> "$report_file"
echo "$cp"  >> "$report_file"
echo "Top 5 processes by Memory usage"  >> "$report_file"
echo ""  >> "$report_file"
echo "$mu"  >> "$report_file"

echo "Report was saved to $report_file"



