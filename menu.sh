#!/bin/bash

show_menu() {
    echo "System Guard - A simple system monitoring tool"
    echo "--------------------------------"
    echo "Options:"
    echo "  1) system - Show system information"
    echo "  2) disk   - Show disk information"
    echo "  3) memory - Show memory information"
    read -p "Enter your choice: " choice

    if [[ "$choice" -eq 2 ]]; then
        read -p "Enter path to disk.sh (/ - by default): " disk_path
    fi
}

show_menu