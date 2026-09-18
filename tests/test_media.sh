#!/usr/bin/env bash
# test_media.sh — Tests for toff media.sh

source "$(dirname "${BASH_SOURCE[0]}")/test_helper.bash"
setup_test_env

source "${TOFF_LIB_DIR}/media.sh"

echo "Running Media & URL Tests..."

# Test toff_is_url
assert_success "detect https url" toff_is_url "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
assert_success "detect http url" toff_is_url "http://example.com/video"
assert_success "detect short url" toff_is_url "https://youtu.be/dQw4w9WgXcQ"
assert_failure "reject non-url time string (1.30)" toff_is_url "1.30"
assert_failure "reject regular word" toff_is_url "shutdown"
assert_failure "reject empty url" toff_is_url ""

# Test toff_is_playlist_url
assert_success "detect youtube playlist with list=" toff_is_playlist_url "https://www.youtube.com/watch?v=123&list=PL456"
assert_success "detect playlist path" toff_is_playlist_url "https://www.youtube.com/playlist?list=PL456"
assert_success "detect soundcloud sets" toff_is_playlist_url "https://soundcloud.com/artist/sets/my-album"
assert_success "detect album path" toff_is_playlist_url "https://music.site/album/123"
assert_failure "reject single youtube video" toff_is_playlist_url "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
assert_failure "reject single soundcloud track" toff_is_playlist_url "https://soundcloud.com/artist/single-track"

# Test _toff_duration_to_seconds
assert_eq "45" "$(_toff_duration_to_seconds "45")" "duration plain seconds"
assert_eq "90" "$(_toff_duration_to_seconds "01:30")" "duration MM:SS format"
assert_eq "3600" "$(_toff_duration_to_seconds "60:00")" "duration 60:00"
assert_eq "5415" "$(_toff_duration_to_seconds "01:30:15")" "duration HH:MM:SS format"
assert_eq "0" "$(_toff_duration_to_seconds "00:00")" "duration 00:00"
assert_failure "fail on invalid 4-part duration" _toff_duration_to_seconds "01:02:03:04"

# Test _toff_require_yt_dlp when missing
mock_command "which" "exit 1"
# Ensure yt-dlp is not found by overriding command -v or isolating PATH
unmock_command "which"

# Mock yt-dlp for successful single video
mock_command "yt-dlp" '
if [[ "$*" == *"--get-duration"* ]]; then
    echo "04:30"
    exit 0
fi
exit 0
'
assert_eq "270" "$(toff_get_url_duration "https://youtu.be/test" "false")" "fetch single video duration (04:30 = 270s)"

# Mock yt-dlp for successful playlist
mock_command "yt-dlp" '
if [[ "$*" == *"--get-duration"* ]]; then
    echo "02:00"
    echo "03:15"
    echo "01:45"
    exit 0
fi
exit 0
'
assert_eq "420" "$(toff_get_url_duration "https://youtube.com/playlist?list=PL123" "true" 2>/dev/null)" "fetch playlist duration sum (120+195+105 = 420s)"

# Mock yt-dlp failure
mock_command "yt-dlp" 'exit 1'
assert_failure "handle yt-dlp failure gracefully" toff_get_url_duration "https://youtu.be/failed" "false"

# Mock yt-dlp returning empty
mock_command "yt-dlp" 'echo ""'
assert_failure "handle yt-dlp empty response" toff_get_url_duration "https://youtu.be/empty" "false"

report_suite "media.sh"
