#!/bin/bash

TMUX_DIR="$HOME/bin/etc/tmux"
SESSION_DIR="$TMUX_DIR/sessions"
NAMED="$SESSION_DIR/tmux.named"

errorExit() {
    echo "$1" >&2
    exit 1
}


listOneSession() {
    ssFile="$( basename $1 )"
    ssId="${ssFile##*.}"
    if [ "$ssId" != "default" ] && \
        [ "$ssId" != "named" ] && \
        grep -q "^session=" "$1" ;
    then
        ssDesc="$( grep "desc:" $1 | sed "s,^ *# *desc *: *\\(.*\\)$,\\1," )"
        ssIdF="$( printf '%-8s' $ssId )"
        echo "$ssIdF : $ssDesc"
    fi
}


listSessions() {
    echo "Predefined session:"
    for ss in "$SESSION_DIR"/tmux.* ; do
        listOneSession $ss
    done
    exit 0
}


listRunning() {
    echo "Running sessions:"
    tmux ls
    echo
    exit 0
}

# Special cases:
# - list predefined sessions
[ "$1" = "-s" ] && \
    listSessions

# - list running sessions
[ "$1" = "-l" ] && \
    listRunning

# - dettach from current session
if [ "$1" = "-d" ] ; then
    [ -n "$TMUX" ] && \
        exec tmux detach-client || \
        exit 0
fi

# - call tmux directly with user params
[ "$1" = "-" ] && \
    exec tmux ${@:2}

# Standard cases: calling, creating sessions, attaching to sessions...
[ "$1" != "" ] && \
    SESSION_ID="$1" || \
    SESSION_ID="default"

[ "$SESSION_ID" = "named" ] && \
    errorExit "The id 'named' is reserved and cannot be used to start the tmux session via this script."

echo "$SESSION_ID" | grep -q "\\( \\|\\\\t\\)" && \
    errorExit "Session id must contain neither spaces nor tabs."

SESS_CONF="$SESSION_DIR/tmux.$SESSION_ID"
if [ -n "$TMUX" ]; then
    TM_CURR_SESS="$( tmux display-message -p '#S' )"
    if [ "$SESSION_ID" != "default" ]; then
        [ "$TM_CURR_SESS" = "$SESSION_ID" ] && exit 0
        tmux run-shell \
            "( [[ -f $SESS_CONF ]] && /bin/bash ${SESS_CONF} || /bin/bash ${NAMED} ${SESSION_ID} ) || true"
        tmux switch-client -t $SESSION_ID
    else
        tmux run-shell "/bin/bash $SESS_CONF || true"
        tmux switch-client -t $( tmux show-environment -g LAST_ANON_SESS | cut -d= -f2 )
    fi
else
    [[ -f $SESS_CONF ]] && \
        exec /bin/bash "$SESS_CONF" || \
        exec /bin/bash ${NAMED} ${SESSION_ID}
fi

exit 0
