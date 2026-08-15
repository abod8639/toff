# toff bash completion
# Place in: /usr/share/bash-completion/completions/toff

_toff_completion() {
    local cur prev words cword
    _init_completion || return

    local boolean_flags="-p --playlist --no-playlist -n --no-banner -q --quiet -c --cancel -v --version -h --help"
    local all_flags="-b --buffer ${boolean_flags}"

    case "$prev" in
        -b|--buffer)
            # Suggest common buffer values in minutes
            COMPREPLY=( $(compgen -W "0 1 2 3 5 10 15" -- "$cur") )
            return ;;
    esac

    if [[ "$cur" == -* ]]; then
        COMPREPLY=( $(compgen -W "$all_flags" -- "$cur") )
        return
    fi

    # For the positional argument, complete URLs or files
    _filedir
}

complete -F _toff_completion toff
