#!/usr/bin/env bash
# run_tests.sh — Master test runner for toff test suite

set -uo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[1;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}${CYAN}========================================"
echo -e "       toff Automated Test Suite        "
echo -e "========================================${NC}"

test_files=(
    "${TEST_DIR}/test_parser.sh"
    "${TEST_DIR}/test_countdown.sh"
    "${TEST_DIR}/test_media.sh"
    "${TEST_DIR}/test_shutdown.sh"
    "${TEST_DIR}/test_cli.sh"
)

overall_status=0
failed_suites=()

for test_file in "${test_files[@]}"; do
    suite_name="$(basename "$test_file")"
    echo ""
    echo -e "${BOLD}▶ Running ${suite_name}...${NC}"
    if bash "$test_file"; then
        echo -e "${GREEN}✔ ${suite_name} passed.${NC}"
    else
        echo -e "${RED}✘ ${suite_name} failed!${NC}"
        overall_status=1
        failed_suites+=("$suite_name")
    fi
done

echo ""
echo -e "${BOLD}${CYAN}========================================"
echo -e "             Final Summary              "
echo -e "========================================${NC}"

if [[ $overall_status -eq 0 ]]; then
    echo -e "${GREEN}${BOLD}ALL TEST SUITES PASSED SUCCESSFULLY! ✔${NC}"
    exit 0
else
    echo -e "${RED}${BOLD}SOME TEST SUITES FAILED: ${failed_suites[*]} ✘${NC}"
    exit 1
fi
