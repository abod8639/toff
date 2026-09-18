#!/usr/bin/env bash
# test_shutdown.sh — Tests for toff shutdown.sh

source "$(dirname "${BASH_SOURCE[0]}")/test_helper.bash"
setup_test_env

source "${TOFF_LIB_DIR}/shutdown.sh"

echo "Running Shutdown & Scheduling Tests..."

# Test _toff_poweroff_cmd
assert_eq "systemctl poweroff" "$(_toff_poweroff_cmd "systemd")" "poweroff command for systemd"

# Test fallback command resolution
mock_command "poweroff" "exit 0"
assert_eq "poweroff" "$(_toff_poweroff_cmd "openrc")" "poweroff command when poweroff binary exists"
unmock_command "poweroff"

# Test _toff_detect_init
init_system="$(_toff_detect_init)"
assert_matches "^(systemd|openrc|runit|s6|sysv)$" "$init_system" "detect a valid init system ($init_system)"

# Test toff_schedule with mocked shutdown command
mock_command "sudo" '
if [[ "$1" == "shutdown" ]]; then
    exit 0
fi
exit 0
'
mock_command "shutdown" "exit 0"

export TOFF_STATE_DIR="${TEST_TMPDIR}/state"
rm -rf "${TOFF_STATE_DIR}"

toff_schedule 300
assert_eq "SHUTDOWN" "$(< "${TOFF_STATE_DIR}/method")" "schedule records SHUTDOWN method"
assert_eq "5" "$(< "${TOFF_STATE_DIR}/minutes")" "schedule records 5 minutes (for 300s)"

# Test toff_cancel with SHUTDOWN method
cancel_output="$(toff_cancel)"
assert_contains "$cancel_output" "cancelled" "toff_cancel confirms shutdown cancellation"
assert_failure "state dir removed after cancel" test -d "${TOFF_STATE_DIR}"

# Test toff_cancel with SYSTEMD_RUN method
mkdir -p "${TOFF_STATE_DIR}"
echo "SYSTEMD_RUN" > "${TOFF_STATE_DIR}/method"
mock_command "systemctl" "exit 0"
cancel_output="$(toff_cancel)"
assert_contains "$cancel_output" "Systemd timer cancelled" "toff_cancel cancels systemd timer"
assert_failure "state dir removed after systemd cancel" test -d "${TOFF_STATE_DIR}"

# Test toff_cancel with AT method
mkdir -p "${TOFF_STATE_DIR}"
echo "AT" > "${TOFF_STATE_DIR}/method"
mock_command "atq" 'echo "42 Thu Sep 18 10:00:00 2026 a user"'
mock_command "atrm" 'exit 0'
cancel_output="$(toff_cancel)"
assert_contains "$cancel_output" "job #42 cancelled" "toff_cancel cancels at job"
assert_failure "state dir removed after at cancel" test -d "${TOFF_STATE_DIR}"

# Test toff_cancel when no active state
mkdir -p "${TOFF_STATE_DIR}"
cancel_output="$(toff_cancel)"
assert_contains "$cancel_output" "no active timer state found" "toff_cancel reports no active state"

report_suite "shutdown.sh"
