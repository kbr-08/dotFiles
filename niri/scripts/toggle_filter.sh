#!/bin/bash

# Check if wlsunset is running
if pgrep -x "wlsunset" > /dev/null; then
    # If running, kill it (Turn OFF)
    pkill wlsunset
    notify-send "Blue Light Filter" "Disabled" -t 2000
else
    # If not running, start it forced to 3500K (Turn ON)
    wlsunset -t 3500 -T 4500 -l 0 -L 0 &
    notify-send "Blue Light Filter" "Enabled (3500K)" -t 2000
fi