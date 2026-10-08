#!/bin/bash

set -euo pipefail

show_system_info() {
    local host_name=$(hostname)
    local os_name=$(awk -F 'PRETTY_NAME=' '{print $2}' /etc/os-release | tr -d '"')
    local kernel_name=$(uname -s)
    local kernel_version=$(uname -r)
    local uptime=$(uptime -p)
    local load_average=$(uptime | awk -F 'load average: ' '{print $2}')

    echo "System Information:"
    echo "-------------------"
    echo "Host Name: $host_name"
    echo "Operating System: $os_name"
    echo "Kernel Name: $kernel_name"
    echo "Kernel Version: $kernel_version"
    echo "Uptime: $uptime"
    echo "Load Average: $load_average"
    echo "-------------------"
}

show_system_info