#!/bin/bash

set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/output.sh"

show_cpu_info() {
    local per_core=false
    local user1 nice1 system1 idle1 iowait1 irq1 softirq1 steal1
    local user2 nice2 system2 idle2 iowait2 irq2 softirq2 steal2
    local total1 total2 idle_total1 idle_total2 total_delta idle_delta
    local cpu_usage logical_cores cpu_model cpu_before cpu_after core_usage
    local load_1 load_5 load_15 core_name core_percent value

    if (( $# > 1 )); then
        printf 'Usage: cpu [--per-core]\n' >&2
        return 1
    fi
    if (( $# == 1 )); then
        if [[ "$1" != "--per-core" ]]; then
            printf 'Invalid CPU option: %s\n' "$1" >&2
            return 1
        fi
        per_core=true
    fi

    if [[ ! -r /proc/stat || ! -r /proc/cpuinfo ]]; then
        printf 'Cannot read CPU information from /proc.\n' >&2
        return 1
    fi

    cpu_before=$(awk '/^cpu([0-9]+)? / {print}' /proc/stat)
    if ! read -r _ user1 nice1 system1 idle1 iowait1 irq1 softirq1 steal1 _ < /proc/stat; then
        printf 'Could not read CPU counters.\n' >&2
        return 1
    fi
    sleep 1
    cpu_after=$(awk '/^cpu([0-9]+)? / {print}' /proc/stat)
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

    print_section "CPU"
    print_metric "Model" "$cpu_model"
    print_metric "Logical cores" "$logical_cores"
    print_metric "Usage (1 second sample)" "$cpu_usage%"

    if [[ -r /proc/loadavg ]] && read -r load_1 load_5 load_15 _ < /proc/loadavg; then
        if [[ "$load_1 $load_5 $load_15" =~ ^[0-9]+([.][0-9]+)?\ [0-9]+([.][0-9]+)?\ [0-9]+([.][0-9]+)?$ ]]; then
            print_metric "Load average (1/5/15m)" "$load_1 $load_5 $load_15"
        fi
    fi

    if [[ "$per_core" == true ]]; then
        core_usage=$(awk -v before="$cpu_before" -v after="$cpu_after" '
            BEGIN {
                old_count = split(before, old_lines, "\n")
                for (line = 1; line <= old_count; line++) {
                    count = split(old_lines[line], fields)
                    name = fields[1]
                    if (name !~ /^cpu[0-9]+$/) continue
                    total = 0
                    for (i = 2; i <= count; i++) total += fields[i]
                    old_total[name] = total
                    old_idle[name] = fields[5] + fields[6]
                }
                new_count = split(after, new_lines, "\n")
                for (line = 1; line <= new_count; line++) {
                    count = split(new_lines[line], fields)
                    name = fields[1]
                    if (name !~ /^cpu[0-9]+$/ || !(name in old_total)) continue
                    total = 0
                    for (i = 2; i <= count; i++) total += fields[i]
                    total_delta = total - old_total[name]
                    idle_delta = fields[5] + fields[6] - old_idle[name]
                    if (total_delta > 0 && idle_delta >= 0 && idle_delta <= total_delta)
                        printf "%s %d%%\n", name, ((total_delta - idle_delta) * 100 / total_delta)
                }
            }
        ')

        if [[ -z "$core_usage" ]]; then
            printf 'Could not calculate per-core CPU usage.\n' >&2
            return 1
        fi
        print_section "Per-core usage (1 second sample)"
        while read -r core_name core_percent; do
            print_metric "${core_name^^}" "$core_percent"
        done <<< "$core_usage"
    fi
}

show_cpu_info "$@"
