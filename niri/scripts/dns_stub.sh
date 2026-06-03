#!/bin/bash
~/.config/niri/scripts/vpn_data.sh
source /tmp/waybar_vpn_cache.sh 2>/dev/null || exit 0
echo "{\"text\": \"stub $WB_DNS_STUB\"}"
