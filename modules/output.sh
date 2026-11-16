if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
    SG_CYAN=$'\033[1;36m'
    SG_LABEL=$'\033[1;34m'
    SG_RESET=$'\033[0m'
else
    SG_CYAN=''
    SG_LABEL=''
    SG_RESET=''
fi

print_section() {
    printf '\n%b%s%b\n' "$SG_CYAN" "$1" "$SG_RESET"
}

print_metric() {
    printf '  %b%-24s%b %s\n' "$SG_LABEL" "$1" "$SG_RESET" "$2"
}
