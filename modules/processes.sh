#!/bin/bash

set -euo pipefail

show_process_info() {
    local process_count

    if ! process_count=$(ps -e --no-headers | wc -l); then
        printf 'Could not read process list.\n' >&2
        return 1
    fi
    process_count="${process_count//[[:space:]]/}"

    if [[ ! "$process_count" =~ ^[0-9]+$ ]]; then
        printf 'Invalid process count returned by ps.\n' >&2
        return 1
    fi

    printf 'Process Information:\n'
    printf '%s\n' '-------------------'
    printf 'Total Processes: %s\n\n' "$process_count"

    printf 'Top Processes by CPU:\n'
    if ! ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 6; then
        printf 'Could not list processes by CPU.\n' >&2
        return 1
    fi

    printf '\nTop Processes by Memory:\n'
    if ! ps -eo pid,comm,%cpu,%mem --sort=-%mem | head -n 6; then
        printf 'Could not list processes by memory.\n' >&2
        return 1
    fi
}

show_process_info
