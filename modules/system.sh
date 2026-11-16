#!/bin/bash

set -euo pipefail

show_system_info() {
    local host_name os_architecture os_name kernel_name kernel_version uptime_info load_average

    if [[ ! -r /etc/os-release ]]; then
        printf 'Cannot read /etc/os-release.\n' >&2
        return 1
    fi

    if ! host_name=$(hostname) || ! os_architecture=$(uname -m) ||
       ! os_name=$(awk -F 'PRETTY_NAME=' '/^PRETTY_NAME=/ {print $2}' /etc/os-release | tr -d '"') ||
       ! kernel_name=$(uname -s) || ! kernel_version=$(uname -r) ||
       ! uptime_info=$(uptime -p) ||
       ! load_average=$(uptime | awk -F 'load average: ' '{print $2}'); then
        printf 'Could not read system information.\n' >&2
        return 1
    fi

    if [[ -z "$host_name" || -z "$os_architecture" || -z "$os_name" || -z "$kernel_name" || -z "$kernel_version" || -z "$uptime_info" || -z "$load_average" ]]; then
        printf 'Incomplete system information.\n' >&2
        return 1
    fi

    echo "System Information:"
    echo "-------------------"
    echo "Host Name: $host_name"
    echo "Architecture: $os_architecture"
    echo "Operating System: $os_name"
    echo "Kernel Name: $kernel_name"
    echo "Kernel Version: $kernel_version"
    echo "Uptime: $uptime_info"
    echo "Load Average: $load_average"
    echo "-------------------"
}

show_system_info
