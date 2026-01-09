#!/bin/bash

CACHE_DIR=/tmp/$USER-tmux-status-cache
CACHE=$CACHE_DIR/uptime-cache
NOW=$( date +%s )

if [[ ! -d $CACHE_DIR ]]; then
    mkdir -p "$CACHE_DIR" || { echo "N/A" ; exit 1 ; }
fi

if [[ ! -f $CACHE ]] || (( $( stat -c %Y "$CACHE" ) + 20 < NOW )); then
    UPT=$( awk '{d=int($1/86400); h=int(($1%86400)/3600); m=int(($1%3600)/60);
           if(d>0) printf "%dd %02d:%02d\n", d,h,m; else printf "%02d:%02d\n", h,m}' \
               /proc/uptime )

    echo "up $UPT" > "$CACHE"
fi

cat "$CACHE"
