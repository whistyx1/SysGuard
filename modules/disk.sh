#!/bin/bash

show_disk_info() {

    local disk_path="${1:-/}"

    local disk_info=$(df -h  "${disk_path}")

    local file_system total_size used_size available_size usage_percentage mount_point

    read -r \
        file_system total_size used_size available_size usage_percentage mount_point \
        <<< "$(awk 'NR==2 {print $1, $2, $3, $4, $5, $6}' \
        <<< "$disk_info")"

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