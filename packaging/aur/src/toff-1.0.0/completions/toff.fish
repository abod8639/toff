# toff fish completion
# Place in: /usr/share/fish/vendor_completions.d/toff.fish

# Disable file completion by default (we handle it manually)
complete -c toff -f

# Options
complete -c toff -s b -l buffer      -d 'Extra buffer minutes after media ends (default: 2)' -r -a '0 1 2 3 5 10 15'
complete -c toff -s p -l playlist    -d 'Force playlist mode (sum all video durations)'
complete -c toff      -l no-playlist -d 'Disable playlist auto-detection'
complete -c toff -s n -l no-banner   -d 'Skip the banner animation'
complete -c toff -s q -l quiet       -d 'Suppress countdown display'
complete -c toff -s c -l cancel      -d 'Cancel a pending toff shutdown'
complete -c toff -s v -l version     -d 'Print version'
complete -c toff -s h -l help        -d 'Show help'

# Allow files and URLs as positional argument
complete -c toff -F
