_tm_complete()
{
    local cur
    cur="${COMP_WORDS[COMP_CWORD]}"

    local predefined running all

    # predefined sessions (script names)
    predefined=$(
        cd "$HOME/bin/etc/tmux/sessions" 2>/dev/null &&
        for f in tmux.* ; do
            [ "$f" = "tmux.default" ] || \
                [ "$f" = "tmux.named" ] || \
                [ "$f" = "tmux.example" ] || \
                ( [ -e "$f" ] && printf '%s\n' "${f#tmux.}" )
        done
    )

    # running tmux sessions
    running=$(tmux list-sessions -F '#S' 2>/dev/null)

    # merge and unique (preserve order)
    all=$(printf "%s\n%s\n" "$predefined" "$running" | awk '!seen[$0]++')

    COMPREPLY=($(compgen -W "$all" -- "$cur"))
}

complete -F _tm_complete tm

