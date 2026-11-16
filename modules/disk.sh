#!/bin/bash

set -euo pipefail

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

    printf 'Disk Information:\n'
    printf '%s\n' '-----------------'
    printf '%s\n' "$disk_info"
    printf '%s\n' '-----------------'
}

show_disk_info "$@"
