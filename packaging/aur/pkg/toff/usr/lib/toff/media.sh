#!/usr/bin/env bash
# toff — media.sh
# Extracts media duration from URLs using yt-dlp.
# Supports: YouTube videos, playlists, SoundCloud, and 1000+ sites.

# ── URL detection ─────────────────────────────────────────────────────────

# Returns 0 if input looks like a URL (http/https)
toff_is_url() {
    [[ "$1" =~ ^https?:// ]]
}

# Returns 0 if the URL appears to be a playlist/collection
toff_is_playlist_url() {
    local url="$1"
    # YouTube playlists, SoundCloud sets, etc.
    [[ "$url" =~ (list=|/playlist\?|/sets/|/album/) ]]
}

# ── Internal helpers ─────────────────────────────────────────────────────

# Verify yt-dlp is installed; print helpful error if not
_toff_require_yt_dlp() {
    if ! command -v yt-dlp &>/dev/null; then
        cat >&2 <<'EOF'
toff: error: yt-dlp is required for URL support but is not installed.

Install it with:
  Arch Linux:    sudo pacman -S yt-dlp
  Debian/Ubuntu: sudo apt install yt-dlp
  Fedora:        sudo dnf install yt-dlp
  pip (any):     pip install -U yt-dlp
EOF
        return 1
    fi
}

# Parse a duration string (HH:MM:SS, MM:SS, or SS) into total seconds.
# Handles both colon-separated and plain integer formats.
_toff_duration_to_seconds() {
    local duration="$1"
    local seconds=0

    # yt-dlp may return a plain integer (seconds) for some extractors
    if [[ "$duration" =~ ^[0-9]+$ ]]; then
        echo "$duration"
        return
    fi

    # Colon-separated: HH:MM:SS or MM:SS
    local IFS=':'
    local -a parts
    read -ra parts <<< "$duration"
    local len="${#parts[@]}"

    case "$len" in
        1) seconds=$(( 10#${parts[0]} )) ;;
        2) seconds=$(( 10#${parts[0]} * 60  + 10#${parts[1]} )) ;;
        3) seconds=$(( 10#${parts[0]} * 3600 + 10#${parts[1]} * 60 + 10#${parts[2]} )) ;;
        *)
            echo "toff: warning: unexpected duration format: '$duration'" >&2
            echo "0"; return 1 ;;
    esac

    echo "$seconds"
}

# ── Public API ────────────────────────────────────────────────────────────

# Fetch the total duration (in seconds) for a URL.
# Usage: toff_get_url_duration <url> <playlist:true|false>
# Outputs: integer seconds
toff_get_url_duration() {
    local url="$1"
    local playlist="${2:-false}"

    _toff_require_yt_dlp || return 1

    local total_seconds=0
    local count=0

    if [[ "$playlist" == "true" ]]; then
        printf '  Fetching playlist info...\n' >&2

        # yt-dlp prints one duration per line for playlists
        while IFS= read -r dur; do
            [[ -z "$dur" ]] && continue
            local s
            s=$(_toff_duration_to_seconds "$dur") || continue
            total_seconds=$(( total_seconds + s ))
            (( count++ )) || true
        done < <(yt-dlp --get-duration "$url" 2>/dev/null)

        if (( count == 0 )); then
            echo "toff: error: no durations fetched from playlist. Check the URL." >&2
            return 1
        fi

        printf '  Found %d video(s) in playlist.\n' "$count" >&2
    else
        local duration
        duration=$(yt-dlp --no-playlist --get-duration "$url" 2>/dev/null) || {
            echo "toff: error: yt-dlp failed to fetch media info." >&2
            echo "toff: tip:   verify the URL is accessible and yt-dlp is up to date." >&2
            return 1
        }

        if [[ -z "$duration" ]]; then
            echo "toff: error: yt-dlp returned empty duration." >&2
            return 1
        fi

        total_seconds=$(_toff_duration_to_seconds "$duration") || return 1
    fi

    if (( total_seconds == 0 )); then
        echo "toff: error: computed duration is 0 seconds." >&2
        return 1
    fi

    echo "$total_seconds"
}
