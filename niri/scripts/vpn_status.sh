#!/bin/bash

CACHE_FILE="/tmp/waybar_geoip_cache"
CACHE_AGE=300  # 5 minutes

get_geoip() {
    if [ -f "$CACHE_FILE" ] && [ $(( $(date +%s) - $(stat -c %Y "$CACHE_FILE") )) -lt $CACHE_AGE ]; then
        cat "$CACHE_FILE"
    else
        RESULT=$(curl -s "http://ip-api.com/json")
        echo "$RESULT" > "$CACHE_FILE"
        echo "$RESULT"
    fi
}

if ip link show | grep -q "pvpnksintrf.*UP"; then
    STATUS=$(protonvpn status 2>/dev/null)
    TUNNEL_IP=$(ip addr show tun0 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)
    if echo "$STATUS" | grep -q "Server:"; then
        SERVER=$(echo "$STATUS" | grep "Server:" | awk '{print $2}')
        CITY=$(echo "$STATUS" | grep "Server:" | awk '{print $4}' | tr -d ',')
        echo "{\"text\": \"󰒃 ProtonVPN $SERVER $CITY $TUNNEL_IP\", \"class\": \"connected\"}"
    else
        CONN=$(nmcli -t -f NAME,TYPE connection show --active | grep ":vpn" | head -1 | cut -d: -f1)
        SERVER=$(echo "$CONN" | awk '{print $2}')
        GEOIP=$(get_geoip)
        CITY=$(echo "$GEOIP" | grep -o '"city":"[^"]*"' | cut -d'"' -f4)
        REGION=$(echo "$GEOIP" | grep -o '"region":"[^"]*"' | cut -d'"' -f4)
        ZIP=$(echo "$GEOIP" | grep -o '"zip":"[^"]*"' | cut -d'"' -f4)
        ISP=$(echo "$GEOIP" | grep -o '"isp":"[^"]*"' | cut -d'"' -f4)
        echo "{\"text\": \"󰒃 ProtonVPN $SERVER $CITY $REGION $ZIP $ISP $TUNNEL_IP \", \"class\": \"connected\"}"
    fi
elif ip link show nordlynx 2>/dev/null | grep -q "UP"; then
    STATUS=$(nordvpn status)
    SERVER=$(echo "$STATUS" | grep "Server:" | awk '{print $2, $3}')
    CITY=$(echo "$STATUS" | grep "City:" | awk '{print $2}')
    IP=$(echo "$STATUS" | grep "^IP:" | awk '{print $2}')
    echo "{\"text\": \"󰒃 NordVPN $SERVER $CITY $IP\", \"class\": \"connected\"}"
else
    echo "{\"text\": \"No VPN\", \"class\": \"disconnected\"}"
fi
