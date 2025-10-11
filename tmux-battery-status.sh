#!/bin/bash

CACHE_DIR=/tmp/$USER-tmux-status-cache
CACHE=$CACHE_DIR/battery-status-cache
NOW=$( date +%s )

if [[ ! -d $CACHE_DIR ]]; then
    mkdir -p "$CACHE_DIR" || { echo "Bt: N/A" ; exit 1 ; }
fi

if [[ ! -f $CACHE ]] || (( $( stat -c %Y "$CACHE" ) + 5 < NOW )); then
    # BATT=$( acpi -b 2> /dev/null | cut -d, -f2 | tr -d ' ' || echo 'N/A' )
    BAT_PATH=/sys/class/power_supply/BAT0
    if [[ -d $BAT_PATH ]]; then
        CAPACITY=$(cat "$BAT_PATH/capacity" 2>/dev/null)
        STATUS=$(cat "$BAT_PATH/status" 2>/dev/null)

        ST=$STATUS
        case "$STATUS" in
            "Full"|"Not charging")
                ST="="
                ;;
            "Charging")
                ST="+"
                ;;
            "Discharging")
                ST="-"
                ;;
        esac

        if   (( CAPACITY > 70 )); then
            COLOR="lightgreen"
        elif (( CAPACITY > 49 )); then
            COLOR="colour154"
        elif (( CAPACITY > 34 )); then
            COLOR="colour226"
        elif (( CAPACITY > 19 )); then
            COLOR="orange"
        else
            COLOR="colour9"
        fi

        BATT="#[fg=$COLOR]${CAPACITY}% ($ST)#[default]"
    else
        BATT="N/A"
    fi

    echo "Bt: $BATT" > "$CACHE"
fi

cat "$CACHE"
