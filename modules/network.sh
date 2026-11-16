#!/bin/bash

set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/output.sh"

show_network_info() {
    local stats_before stats_after network_rows interface rx_bytes tx_bytes rx_packets tx_packets rx_rate tx_rate
    local addresses address

    if [[ ! -r /proc/net/dev ]]; then
        printf 'Cannot read /proc/net/dev.\n' >&2
        return 1
    fi

    if ! stats_before=$(awk -F: 'NR > 2 {name=$1; gsub(/^[[:space:]]+|[[:space:]]+$/, "", name); stats=$2; sub(/^[[:space:]]+/, "", stats); split(stats, f, /[[:space:]]+/); printf "%s|%s|%s|%s|%s\n", name, f[1], f[9], f[2], f[10]}' /proc/net/dev) ||
       ! sleep 1 ||
       ! stats_after=$(awk -F: 'NR > 2 {name=$1; gsub(/^[[:space:]]+|[[:space:]]+$/, "", name); stats=$2; sub(/^[[:space:]]+/, "", stats); split(stats, f, /[[:space:]]+/); printf "%s|%s|%s|%s|%s\n", name, f[1], f[9], f[2], f[10]}' /proc/net/dev); then
        printf 'Could not sample network counters.\n' >&2
        return 1
    fi

    network_rows=$(awk -F'|' -v before="$stats_before" -v after="$stats_after" '
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
                count = split(old_lines[line], fields, "|")
                if (count < 5) continue
                old_rx[fields[1]] = fields[2]
                old_tx[fields[1]] = fields[3]
            }
            new_count = split(after, new_lines, "\n")
            for (line = 1; line <= new_count; line++) {
                count = split(new_lines[line], fields, "|")
                if (count < 5 || !(fields[1] in old_rx)) continue
                rx_rate = fields[2] - old_rx[fields[1]]
                tx_rate = fields[3] - old_tx[fields[1]]
                if (rx_rate < 0 || tx_rate < 0) continue
                printf "%s|%s|%s|%s|%s|%s|%s\n", fields[1], human(fields[2], ""), human(fields[3], ""), fields[4], fields[5], human(rx_rate, "/s"), human(tx_rate, "/s")
            }
        }
    ')

    if [[ -z "$network_rows" ]]; then
        printf 'No network interfaces found in /proc/net/dev.\n' >&2
        return 1
    fi

    print_section "Network (1 second sample)"
    while IFS='|' read -r interface rx_bytes tx_bytes rx_packets tx_packets rx_rate tx_rate; do
        addresses=''
        if command -v ip >/dev/null 2>&1; then
            if addresses=$(ip -o address show dev "$interface" 2>/dev/null | awk '$3 == "inet" || $3 == "inet6" {printf "%s%s ", separator, $4; separator=", "}'); then
                addresses="${addresses% }"
            else
                addresses=''
            fi
        fi
        if [[ "$interface" != "lo" && -z "$addresses" && "$rx_bytes" == "0.0 B" && "$tx_bytes" == "0.0 B" && "$rx_packets" == 0 && "$tx_packets" == 0 ]]; then
            continue
        fi
        print_section "$interface"
        if command -v ip >/dev/null 2>&1; then
            print_metric "IP addresses" "${addresses:-None assigned}"
        else
            print_metric "IP addresses" "Unavailable (ip utility not installed)"
        fi
        print_metric "Received" "$rx_bytes"
        print_metric "Sent" "$tx_bytes"
        print_metric "RX packets" "$rx_packets"
        print_metric "TX packets" "$tx_packets"
        print_metric "Receive rate" "$rx_rate"
        print_metric "Transmit rate" "$tx_rate"
    done <<< "$network_rows"
}

show_network_info "$@"
