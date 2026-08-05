#!/usr/bin/env bash
# toff — shutdown.sh
# Cross-distro safe shutdown scheduler and canceller.
#
# Init system support:
#   systemd  → systemctl poweroff  (no sudo needed via logind)
#   OpenRC   → poweroff / shutdown
#   runit    → poweroff / shutdown
#   s6       → poweroff / shutdown
#   SysV     → shutdown -h now
#   fallback → background sleep + poweroff

# ── Init system detection ─────────────────────────────────────────────────

_toff_detect_init() {
    if [[ -d /run/systemd/system ]]; then
        echo "systemd"
    elif command -v openrc-run &>/dev/null || [[ -f /sbin/openrc ]]; then
        echo "openrc"
    elif command -v runit &>/dev/null || [[ -d /etc/runit ]]; then
        echo "runit"
    elif command -v s6-svscan &>/dev/null || [[ -d /etc/s6 ]]; then
        echo "s6"
    else
        echo "sysv"
    fi
}

# ── Poweroff command resolution ───────────────────────────────────────────

# Returns the best available poweroff command for this system.
_toff_poweroff_cmd() {
    local init="$1"
    case "$init" in
        systemd)
            # logind allows the active user to poweroff without sudo
            echo "systemctl poweroff"
            ;;
        *)
            # Try in order of availability; the first that works wins at runtime
            if command -v poweroff &>/dev/null; then
                echo "poweroff"
            elif command -v shutdown &>/dev/null; then
                echo "shutdown -P now"
            else
                echo "halt -p"
            fi
            ;;
    esac
}

# ── Sudo management ───────────────────────────────────────────────────────

# Cache sudo credentials upfront and keep them alive in the background.
# Only called on non-systemd systems where sudo is needed.
_toff_prepare_sudo() {
    if ! sudo -v 2>/dev/null; then
        echo "toff: error: sudo authentication failed." >&2
        echo "toff: hint:  add the following to /etc/sudoers (via visudo):" >&2
        echo "             %wheel ALL=(ALL) NOPASSWD: /usr/bin/poweroff, /usr/bin/shutdown, /usr/bin/halt" >&2
        return 1
    fi

    # Keepalive: refresh sudo every 50s in background
    (
        while true; do
            sudo -n true 2>/dev/null || break
            sleep 50
        done
    ) &
    _TOFF_SUDO_KEEPALIVE_PID=$!
    disown "$_TOFF_SUDO_KEEPALIVE_PID" 2>/dev/null || true
    echo "$_TOFF_SUDO_KEEPALIVE_PID" > "${TOFF_STATE_DIR}/keepalive.pid"
}

# ── Scheduling ────────────────────────────────────────────────────────────

# Schedule system shutdown after <seconds> seconds.
# Usage: toff_schedule <seconds>
toff_schedule() {
    local seconds="$1"

    mkdir -p "$TOFF_STATE_DIR"

    local init
    init=$(_toff_detect_init)

    local poweroff_cmd
    poweroff_cmd=$(_toff_poweroff_cmd "$init")

    # ── Strategy 1: system shutdown command (survives terminal close) ─────
    if command -v shutdown &>/dev/null; then
        local minutes=$(( (seconds + 59) / 60 ))

        # Try -P (poweroff) first, then -h (halt/poweroff)
        if sudo shutdown -P "+${minutes}" &>/dev/null 2>&1 \
        || sudo shutdown -h "+${minutes}" &>/dev/null 2>&1; then
            echo "SHUTDOWN" > "${TOFF_STATE_DIR}/method"
            echo "$minutes" > "${TOFF_STATE_DIR}/minutes"
            return 0
        fi
    fi

    # ── Strategy 2: systemd transient timer (precise, survives terminal) ──
    if [[ "$init" == "systemd" ]] && command -v systemd-run &>/dev/null; then
        if systemd-run \
            --on-active="${seconds}s" \
            --timer-property=AccuracySec=1s \
            --unit=toff-shutdown.timer \
            -- systemctl poweroff &>/dev/null 2>&1; then
            echo "SYSTEMD_RUN" > "${TOFF_STATE_DIR}/method"
            return 0
        fi
    fi

    # ── Strategy 3: `at` command (cross-distro, survives terminal close) ──
    if command -v at &>/dev/null; then
        local minutes=$(( (seconds + 59) / 60 ))
        local sudo_prefix=""
        [[ "$init" != "systemd" ]] && sudo_prefix="sudo "
        if echo "${sudo_prefix}${poweroff_cmd}" \
           | at "now + ${minutes} minutes" &>/dev/null 2>&1; then
            echo "AT" > "${TOFF_STATE_DIR}/method"
            return 0
        fi
    fi

    # ── Strategy 4: background sleep (universal fallback) ─────────────────
    if [[ "$init" != "systemd" ]]; then
        _toff_prepare_sudo || return 1
        poweroff_cmd="sudo ${poweroff_cmd}"
    fi

    (
        sleep "$seconds"
        eval "$poweroff_cmd"
    ) &
    local timer_pid=$!
    disown "$timer_pid" 2>/dev/null || true
    echo "$timer_pid" > "${TOFF_STATE_DIR}/timer.pid"
    echo "SLEEP" > "${TOFF_STATE_DIR}/method"
}

# ── Cancellation ──────────────────────────────────────────────────────────

# Cancel a pending toff shutdown.
toff_cancel() {
    local method=""
    [[ -f "${TOFF_STATE_DIR}/method" ]] && method=$(< "${TOFF_STATE_DIR}/method")

    case "$method" in
        SHUTDOWN)
            if sudo shutdown -c 2>/dev/null; then
                echo "  System shutdown cancelled."
            else
                echo "toff: could not cancel via shutdown -c." >&2
            fi
            ;;
        SYSTEMD_RUN)
            systemctl stop toff-shutdown.timer 2>/dev/null \
                && echo "  Systemd timer cancelled." \
                || echo "toff: systemd timer not found." >&2
            ;;
        AT)
            # atrm the last job; store job number for reliable removal
            local atq_out
            atq_out=$(atq 2>/dev/null | tail -1)
            local job_id
            job_id=$(awk '{print $1}' <<< "$atq_out")
            if [[ -n "$job_id" ]]; then
                atrm "$job_id" && echo "  at job #${job_id} cancelled."
            else
                echo "toff: no at job found." >&2
            fi
            ;;
        SLEEP)
            if [[ -f "${TOFF_STATE_DIR}/timer.pid" ]]; then
                local pid
                pid=$(< "${TOFF_STATE_DIR}/timer.pid")
                if kill "$pid" 2>/dev/null; then
                    echo "  Timer process cancelled (PID ${pid})."
                else
                    echo "toff: timer process not found (may have already fired)." >&2
                fi
            fi
            # Kill sudo keepalive if present
            if [[ -f "${TOFF_STATE_DIR}/keepalive.pid" ]]; then
                kill "$(< "${TOFF_STATE_DIR}/keepalive.pid")" 2>/dev/null || true
            fi
            ;;
        *)
            # Unknown method — try all cancellation strategies
            sudo shutdown -c 2>/dev/null || true
            [[ -f "${TOFF_STATE_DIR}/timer.pid" ]] \
                && kill "$(< "${TOFF_STATE_DIR}/timer.pid")" 2>/dev/null || true
            echo "toff: no active timer state found."
            ;;
    esac

    rm -rf "${TOFF_STATE_DIR}"
}
