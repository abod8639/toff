#!/usr/bin/env bash
# test_countdown.sh — Tests for toff countdown.sh

source "$(dirname "${BASH_SOURCE[0]}")/test_helper.bash"
setup_test_env

source "${TOFF_LIB_DIR}/countdown.sh"

echo "Running Countdown & Duration Tests..."

# Test format_duration with hours, minutes, seconds
assert_eq "1h 30m 00s" "$(toff_format_duration 5400)" "format 5400s as 1h 30m 00s"
assert_eq "1h 00m 00s" "$(toff_format_duration 3600)" "format 3600s as 1h 00m 00s"
assert_eq "2h 00m 00s" "$(toff_format_duration 7200)" "format 7200s as 2h 00m 00s"
assert_eq "1h 01m 05s" "$(toff_format_duration 3665)" "format 3665s as 1h 01m 05s"

# Test format_duration with minutes and seconds
assert_eq "1m 30s" "$(toff_format_duration 90)" "format 90s as 1m 30s"
assert_eq "1m 00s" "$(toff_format_duration 60)" "format 60s as 1m 00s"
assert_eq "59m 59s" "$(toff_format_duration 3599)" "format 3599s as 59m 59s"
assert_eq "5m 03s" "$(toff_format_duration 303)" "format 303s as 5m 03s"

# Test format_duration with seconds only
assert_eq "45s" "$(toff_format_duration 45)" "format 45s as 45s"
assert_eq "1s" "$(toff_format_duration 1)" "format 1s as 1s"
assert_eq "59s" "$(toff_format_duration 59)" "format 59s as 59s"
assert_eq "0s" "$(toff_format_duration 0)" "format 0s as 0s"

report_suite "countdown.sh"
