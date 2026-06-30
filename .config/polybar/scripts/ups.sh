#!/bin/bash

### Config ###

# NUT device name (the [section] in /etc/nut/ups.conf). Second arg "toggle"
# flips line <-> battery voltage. Polls upsd over localhost.
# This UPS reports no battery.charge (%), so we show voltages instead.
UPS="${UPS:-ups@localhost}"
ACTION="$1"
STATE="/tmp/polybar-ups.mode"

### Toggle ###

# No hover in polybar, so left-click flips line <-> battery voltage and
# signals every instance (one per monitor) to redraw now.
if [ "$ACTION" = "toggle" ]; then
    MODE=line
    [ -r "$STATE" ] && read -r MODE <"$STATE"
    if [ "$MODE" = "batt" ]; then echo line >"$STATE"; else echo batt >"$STATE"; fi
    pkill -USR1 -f "ups.sh$" 2>/dev/null
    exit 0
fi

### Loop ###

trap 'true' USR1 # wakes the sleep so a click redraws at once

while true; do
    MODE=line
    [ -r "$STATE" ] && read -r MODE <"$STATE"

    # One query, parse the keys we need.
    DUMP=$(upsc "$UPS" 2>/dev/null)
    STATUS=$(printf '%s\n' "$DUMP" | awk -F': ' '/^ups.status:/{print $2}')
    INV=$(printf '%s\n' "$DUMP" | awk -F': ' '/^input.voltage:/{printf "%.0f",$2}')
    BATV=$(printf '%s\n' "$DUMP" | awk -F': ' '/^battery.voltage:/{printf "%.1f",$2}')

    if [ -z "$STATUS" ]; then
        # Driver/server not up yet, or no data.
        printf '%%{F#595959}󰂑 N/A%%{F-}\n'
        sleep 5 &
        wait $!
        continue
    fi

    # On battery / low battery are alerts.
    case " $STATUS " in
    *" LB "* | *" OB "*) ALERT=1 ;;
    *) ALERT=0 ;;
    esac

    if [ "$ALERT" = 1 ]; then
        # On battery: line voltage is gone; show battery voltage in red.
        printf '%%{F#ff0000}󰂃 %sV%%{F-}\n' "${BATV:-?}"
    elif [ "$MODE" = "batt" ]; then
        printf '󰁹 %sV\n' "${BATV:-?}"
    else
        printf '󱐋 %sV\n' "${INV:-?}"
    fi

    sleep 5 &
    wait $!
done
