#!/bin/bash

show_help() {
    echo "System Guard - A simple system monitoring tool"
    echo "--------------------------------"
    echo "Usage: ./sysguard [option]"
    echo "Options:"
    echo "  --help   Show  help message"
    echo "  system   Show system information"
    echo "  disk [path]   Show disk information; default: /"
    echo "  memory   Show memory information"
    echo "  processes   Show process information"
    echo "--------------------------------"
    echo "Example:"
    echo "  ./sysguard system"
    echo "  ./sysguard disk /var"
    echo "  ./sysguard memory"
    echo "  ./sysguard processes"
    echo "--------------------------------"
    exit 0
}

show_help