#!/usr/bin/env bash
# test_cli.sh — Tests for toff command-line interface

source "$(dirname "${BASH_SOURCE[0]}")/test_helper.bash"
setup_test_env

# Safety mock for all system commands during CLI tests
mock_command "sudo" "exit 0"
mock_command "shutdown" "exit 0"
mock_command "systemctl" "exit 0"
mock_command "poweroff" "exit 0"

TOFF_BIN="${TOFF_SRC}/toff"

echo "Running CLI Interface Tests..."

# Test --version and -v
version_out="$("${TOFF_BIN}" --version)"
assert_contains "$version_out" "toff 1.0.0" "CLI --version output"
assert_eq "toff 1.0.0" "$("${TOFF_BIN}" -v)" "CLI -v output"

# Test --help and -h
help_out="$("${TOFF_BIN}" --help)"
assert_contains "$help_out" "Usage:" "CLI --help displays Usage"
assert_contains "$help_out" "Time Formats:" "CLI --help displays Time Formats"
assert_contains "$("${TOFF_BIN}" -h)" "Usage:" "CLI -h displays Usage"

# Test missing arguments
assert_failure "CLI fails with no arguments" "${TOFF_BIN}"

# Test invalid flag
assert_failure "CLI fails with unknown flag" "${TOFF_BIN}" --invalid-flag

# Test invalid buffer argument
assert_failure "CLI fails with non-integer buffer" "${TOFF_BIN}" --buffer abc 90

# Test --cancel when no timer is active
export TOFF_STATE_DIR="${TEST_TMPDIR}/state_clean"
rm -rf "${TOFF_STATE_DIR}"
cancel_out="$("${TOFF_BIN}" --cancel)"
assert_contains "$cancel_out" "no active timer state found" "CLI --cancel with no active timer"

# Test overlapping timer prevention
export TOFF_STATE_DIR="${TEST_TMPDIR}/state_active"
mkdir -p "${TOFF_STATE_DIR}"
overlap_err="$("${TOFF_BIN}" 90 2>&1 || true)"
assert_contains "$overlap_err" "a shutdown timer is already active" "CLI prevents overlapping timers"
rm -rf "${TOFF_STATE_DIR}"

report_suite "toff CLI"
