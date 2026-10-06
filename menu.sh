#!/bin/bash

show_menu() {
    echo "System Guard - A simple system monitoring tool"
    echo "--------------------------------"
    echo "Options:"
    echo "  1) system - Show system information"
    echo "  2) disk   - Show disk information"
    read -p "Enter your choice: " choice
}

show_menu