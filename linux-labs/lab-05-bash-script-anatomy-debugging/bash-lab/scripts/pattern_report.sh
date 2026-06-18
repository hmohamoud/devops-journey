#!/bin/bash
file=$1
count=$#
pattern=$2
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
if [ "$count" -ne 2 ]; then
	echo "Error: expected 2 arguments"
	echo "Usage: ./pattern_report.sh FILE PATTERN"
	exit 2
fi

if [ ! -f "$file" ]; then 
	echo "Missing file: $file"
	exit 1
fi

mkdir -p bash-lab/output
mkdir -p bash-lab/errors

matching_count=$(grep -i "$pattern" "$file" | wc -l)

echo "Pattern Report" > "bash-lab/output/pattern-report-$timestamp.txt"
echo "Generated: $timestamp" >> "bash-lab/output/pattern-report-$timestamp.txt"
echo "File scanned: $file" >> "bash-lab/output/pattern-report-$timestamp.txt"
echo "Pattern searched: $pattern " >> "bash-lab/output/pattern-report-$timestamp.txt"
echo "Match count: $matching_count" >> "bash-lab/output/pattern-report-$timestamp.txt"
echo "Report written to: bash-lab/output/pattern-report-$timestamp.txt"

if [ "$matching_count" -gt 0 ]; then
	grep -i "$pattern" "$file" >> "bash-lab/output/pattern-report-$timestamp.txt"
else
	echo "No matches found" >> "bash-lab/output/pattern-report-$timestamp.txt"
fi
exit 0
