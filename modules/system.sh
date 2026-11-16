#!/bin/bash

set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/output.sh"

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

    print_section "System"
    print_metric "Host name" "$host_name"
    print_metric "Architecture" "$os_architecture"
    print_metric "Operating system" "$os_name"
    print_metric "Kernel" "$kernel_name $kernel_version"
    print_metric "Uptime" "$uptime_info"
    print_metric "Load average" "$load_average"
}

show_system_info
