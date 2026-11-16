#!/bin/bash

set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/output.sh"

convert_to_gib() {
    awk -v kib="$1" 'BEGIN {printf "%.2f\n", kib / 1048576}'
}

show_meminfo() {
    local mem_total='' mem_free='' mem_available='' mem_buffers='' mem_cached=''
    local mem_swap_total='' mem_swap_free='' mem_swap_used='' mem_used key value unit
    local mem_usage_percentage mem_swap_usage_percentage

    if [[ ! -r /proc/meminfo ]]; then
        printf 'Cannot read /proc/meminfo.\n' >&2
        return 1
    fi

    while read -r key value unit; do
        case "$key" in
            MemTotal:|MemFree:|MemAvailable:|Buffers:|Cached:|SwapTotal:|SwapFree:)
                if [[ "$unit" != "kB" ]]; then
                    printf 'Invalid memory unit for %s\n' "$key" >&2
                    return 1
                fi
                ;;
        esac
        case "$key" in
            MemTotal:) mem_total="$value" ;;
            MemFree:) mem_free="$value" ;;
            MemAvailable:) mem_available="$value" ;;
            Buffers:) mem_buffers="$value" ;;
            Cached:) mem_cached="$value" ;;
            SwapTotal:) mem_swap_total="$value" ;;
            SwapFree:) mem_swap_free="$value" ;;
        esac
    done < /proc/meminfo

    for value in "$mem_total" "$mem_free" "$mem_available" "$mem_buffers" "$mem_cached" "$mem_swap_total" "$mem_swap_free"; do
        if [[ ! "$value" =~ ^(0|[1-9][0-9]*)$ ]]; then
            printf 'Invalid or incomplete memory information.\n' >&2
            return 1
        fi
    done

    if (( mem_total == 0 || mem_available > mem_total || mem_swap_free > mem_swap_total )); then
        printf 'Inconsistent memory information.\n' >&2
        return 1
    fi

    mem_usage_percentage=$(( (mem_total - mem_available) * 100 / mem_total))
    mem_used=$((mem_total - mem_available))
    mem_swap_used=$((mem_swap_total - mem_swap_free ))
    mem_swap_usage_percentage=0
    if (( mem_swap_total > 0 )); then
        mem_swap_usage_percentage=$((mem_swap_used * 100 / mem_swap_total))
    fi

    print_section "Memory"
    print_metric "Total" "$(convert_to_gib "$mem_total") GiB"
    print_metric "Used" "$(convert_to_gib "$mem_used") GiB"
    print_metric "Free" "$(convert_to_gib "$mem_free") GiB"
    print_metric "Available" "$(convert_to_gib "$mem_available") GiB"
    print_metric "Buffers" "$(convert_to_gib "$mem_buffers") GiB"
    print_metric "Cached" "$(convert_to_gib "$mem_cached") GiB"
    print_section "Swap"
    print_metric "Total" "$(convert_to_gib "$mem_swap_total") GiB"
    print_metric "Used" "$(convert_to_gib "$mem_swap_used") GiB"
    print_metric "Free" "$(convert_to_gib "$mem_swap_free") GiB"
    print_metric "Usage" "$mem_swap_usage_percentage%"
    print_metric "Memory usage" "$mem_usage_percentage%"
}

show_meminfo
