```bash
#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/../config/toolkit.conf"
source "$(dirname "$0")/../lib/common.sh"

trap 'echo "System audit complete."' EXIT
trap 'log_error "system-audit.sh failed at line $LINENO"' ERR

running_count=$(pgrep -f "toolkit.sh" | wc -l)

if [ "$running_count" -gt 1 ]; then
    log_error "Another toolkit process appears to be running"
    exit 1
fi

if [ -d "config" ]; then
    config_status="ok"
else
    config_status="missing"
fi

require_dir "config"

if [ -d "lib" ]; then
    lib_status="ok"
else
    lib_status="missing"
fi

require_dir "lib"

if [ -d "data" ]; then
    data_status="ok"
else
    data_status="missing"
fi

require_dir "data"

if [ -d "scripts" ]; then
    scripts_status="ok"
else
    scripts_status="missing"
fi

require_dir "scripts"

if [ -d "$REPORT_DIR" ]; then
    report_status="ok"
else
    report_status="missing"
fi

require_dir "$REPORT_DIR"

if [ -d "$ERROR_DIR" ]; then
    error_status="ok"
else
    error_status="missing"
fi

require_dir "$ERROR_DIR"

if [ -d "$LOG_DIR" ]; then
    log_status="ok"
else
    log_status="missing"
fi

require_dir "$LOG_DIR"

if [ -d "$(pwd)/scripts" ]; then
    echo "Absolute path check: OK"
fi

if [ -d "./scripts" ]; then
    echo "Relative path check: OK"
fi

non_executable=()

for f in scripts/*.sh lib/*.sh; do
    if [ ! -x "$f" ]; then
        non_executable+=("$f")
    fi
done

file_inventory=$(find . -name "*.sh" -o -name "*.conf" -o -name "*.log")

report_file="$REPORT_DIR/system-audit-report-$(timestamp).log"

echo "System Audit Report" > "$report_file"
echo "Generated: $(timestamp)" >> "$report_file"
echo "Config directory: $config_status" >> "$report_file"
echo "Lib directory: $lib_status" >> "$report_file"
echo "Data directory: $data_status" >> "$report_file"
echo "Scripts directory: $scripts_status" >> "$report_file"
echo "Report directory: $report_status" >> "$report_file"
echo "Error directory: $error_status" >> "$report_file"
echo "Log directory: $log_status" >> "$report_file"

echo "" >> "$report_file"

if [ -z "$non_executable" ]; then
    echo "All scripts executable" >> "$report_file"
else
    echo "NOT EXECUTABLE:" >> "$report_file"

    for element in "${non_executable[@]}"; do
        echo "$element" >> "$report_file"
    done
fi

echo "" >> "$report_file"

echo "File Inventory: $file_inventory" >> "$report_file"

if [ "$config_status" == "Missing" ] || \
   [ "$lib_status" == "Missing" ] || \
   [ "$data_status" == "Missing" ] || \
   [ "$scripts_status" == "Missing" ] || \
   [ "$report_status" == "Missing" ] || \
   [ "$error_status" == "Missing" ] || \
   [ "$log_status" == "Missing" ] || \
   [ "${#non_executable[@]}" -gt 0 ]; then
    exit 1
else
    exit 0
fi
```
