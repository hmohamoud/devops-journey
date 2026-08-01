#!/bin/bash

# --- Requirement 1: validate zero arguments ---
validate_args() {
    local actual="$1"
    local required="$2"
    if [ "$actual" -ne "$required" ]; then
        echo "Usage: expected $required argument(s), got $actual"
        return 2
    fi
}

if ! validate_args "$#" 0; then
    exit 2
fi

# --- Requirement 4: cpu tier function ---
cpu_tier() {
    if [ "$1" -lt 40 ]; then
        echo "low"
    elif [ "$1" -lt 70 ]; then
        echo "medium"
    elif [ "$1" -lt 90 ]; then
        echo "high"
    else
        echo "critical"
    fi
}

# counter for requirement 7
processed=0
# flag for requirement 8
broke_early=false

# --- Requirement 2: main loop ---
while IFS=, read -r name ip status port service cpu uptime; do

    # --- Requirement 3: skip stopped/failed ---
    if [ "$status" == "stopped" ] || [ "$status" == "failed" ]; then
        continue
    fi

    # --- Requirement 4: get cpu tier ---
    tier=$(cpu_tier "$cpu")

    # --- Requirement 4: get service tier ---
    case "$service" in
        nginx|proxy*) service_tier="web" ;;
        postgres|redis) service_tier="data" ;;
        *) service_tier="other" ;;
    esac

    # --- Requirement 6: break on critical, BEFORE printing the normal line ---
    if [ "$tier" == "critical" ]; then
        echo "ALERT: $name has critical CPU load ($cpu%) — stopping scan"
        broke_early=true
        break
    fi

    # --- Requirement 5: print the summary line ---
    echo "$name | $service_tier | $tier"

    # --- Requirement 7: increment processed count ---
    processed=$((processed + 1))

done < bash-lab/data/fleet.txt

# --- Requirement 7: print total processed ---
echo "Total servers processed: $processed"

# --- Requirement 8: correct exit code ---
if [ "$broke_early" == "true" ]; then
    exit 1
else
    exit 0
fi