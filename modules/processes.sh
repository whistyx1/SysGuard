#!/bin/bash

set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/output.sh"

show_top_processes() {
    local sort_by="$1" title="$2" rows pid command cpu memory index=1

    if ! rows=$(ps -eo pid=,comm=,%cpu=,%mem= --sort="-$sort_by" | sed -n '1,5p'); then
        printf 'Could not list processes by %s.\n' "$sort_by" >&2
        return 1
    fi
    if [[ -z "$rows" ]]; then
        printf 'No process data returned.\n' >&2
        return 1
    fi

    print_section "$title"
    while read -r pid command cpu memory; do
        print_metric "$index. $command (PID $pid)" "CPU ${cpu}% | MEM ${memory}%"
        ((index += 1))
    done <<< "$rows"
}

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

    print_section "Processes"
    print_metric "Total" "$process_count"

    show_top_processes '%cpu' 'Top by CPU'
    show_top_processes '%mem' 'Top by memory'
}

show_process_info
