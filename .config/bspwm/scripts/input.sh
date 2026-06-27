#! /bin/sh

# Re-applies input settings on startup and on device hotplug (inputplug).

# Repeat delay 300ms and rate 75ms
xset r rate 300 75

# Mouse acceleration
xset m 0 0
xinput set-prop "pointer:Compx 2.4G Wireless Receiver" "libinput Accel Profile Enabled" 0 1 0 2>/dev/null
xinput set-prop "pointer:Compx 2.4G Dual Mode Mouse"   "libinput Accel Profile Enabled" 0 1 0 2>/dev/null

# Layout
setxkbmap -layout us -option caps:none
