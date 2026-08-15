#compdef toff
# toff zsh completion
# Place in: /usr/share/zsh/site-functions/_toff

_toff() {
    local -a opts

    opts=(
        '(-b --buffer)'{-b,--buffer}'[Extra buffer minutes after media ends (default: 2)]:minutes:(0 1 2 3 5 10 15)'
        '(-p --playlist)'{-p,--playlist}'[Force playlist mode — sum all video durations]'
        '--no-playlist[Disable playlist auto-detection]'
        '(-n --no-banner)'{-n,--no-banner}'[Skip the banner animation]'
        '(-q --quiet)'{-q,--quiet}'[Suppress countdown display]'
        '(-c --cancel)'{-c,--cancel}'[Cancel a pending toff shutdown]'
        '(-v --version)'{-v,--version}'[Print version]'
        '(-h --help)'{-h,--help}'[Show help]'
        ':time or URL:_urls'
    )

    _arguments -C $opts
}

_toff "$@"
