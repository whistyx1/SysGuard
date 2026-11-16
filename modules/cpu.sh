#!/bin/bash

set -euo pipefail

show_cpu_info() {
    local user1 nice1 system1 idle1 iowait1 irq1 softirq1 steal1
    local user2 nice2 system2 idle2 iowait2 irq2 softirq2 steal2
    local total1 total2 idle_total1 idle_total2 total_delta idle_delta
    local cpu_usage logical_cores cpu_model

    if [[ ! -r /proc/stat || ! -r /proc/cpuinfo ]]; then
        printf 'Cannot read CPU information from /proc.\n' >&2
        return 1
    fi

    if ! read -r _ user1 nice1 system1 idle1 iowait1 irq1 softirq1 steal1 _ < /proc/stat; then
        printf 'Could not read CPU counters.\n' >&2
        return 1
    fi
    sleep 1
    if ! read -r _ user2 nice2 system2 idle2 iowait2 irq2 softirq2 steal2 _ < /proc/stat; then
        printf 'Could not read CPU counters.\n' >&2
        return 1
    fi

    for value in "$user1" "$nice1" "$system1" "$idle1" "$iowait1" "$irq1" "$softirq1" "$steal1" \
                 "$user2" "$nice2" "$system2" "$idle2" "$iowait2" "$irq2" "$softirq2" "$steal2"; do
        if [[ ! "$value" =~ ^[0-9]+$ ]]; then
            printf 'Invalid CPU counters in /proc/stat.\n' >&2
            return 1
        fi
    done

    total1=$((user1 + nice1 + system1 + idle1 + iowait1 + irq1 + softirq1 + steal1))
    total2=$((user2 + nice2 + system2 + idle2 + iowait2 + irq2 + softirq2 + steal2))
    idle_total1=$((idle1 + iowait1))
    idle_total2=$((idle2 + iowait2))
    total_delta=$((total2 - total1))
    idle_delta=$((idle_total2 - idle_total1))

    if (( total_delta <= 0 || idle_delta < 0 || idle_delta > total_delta )); then
        printf 'Inconsistent CPU counters.\n' >&2
        return 1
    fi

    cpu_usage=$(( (total_delta - idle_delta) * 100 / total_delta ))
    logical_cores=$(awk '/^processor[[:space:]]*:/ {count++} END {print count+0}' /proc/cpuinfo)
    cpu_model=$(awk -F ':' '/^(model name|Hardware)[[:space:]]*:/ {sub(/^[[:space:]]+/, "", $2); print $2; exit}' /proc/cpuinfo)

    if [[ ! "$logical_cores" =~ ^[1-9][0-9]*$ ]]; then
        printf 'Incomplete CPU information in /proc/cpuinfo.\n' >&2
        return 1
    fi
    cpu_model="${cpu_model:-Unavailable in /proc/cpuinfo}"

    printf 'CPU Information:\n'
    printf '%s\n' '----------------'
    printf 'CPU Model: %s\n' "$cpu_model"
    printf 'Logical Cores: %s\n' "$logical_cores"
    printf 'Usage (1 second sample): %s%%\n' "$cpu_usage"
    printf '%s\n' '----------------'
}

show_cpu_info
