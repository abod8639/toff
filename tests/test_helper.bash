#!/usr/bin/env bash
# test_helper.bash — Test utilities and assertions for toff test suite

# Root directories
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOFF_ROOT="$(cd "${TEST_DIR}/.." && pwd)"
TOFF_SRC="${TOFF_ROOT}/src"
export TOFF_LIB_DIR="${TOFF_SRC}/lib"

# Color constants
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Temporary state for isolation
TEST_TMPDIR=""
TEST_MOCK_BIN=""

setup_test_env() {
    TEST_TMPDIR="$(mktemp -d /tmp/toff_test_XXXXXX)"
    export TOFF_STATE_DIR="${TEST_TMPDIR}/state"
    mkdir -p "${TOFF_STATE_DIR}"

    TEST_MOCK_BIN="${TEST_TMPDIR}/bin"
    mkdir -p "${TEST_MOCK_BIN}"
    export ORIGINAL_PATH="$PATH"
    export PATH="${TEST_MOCK_BIN}:${PATH}"
}

teardown_test_env() {
    export PATH="${ORIGINAL_PATH:-$PATH}"
    if [[ -n "${TEST_TMPDIR:-}" && -d "${TEST_TMPDIR}" ]]; then
        rm -rf "${TEST_TMPDIR}"
    fi
}

trap teardown_test_env EXIT

# Assertion helpers
assert_eq() {
    local expected="$1"
    local actual="$2"
    local desc="${3:-assert_eq}"

    (( TESTS_RUN++ )) || true
    if [[ "$expected" == "$actual" ]]; then
        (( TESTS_PASSED++ )) || true
        printf "  ${GREEN}✓${NC} %s\n" "$desc"
    else
        (( TESTS_FAILED++ )) || true
        printf "  ${RED}✗${NC} %s\n" "$desc"
        printf "    Expected: '%s'\n" "$expected"
        printf "    Actual:   '%s'\n" "$actual"
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local desc="${3:-assert_contains}"

    (( TESTS_RUN++ )) || true
    if [[ "$haystack" == *"$needle"* ]]; then
        (( TESTS_PASSED++ )) || true
        printf "  ${GREEN}✓${NC} %s\n" "$desc"
    else
        (( TESTS_FAILED++ )) || true
        printf "  ${RED}✗${NC} %s\n" "$desc"
        printf "    Expected '%s' to contain '%s'\n" "$haystack" "$needle"
    fi
}

assert_matches() {
    local pattern="$1"
    local string="$2"
    local desc="${3:-assert_matches}"

    (( TESTS_RUN++ )) || true
    if [[ "$string" =~ $pattern ]]; then
        (( TESTS_PASSED++ )) || true
        printf "  ${GREEN}✓${NC} %s\n" "$desc"
    else
        (( TESTS_FAILED++ )) || true
        printf "  ${RED}✗${NC} %s\n" "$desc"
        printf "    Expected '%s' to match pattern '%s'\n" "$string" "$pattern"
    fi
}

assert_success() {
    local desc="$1"
    shift
    (( TESTS_RUN++ )) || true

    if "$@" >/dev/null 2>&1; then
        (( TESTS_PASSED++ )) || true
        printf "  ${GREEN}✓${NC} %s\n" "$desc"
    else
        (( TESTS_FAILED++ )) || true
        printf "  ${RED}✗${NC} %s (command failed unexpectedly)\n" "$desc"
    fi
}

assert_failure() {
    local desc="$1"
    shift
    (( TESTS_RUN++ )) || true

    if "$@" >/dev/null 2>&1; then
        (( TESTS_FAILED++ )) || true
        printf "  ${RED}✗${NC} %s (command succeeded unexpectedly)\n" "$desc"
    else
        (( TESTS_PASSED++ )) || true
        printf "  ${GREEN}✓${NC} %s\n" "$desc"
    fi
}

mock_command() {
    local cmd_name="$1"
    local mock_script="$2"
    local target="${TEST_MOCK_BIN}/${cmd_name}"

    cat <<MOCK_EOF > "$target"
#!/usr/bin/env bash
$mock_script
MOCK_EOF
    chmod +x "$target"
}

unmock_command() {
    local cmd_name="$1"
    rm -f "${TEST_MOCK_BIN}/${cmd_name}"
}

report_suite() {
    local suite_name="$1"
    echo ""
    echo "────────────────────────────────────────"
    echo "Suite: ${suite_name}"
    printf "Tests: %d | Passed: ${GREEN}%d${NC} | Failed: ${RED}%d${NC}\n" \
        "$TESTS_RUN" "$TESTS_PASSED" "$TESTS_FAILED"
    echo "────────────────────────────────────────"

    if (( TESTS_FAILED > 0 )); then
        return 1
    fi
    return 0
}
