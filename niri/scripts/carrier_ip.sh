#!/bin/bash
~/.config/niri/scripts/vpn_data.sh
source /tmp/waybar_vpn_cache.sh 2>/dev/null || exit 0
if [ "$WB_IS_WWAN" = "1" ]; then
    echo "󰈀 $WB_CARRIER_IP"
else
    echo " $WB_CARRIER_IP"
fi
