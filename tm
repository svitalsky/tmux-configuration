#!/bin/bash

TMUX_DIR="$HOME/bin/etc/tmux"
NAMED="$TMUX_DIR/tmux.named"

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
    echo "Running sessions:"
    tmux ls
    echo
    echo "Predefined session:"
    for ss in "$TMUX_DIR"/tmux.* ; do
        listOneSession $ss
    done
    exit 0
}


[ "$1" = "-l" ] && \
    listSessions

[ "$1" = "-" ] && \
    exec tmux ${@:2}

[ "$1" != "" ] && \
    SESSION_ID="$1" || \
    SESSION_ID="default"

[ "$SESSION_ID" = "named" ] && \
    errorExit "The id 'named' is reserved and cannot be used to start the tmux session via this script."

echo "$SESSION_ID" | grep -q "\\( \\|\\\\t\\)" && \
    errorExit "Session id must contain neither spaces nor tabs."

SESS_CONF="$TMUX_DIR/tmux.$SESSION_ID"
[[ -f $SESS_CONF ]] && \
    exec /bin/bash "$SESS_CONF" || \
    exec /bin/bash ${NAMED} ${SESSION_ID}
