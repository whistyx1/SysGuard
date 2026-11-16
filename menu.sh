#!/bin/bash

show_menu() {
    echo "System Guard - A simple system monitoring tool"
    echo "--------------------------------"
    echo "Options:"
    echo "  1) system - Show system information"
    echo "  2) disk   - Show disk information"
    echo "  3) memory - Show memory information"
    echo "  4) processes - Show process information"
    echo "  5) cpu - Show CPU information"
    echo "  6) all - Show all system information"
    echo "  7) disk I/O - Show read/write counters and throughput"
    if ! read -r -p "Enter your choice: " choice; then
        printf 'Could not read menu choice.\n' >&2
        return 1
    fi

    case "$choice" in
        1|3|4|5|6|7) ;;
        2)
            if ! read -r -p "Enter disk path (leave blank for all filesystems): " disk_path; then
                printf 'Could not read disk path.\n' >&2
                return 1
            fi
            ;;
        *)
            printf 'Invalid choice. Enter 1, 2, 3, 4, 5, 6, or 7.\n' >&2
            return 1
            ;;
    esac
}

show_menu
