#!/bin/bash

if ip link show | grep -q "pvpnksintrf.*UP"; then
    STATUS=$(protonvpn status)
    SERVER=$(echo "$STATUS" | grep "Server:" | awk '{print $2}')
    CITY=$(echo "$STATUS" | grep "Server:" | awk '{print $4}' | tr -d ',')
    echo "{\"text\": \"󰒃 ProtonVPN $SERVER $CITY\", \"class\": \"connected\"}"
elif ip link show nordlynx 2>/dev/null | grep -q "UP"; then
    STATUS=$(nordvpn status)
    SERVER=$(echo "$STATUS" | grep "Server:" | awk '{print $2, $3}')
    CITY=$(echo "$STATUS" | grep "City:" | awk '{print $2}')
    IP=$(echo "$STATUS" | grep "^IP:" | awk '{print $2}')
    echo "{\"text\": \"󰒃 NordVPN $SERVER $CITY $IP\", \"class\": \"connected\"}"
else
    echo "{\"text\": \"No VPN\", \"class\": \"disconnected\"}"
fi