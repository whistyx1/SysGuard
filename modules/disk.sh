#!/bin/bash

set -euo pipefail

show_disk_info() {

    local disk_path="${1:-/}"
    local disk_info file_system total_size used_size available_size usage_percentage mount_point

    if (( $# > 1 )); then
        printf 'Usage: disk [path]\n' >&2
        return 1
    fi

    if ! disk_info=$(df -Ph -- "$disk_path"); then
        printf 'Could not read disk information for: %s\n' "$disk_path" >&2
        return 1
    fi

    if [[ "$disk_info" != *$'\n'* ]]; then
        printf 'Incomplete disk information for: %s\n' "$disk_path" >&2
        return 1
    fi

    read -r \
        file_system total_size used_size available_size usage_percentage mount_point \
        <<< "${disk_info#*$'\n'}"

    if [[ -z "$file_system" || -z "$total_size" || -z "$used_size" || -z "$available_size" || -z "$usage_percentage" || -z "$mount_point" ]]; then
        printf 'Incomplete disk information for: %s\n' "$disk_path" >&2
        return 1
    fi

    echo "Disk Information:"
    echo "-----------------"
    echo "File System: $file_system"
    echo "Total Size: $total_size"
    echo "Used Size: $used_size"
    echo "Available Size: $available_size"
    echo "Usage Percentage: $usage_percentage"
    echo "Mount Point: $mount_point"
    echo "-----------------"
}

show_disk_info "$@"
