#!/usr/bin/env bash
set -u

# Pick the first controller explicitly
CTL="$(bluetoothctl list | awk 'NR==1{print $2}')"

if [ -z "${CTL:-}" ]; then
  echo "No Bluetooth controller found (bluetoothctl list is empty)" >&2
  exit 1
fi

STATE="$(bluetoothctl show "$CTL" | awk '/Powered:/ {print $2}')"

if [ "$STATE" = "yes" ]; then
  bluetoothctl power off
else
  bluetoothctl power on
fi
