#!/bin/bash

show_system_info() {
    host_name=$(hostname)
    os_name=$(awk -F 'PRETTY_NAME=' '{print $2}' /etc/os-release | tr -d '"')
    kernel_name=$(uname -s)
    kernel_version=$(uname -r)
    uptime=$(uptime -p)
    load_average=$(uptime | awk -F 'load average: ' '{print $2}')

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