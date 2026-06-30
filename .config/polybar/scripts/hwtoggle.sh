#!/bin/bash

### Config ###

# Module: cpu | gpu | ram. Second arg "toggle" flips the view.
MOD="$1"
ACTION="$2"
STATE="/tmp/polybar-hw-${MOD}.mode"

### Toggle ###

# No hover in polybar, so left-click flips usage <-> temp and signals
# every instance (one per monitor) to redraw now.
if [ "$ACTION" = "toggle" ]; then
    MODE=usage
    [ -r "$STATE" ] && read -r MODE <"$STATE"
    if [ "$MODE" = "temp" ]; then echo usage >"$STATE"; else echo temp >"$STATE"; fi
    pkill -USR1 -f "hwtoggle.sh ${MOD}$" 2>/dev/null
    exit 0
fi

### Readers ###
# Usage readers set OUT in this shell (no fork, keeps CPU delta state).
# Temp readers print, so they are captured with $().

PREV_IDLE=0
PREV_TOTAL=0

# CPU usage % over the interval, from /proc/stat
cpu_usage() {
    local a b c d e f g idle total didle dtotal
    read -r _ a b c d e f g _ </proc/stat
    idle=$((d + e))
    total=$((a + b + c + d + e + f + g))
    didle=$((idle - PREV_IDLE))
    dtotal=$((total - PREV_TOTAL))
    PREV_IDLE=$idle
    PREV_TOTAL=$total
    if [ "$dtotal" -le 0 ]; then OUT=0; else OUT=$((100 * (dtotal - didle) / dtotal)); fi
}

# RAM usage % from /proc/meminfo
ram_usage() {
    local k v t a
    while read -r k v _; do
        case "$k" in
        MemTotal:) t=$v ;;
        MemAvailable:) a=$v; break ;;
        esac
    done </proc/meminfo
    OUT=$((100 * (t - a) / t))
}

# CPU package temp (k10temp Tctl)
cpu_temp() { sensors -u 'k10temp-*' 2>/dev/null | awk '/^Tctl:/{f=1} f&&/_input:/{printf "%.0f",$2; exit}'; }

# Hottest RAM module (spd5118)
ram_temp() { sensors -u 'spd5118-*' 2>/dev/null | awk '/_input:/{if($2>m)m=$2} END{if(m!="")printf "%.0f",m}'; }

# GPU via nvidia-smi
gpu_usage() { nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -n1; }
gpu_temp() { nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -n1; }

### Loop ###

trap 'true' USR1 # wakes the sleep so a click redraws at once
cpu_usage        # prime the CPU delta

while true; do
    MODE=usage
    [ -r "$STATE" ] && read -r MODE <"$STATE"
    case "$MOD" in
    cpu) if [ "$MODE" = temp ]; then OUT=$(cpu_temp); S=°C; else cpu_usage; S=%; fi ;;
    ram) if [ "$MODE" = temp ]; then OUT=$(ram_temp); S=°C; else ram_usage; S=%; fi ;;
    gpu) if [ "$MODE" = temp ]; then OUT=$(gpu_temp); S=°C; else OUT=$(gpu_usage); S=%; fi ;;
    esac
    printf '%s%s\n' "${OUT:-?}" "$S"
    sleep 2 &
    wait $!
done
