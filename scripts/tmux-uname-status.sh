#!/bin/bash

CACHE_DIR=/tmp/$USER-tmux-status-cache
CACHE=$CACHE_DIR/uname-cache
NOW=$( date +%s )

if [[ ! -d $CACHE_DIR ]]; then
    mkdir -p "$CACHE_DIR" || { echo "N/A" ; exit 1 ; }
fi

if [[ ! -f $CACHE ]] || (( $( stat -c %Y "$CACHE" ) + 600 < NOW )); then
    USER=$( whoami )
    MACHINE=$( uname -a | cut -d ' ' -f 2,3 | cut -d '-' -f 1,2 )

    echo "$USER@$MACHINE" > "$CACHE"
fi

cat "$CACHE"
