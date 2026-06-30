#!/bin/sh

# Red/green desktop notification on power outage / return. Runs in the X
# session (autostarted from bspwmrc) so notify-send reaches the daemon.
# Low-battery shutdown is handled separately by NUT's upsmon.

UPS="${UPS:-ups@localhost}"
ID=97531 # fixed replace-id so UPS notifications don't stack

notify() {
    # urgency color icon summary body
    notify-send -a UPS -u "$1" -r "$ID" -i "$3" \
        -h "string:frcolor:$2" -h string:fgcolor:#ffffff -h string:bgcolor:#1a1a1a \
        "$4" "$5"
}

# Seed current state silently so login doesn't fire a notification.
case "$(upsc "$UPS" ups.status 2>/dev/null)" in *OB*) WASBATT=1 ;; *) WASBATT=0 ;; esac
LBWARNED=0

while sleep 3; do
    ST=$(upsc "$UPS" ups.status 2>/dev/null)
    [ -z "$ST" ] && continue

    case "$ST" in *OB*) ONBATT=1 ;; *) ONBATT=0 ;; esac

    if [ "$ONBATT" = 1 ] && [ "$WASBATT" = 0 ]; then
        notify critical "#9b0000" battery-caution "Power Outage" "Running on UPS battery"
    elif [ "$ONBATT" = 0 ] && [ "$WASBATT" = 1 ]; then
        notify normal "#2ea043" battery-full "Power Restored" "Back on mains power"
        LBWARNED=0
    fi
    WASBATT=$ONBATT

    # Low-battery heads-up; upsmon will shut the system down.
    case "$ST" in
    *LB*)
        if [ "$LBWARNED" = 0 ]; then
            notify critical "#ff0000" battery-empty "Battery Low" "Saving and shutting down soon"
            LBWARNED=1
        fi
        ;;
    esac
done
