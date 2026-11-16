#!/bin/bash

set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/output.sh"

show_disk_info() {
    local disk_info

    if (( $# > 1 )); then
        printf 'Usage: disk [path]\n' >&2
        return 1
    fi

    if (( $# == 1 )); then
        if ! disk_info=$(df -Ph -- "$1"); then
            printf 'Could not read disk information for: %s\n' "$1" >&2
            return 1
        fi
    else
        if ! disk_info=$(df -Ph); then
            printf 'Could not read filesystem information.\n' >&2
            return 1
        fi
    fi

    if [[ -z "$disk_info" || "$disk_info" != *$'\n'* ]]; then
        printf 'Incomplete disk information.\n' >&2
        return 1
    fi

    print_section "Disk"
    while read -r filesystem size used available usage mount_point; do
        [[ -z "$filesystem" || "$filesystem" == "Filesystem" ]] && continue
        print_section "$mount_point"
        print_metric "Filesystem" "$filesystem"
        print_metric "Size" "$size"
        print_metric "Used" "$used"
        print_metric "Available" "$available"
        print_metric "Usage" "$usage"
    done <<< "$disk_info"
}

show_disk_info "$@"
