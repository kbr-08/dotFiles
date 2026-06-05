#!/bin/bash
~/.config/niri/scripts/vpn_data.sh
source /tmp/waybar_vpn_cache.sh 2>/dev/null || exit 0

GW=$(ip route | grep default | grep "$WB_CARRIER_IFACE" | awk '{print $3}' | head -1)

if [ "$WB_IS_WWAN" = "1" ]; then
    echo "{\"text\": \"󰈀 $WB_CARRIER_IFACE  $WB_CARRIER_IP  GW: $GW\"}"
else
    SSID=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2)
    [ -z "$SSID" ] && SSID="Unknown"
    echo "{\"text\": \"󰤨 $WB_CARRIER_IFACE  $WB_CARRIER_IP  $SSID  GW: $GW\"}"
fi
