#!/usr/bin/env bash
# toff — countdown.sh
# Countdown timer display and duration formatting utilities.

# Format seconds → human-readable string (e.g. "1h 30m 00s")
toff_format_duration() {
    local seconds="$1"
    local h=$(( seconds / 3600 ))
    local m=$(( (seconds % 3600) / 60 ))
    local s=$(( seconds % 60 ))

    if (( h > 0 )); then
        printf '%dh %02dm %02ds' "$h" "$m" "$s"
    elif (( m > 0 )); then
        printf '%dm %02ds' "$m" "$s"
    else
        printf '%ds' "$s"
    fi
}

# Called when user presses Ctrl+C during countdown
_toff_countdown_trap() {
    printf '\n'
    local answer
    read -r -p "  Cancel shutdown? [y/N] " answer < /dev/tty
    if [[ "${answer,,}" == "y" ]]; then
        toff_cancel
        printf '\n  Shutdown cancelled.\n'
        exit 0
    fi
    echo "  Resuming countdown..."
    # Re-arm the trap
    trap '_toff_countdown_trap' INT
}

# Show live countdown: HH:MM:SS with expected poweroff time
# Usage: toff_show_countdown <total_seconds>
toff_show_countdown() {
    local total_seconds="$1"
    local remaining="$total_seconds"

    trap '_toff_countdown_trap' INT

    printf '\n  Press \033[1mCtrl+C\033[0m to cancel\n'
    printf '  ─────────────────────────────────────\n'

    while (( remaining > 0 )); do
        local h=$(( remaining / 3600 ))
        local m=$(( (remaining % 3600) / 60 ))
        local s=$(( remaining % 60 ))
        local eta
        eta=$(date -d "+${remaining} seconds" '+%H:%M:%S' 2>/dev/null || echo "--:--:--")
        printf '\r  \033[1;32m%02d:%02d:%02d\033[0m  ─  poweroff at \033[1;33m%s\033[0m ' \
            "$h" "$m" "$s" "$eta"
        sleep 1
        (( remaining-- )) || true
    done

    printf '\n'
    trap - INT
}
