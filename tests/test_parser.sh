#!/usr/bin/env bash
# test_parser.sh — Tests for toff parser.sh

source "$(dirname "${BASH_SOURCE[0]}")/test_helper.bash"
setup_test_env

source "${TOFF_LIB_DIR}/parser.sh"

echo "Running Parser Tests..."

# Test H.MM format
assert_eq "5400" "$(toff_parse_time "1.30")" "parse 1.30 as 5400s (1h 30m)"
assert_eq "2700" "$(toff_parse_time "0.45")" "parse 0.45 as 2700s (45m)"
assert_eq "7200" "$(toff_parse_time "2.00")" "parse 2.00 as 7200s (2h)"
assert_eq "36300" "$(toff_parse_time "10.05")" "parse 10.05 as 36300s (10h 5m)"

# Test MM format
assert_eq "5400" "$(toff_parse_time "90")" "parse 90 as 5400s (90m)"
assert_eq "60" "$(toff_parse_time "1")" "parse 1 as 60s (1m)"
assert_eq "300" "$(toff_parse_time "5")" "parse 5 as 300s (5m)"
assert_eq "7200" "$(toff_parse_time "120")" "parse 120 as 7200s (120m)"

# Test HH:MM format
assert_eq "5400" "$(toff_parse_time "1:30")" "parse 1:30 as 5400s"
assert_eq "900" "$(toff_parse_time "00:15")" "parse 00:15 as 900s"
assert_eq "300" "$(toff_parse_time "0:05")" "parse 0:05 as 300s"
assert_eq "7200" "$(toff_parse_time "2:00")" "parse 2:00 as 7200s"

# Test HH:MM:SS format
assert_eq "5400" "$(toff_parse_time "1:30:00")" "parse 1:30:00 as 5400s"
assert_eq "90" "$(toff_parse_time "00:01:30")" "parse 00:01:30 as 90s"
assert_eq "45" "$(toff_parse_time "0:00:45")" "parse 0:00:45 as 45s"
assert_eq "3665" "$(toff_parse_time "01:01:05")" "parse 01:01:05 as 3665s"

# Test Invalid inputs
assert_failure "reject H.MM with minutes >= 60 (1.60)" toff_parse_time "1.60"
assert_failure "reject H.MM with minutes >= 60 (1.99)" toff_parse_time "1.99"
assert_failure "reject HH:MM with minutes >= 60 (1:60)" toff_parse_time "1:60"
assert_failure "reject HH:MM:SS with seconds >= 60 (1:30:60)" toff_parse_time "1:30:60"
assert_failure "reject HH:MM:SS with minutes >= 60 (1:60:00)" toff_parse_time "1:60:00"
assert_failure "reject 0 minutes" toff_parse_time "0"
assert_failure "reject negative time (-10)" toff_parse_time "-10"
assert_failure "reject non-numeric string (abc)" toff_parse_time "abc"
assert_failure "reject invalid delimiter format (1.2.3)" toff_parse_time "1.2.3"
assert_failure "reject empty input" toff_parse_time ""

report_suite "parser.sh"
