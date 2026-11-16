#!/bin/bash

set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/output.sh"

show_disk_io() {
    local stats_before stats_after io_rows device reads writes read_bytes write_bytes read_rate write_rate

    if [[ ! -r /proc/diskstats ]]; then
        printf 'Cannot read /proc/diskstats.\n' >&2
        return 1
    fi

    if ! stats_before=$(cat /proc/diskstats) || ! sleep 1 || ! stats_after=$(cat /proc/diskstats); then
        printf 'Could not sample disk I/O counters.\n' >&2
        return 1
    fi

    io_rows=$(awk -v before="$stats_before" -v after="$stats_after" '
        function human(bytes, suffix, unit_index) {
            split("B KiB MiB GiB TiB", units, " ")
            unit_index = 1
            while (bytes >= 1024 && unit_index < 5) {
                bytes /= 1024
                unit_index++
            }
            return sprintf("%.1f %s%s", bytes, units[unit_index], suffix)
        }
        BEGIN {
            old_count = split(before, old_lines, "\n")
            for (line = 1; line <= old_count; line++) {
                count = split(old_lines[line], fields)
                if (count < 10) continue
                name = fields[3]
                if (name ~ /^(ram|loop|nbd|fd)[0-9]+$/) continue
                old_reads[name] = fields[4]
                old_read_sectors[name] = fields[6]
                old_writes[name] = fields[8]
                old_write_sectors[name] = fields[10]
            }
            new_count = split(after, new_lines, "\n")
            for (line = 1; line <= new_count; line++) {
                count = split(new_lines[line], fields)
                if (count < 10) continue
                name = fields[3]
                if (name ~ /^(ram|loop|nbd|fd)[0-9]+$/) continue
                if (!(name in old_reads)) continue
                reads = fields[4] - old_reads[name]
                writes = fields[8] - old_writes[name]
                read_bytes = (fields[6] - old_read_sectors[name]) * 512
                write_bytes = (fields[10] - old_write_sectors[name]) * 512
                if (reads < 0 || writes < 0 || read_bytes < 0 || write_bytes < 0) continue
                printf "%s|%s|%s|%s|%s|%s|%s|%s|%s\n", fields[1], fields[2], name, fields[4], fields[8], human(fields[6] * 512, ""), human(fields[10] * 512, ""), human(read_bytes, "/s"), human(write_bytes, "/s")
            }
        }
    ')

    if [[ -z "$io_rows" ]]; then
        printf 'No disk I/O devices found in /proc/diskstats.\n' >&2
        return 1
    fi

    print_section "Disk I/O (1 second sample)"
    while IFS='|' read -r major minor device reads writes read_bytes write_bytes read_rate write_rate; do
        if [[ -e "/sys/dev/block/${major}:${minor}/partition" ]]; then
            continue
        fi
        print_section "$device"
        print_metric "Read operations" "$reads"
        print_metric "Write operations" "$writes"
        print_metric "Total read" "$read_bytes"
        print_metric "Total written" "$write_bytes"
        print_metric "Read rate" "$read_rate"
        print_metric "Write rate" "$write_rate"
    done <<< "$io_rows"
}

show_disk_info() {
    local disk_info

    if (( $# > 1 )); then
        printf 'Usage: disk [path|--io]\n' >&2
        return 1
    fi

    if (( $# == 1 )); then
        if [[ "$1" == "--io" ]]; then
            show_disk_io
            return
        fi
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
