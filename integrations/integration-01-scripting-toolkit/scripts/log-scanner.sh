#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/../config/toolkit.conf"
source "$(dirname "$0")/../lib/common.sh"
report_file="$REPORT_DIR/log-scan-report-$(timestamp).log"
error_count=0
warning_count=0

trap 'echo "Log scan complete. Errors: $error_count, Warnings: $warning_count"' EXIT
trap 'log_error "log-scanner.sh failed at line $LINENO"' ERR

if ! require_file "$LOG_FILE"; then 
	exit 1 
fi

if [ ! -s "$LOG_FILE" ]; then
	exit 1
fi

echo "Log scanner report" > "$report_file"
echo "Generated: $(timestamp)" >> "$report_file"
echo "File Scanned: $LOG_FILE" >> "$report_file"
e_error=$(grep -i "ERROR" "$LOG_FILE" || true) 
e_warning=$(grep -i "WARNING" "$LOG_FILE" || true)
error_count=$(grep -ic "ERROR" "$LOG_FILE")
echo "ERROR COUNT: $error_count" >> "$report_file"
warning_count=$(grep -ic "WARNING" "$LOG_FILE") 
echo "WARNING COUNT: $warning_count" >> "$report_file"
most_common=$(grep -iE "ERROR|WARNING" "$LOG_FILE" | sort | uniq -c | sort -nr | head -1 || true)
echo "$most_common" >> "$report_file"

if [ "$error_count" -eq 0 ] && [ "$warning_count" -eq 0 ]; then
	echo "No errors or warnings found" >> "$report_file"
else
	echo "$e_error" >> "$report_file"
	echo "$e_warning" >> "$report_file"
fi
exit 0