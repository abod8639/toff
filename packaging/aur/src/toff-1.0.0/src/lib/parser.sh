#!/usr/bin/env bash
# toff — parser.sh
# Parses human-readable time strings into total seconds.
#
# Supported formats:
#   H.MM        → hours + minutes   (e.g. 1.30 = 1h 30m)
#   MM          → minutes only      (e.g. 90   = 90m)
#   HH:MM       → hours + minutes   (e.g. 1:30)
#   HH:MM:SS    → full duration     (e.g. 1:30:00)

# Usage: toff_parse_time <input>
# Outputs: total seconds (integer)
# Returns 1 on error (error message printed to stderr)
toff_parse_time() {
    local input="$1"
    local total_seconds=0

    # ── H.MM format (e.g. 1.30) ───────────────────────────────────────────
    if [[ "$input" =~ ^([0-9]+)\.([0-9]{1,2})$ ]]; then
        local hours="${BASH_REMATCH[1]}"
        local mins="${BASH_REMATCH[2]}"
        if (( 10#$mins >= 60 )); then
            printf 'toff: error: minutes part must be < 60 (got %s).\n' "$mins" >&2
            return 1
        fi
        total_seconds=$(( 10#$hours * 3600 + 10#$mins * 60 ))

    # ── HH:MM:SS format ───────────────────────────────────────────────────
    elif [[ "$input" =~ ^([0-9]+):([0-9]{2}):([0-9]{2})$ ]]; then
        local h="${BASH_REMATCH[1]}"
        local m="${BASH_REMATCH[2]}"
        local s="${BASH_REMATCH[3]}"
        if (( 10#$m >= 60 || 10#$s >= 60 )); then
            echo "toff: error: invalid time values in HH:MM:SS." >&2
            return 1
        fi
        total_seconds=$(( 10#$h * 3600 + 10#$m * 60 + 10#$s ))

    # ── HH:MM format ──────────────────────────────────────────────────────
    elif [[ "$input" =~ ^([0-9]+):([0-9]{2})$ ]]; then
        local h="${BASH_REMATCH[1]}"
        local m="${BASH_REMATCH[2]}"
        if (( 10#$m >= 60 )); then
            printf 'toff: error: minutes must be < 60 (got %s).\n' "$m" >&2
            return 1
        fi
        total_seconds=$(( 10#$h * 3600 + 10#$m * 60 ))

    # ── Plain minutes (e.g. 90) ───────────────────────────────────────────
    elif [[ "$input" =~ ^([0-9]+)$ ]]; then
        total_seconds=$(( 10#${BASH_REMATCH[1]} * 60 ))

    # ── Unknown ───────────────────────────────────────────────────────────
    else
        cat >&2 <<EOF
toff: error: unrecognized time format: '$input'

Supported formats:
  H.MM      e.g.  1.30   → 1 hour 30 minutes
  MM        e.g.  90     → 90 minutes
  HH:MM     e.g.  1:30   → 1 hour 30 minutes
  HH:MM:SS  e.g.  1:30:00
EOF
        return 1
    fi

    if (( total_seconds <= 0 )); then
        echo "toff: error: time must be greater than zero." >&2
        return 1
    fi

    echo "$total_seconds"
}
