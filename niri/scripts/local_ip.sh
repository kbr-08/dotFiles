#!/bin/bash

WWAN_IP=$(ip addr show wwan0 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)
if [ -n "$WWAN_IP" ]; then
    echo "󱄙 $WWAN_IP"
    exit 0
fi

WIFI_IP=$(ip addr show wlp0s20f3 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)
if [ -n "$WIFI_IP" ]; then
    echo "󰀂 $WIFI_IP"
    exit 0
fi

echo ""