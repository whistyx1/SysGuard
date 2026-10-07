show_help() {
    echo "System Guard - A simple system monitoring tool"
    echo "--------------------------------"
    echo "Usage: ./sysguard [option]"
    echo "Options:"
    echo "  --help   Show  help message"
    echo "  system   Show system information"
    echo "  disk [path]   Show disk information; default: /"
    echo "Example:"
    echo "  ./sysguard system"
    echo "  ./sysguard disk /var"
    echo "--------------------------------"
    exit 0
}

show_help