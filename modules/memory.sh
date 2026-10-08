#!/bin/bash

set -euo pipefail

convert_to_gib() {
    printf "%.2f\n" "$(echo "scale=2; $1 / 1024 / 1024" | bc)"
}

show_meminfo() {
    local mem_info=$(cat /proc/meminfo)

    local mem_total mem_free mem_available mem_buffers mem_cached mem_swap_total mem_swap_free mem_swap_used
    local mem_usage_percentage


    read -r \
        mem_total mem_free mem_available mem_buffers mem_cached mem_swap_total mem_swap_free \
        <<< "$(awk '
            $1 == "MemTotal:" {printf "%s ", $2}
            $1 == "MemFree:" {printf "%s ", $2}
            $1 == "MemAvailable:" {printf "%s ", $2}
            $1 == "Buffers:" {printf "%s ", $2}
            $1 == "Cached:" {printf "%s ", $2}
            $1 == "SwapTotal:" {printf "%s ", $2}
            $1 == "SwapFree:" {print $2}
        ' \
        <<< "$mem_info")"

    mem_usage_percentage=$(( (mem_total - mem_available) * 100 / mem_total))
    mem_swap_used=$((mem_swap_total - mem_swap_free ))

    echo "Memory Information:"
    echo "-------------------"
    echo "Total Memory: $(convert_to_gib "$mem_total") GiB"
    echo "Free Memory: $(convert_to_gib "$mem_free") GiB"
    echo "Available Memory: $(convert_to_gib "$mem_available") GiB"
    echo "Buffers: $(convert_to_gib "$mem_buffers") GiB"
    echo "Cached: $(convert_to_gib "$mem_cached") Gib"
    echo "Swap Total: $(convert_to_gib "$mem_swap_total") GiB"
    echo "Swap Free: $(convert_to_gib "$mem_swap_free") GiB"
    echo "Swap Used: $(convert_to_gib "$mem_swap_used") GiB"
    echo "Memory Usage Percentage: "$mem_usage_percentage" %"
    echo "-------------------"
}

show_meminfo