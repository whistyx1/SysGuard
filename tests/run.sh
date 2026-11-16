#!/bin/bash

set -uo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
passed=0
failed=0

run_output_test() {
    local name="$1" expected="$2" output
    shift 2

    if output=$(NO_COLOR=1 "$@" 2>&1) && [[ "$output" == *"$expected"* ]]; then
        printf 'PASS %s\n' "$name"
        ((passed += 1))
    else
        printf 'FAIL %s\n' "$name" >&2
        printf '%s\n' "$output" >&2
        ((failed += 1))
    fi
}

run_failure_test() {
    local name="$1" expected="$2" output
    shift 2

    if output=$(NO_COLOR=1 "$@" 2>&1); then
        printf 'FAIL %s (unexpected success)\n' "$name" >&2
        ((failed += 1))
    elif [[ "$output" == *"$expected"* ]]; then
        printf 'PASS %s\n' "$name"
        ((passed += 1))
    else
        printf 'FAIL %s\n' "$name" >&2
        printf '%s\n' "$output" >&2
        ((failed += 1))
    fi
}

run_output_test SystemCommandShowsOperatingSystem "Operating system" bash "$ROOT_DIR/sysguard" system
run_output_test CpuCommandShowsLoadAverage "Load average" bash "$ROOT_DIR/sysguard" cpu
run_output_test CpuPerCoreShowsIndividualCores "Per-core usage" bash "$ROOT_DIR/sysguard" cpu --per-core
run_output_test MemoryCommandShowsUsedRam "  Used" bash "$ROOT_DIR/sysguard" memory
run_output_test MemoryCommandShowsSwapUsage "  Usage" bash "$ROOT_DIR/sysguard" memory
run_output_test DiskCommandListsFilesystems "Filesystem" bash "$ROOT_DIR/sysguard" disk
run_output_test DiskPathShowsFilesystem "Filesystem" bash "$ROOT_DIR/sysguard" disk /
run_output_test DiskIoShowsRates "Read rate" bash "$ROOT_DIR/sysguard" disk --io
run_output_test DiskIoShowsWriteRates "Write rate" bash "$ROOT_DIR/sysguard" disk --io
run_output_test ProcessesCommandShowsRankedLists "Top by memory" bash "$ROOT_DIR/sysguard" processes
run_output_test NetworkCommandShowsTrafficRates "Receive rate" bash "$ROOT_DIR/sysguard" network
run_output_test NetworkCommandShowsIpAddressField "IP addresses" bash "$ROOT_DIR/sysguard" network
run_output_test AllCommandRunsThroughProcesses "Top by memory" bash "$ROOT_DIR/sysguard" all

if output=$(printf '8\n' | NO_COLOR=1 bash "$ROOT_DIR/sysguard" 2>&1) && [[ "$output" == *"Network"* ]]; then
    printf 'PASS MenuDispatchesNetworkCommand\n'
    ((passed += 1))
else
    printf 'FAIL MenuDispatchesNetworkCommand\n%s\n' "$output" >&2
    ((failed += 1))
fi

run_failure_test UnknownCommandReturnsError "Invalid argument" bash "$ROOT_DIR/sysguard" unknown
run_failure_test CpuRejectsUnknownOption "Invalid arguments" bash "$ROOT_DIR/sysguard" cpu --invalid
run_failure_test DiskRejectsMissingPath "Could not read disk information" bash "$ROOT_DIR/sysguard" disk /missing-sysguard-test-path

printf '\nResults: %d passed, %d failed\n' "$passed" "$failed"
(( failed == 0 ))
