#!/bin/bash

show_disk_info() {
    disk_info=$(df -h /)

    local file_system=$(printf '%s\n' "$disk_info" | awk 'NR==2 {print $1}')
    local total_size=$(printf '%s\n' "$disk_info" | awk 'NR==2 {print $2}')
    local used_size=$(printf '%s\n' "$disk_info" | awk 'NR==2 {print $3}')
    local available_size=$(printf '%s\n' "$disk_info" | awk 'NR==2 {print $4}')
    local usage_percentage=$(printf '%s\n' "$disk_info" | awk 'NR==2 {print $5}')
    local mount_point=$(printf '%s\n' "$disk_info" | awk 'NR==2 {print $6}')

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

show_disk_info