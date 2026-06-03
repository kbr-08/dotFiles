#!/bin/bash
# Master VPN data collector - writes sourceable cache
# Called by all individual bar modules

CACHE_FILE="/tmp/waybar_vpn_cache.sh"
EXIT_IP_CACHE="/tmp/waybar_exit_ip_cache"
GEOIP_CACHE="/tmp/waybar_geoip_cache"
LOCK_FILE="/tmp/waybar_vpn_cache.lock"
CACHE_MAX_AGE=5

needs_refresh() {
    [ ! -f "$CACHE_FILE" ] && return 0
    local age=$(( $(date +%s) - $(stat -c %Y "$CACHE_FILE") ))
    [ $age -ge $CACHE_MAX_AGE ] && return 0
    return 1
}

needs_refresh || exit 0

# Lock to prevent concurrent writes
exec 9>"$LOCK_FILE"
flock -n 9 || exit 0

# --- VPN Detection ---
if ip link show | grep -q "pvpnksintrf.*UP"; then
    WB_PROVIDER="ProtonVPN"
    WB_TUNNEL_IP=$(ip addr show tun0 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)

    STATUS=$(protonvpn status 2>/dev/null)
    if echo "$STATUS" | grep -q "Server:"; then
        WB_SERVER=$(echo "$STATUS" | grep "Server:" | awk '{print $2}')
        WB_CITY=$(echo "$STATUS" | grep "Server:" | awk '{print $4}' | tr -d ',')
    else
        CONN=$(nmcli -t -f NAME,TYPE connection show --active | grep ":vpn" | head -1 | cut -d: -f1)
        WB_SERVER=$(echo "$CONN" | awk '{print $2}')
        if [ -f "$GEOIP_CACHE" ] && [ $(( $(date +%s) - $(stat -c %Y "$GEOIP_CACHE") )) -lt 300 ]; then
            GEOIP=$(cat "$GEOIP_CACHE")
        else
            GEOIP=$(curl -s --max-time 3 "http://ip-api.com/json")
            echo "$GEOIP" > "$GEOIP_CACHE"
        fi
        WB_CITY=$(echo "$GEOIP" | grep -o '"city":"[^"]*"' | cut -d'"' -f4)
        WB_REGION=$(echo "$GEOIP" | grep -o '"region":"[^"]*"' | cut -d'"' -f4)
        WB_ISP=$(echo "$GEOIP" | grep -o '"isp":"[^"]*"' | cut -d'"' -f4)
    fi

    # Exit IP cached 5 min
    if [ -f "$EXIT_IP_CACHE" ] && [ $(( $(date +%s) - $(stat -c %Y "$EXIT_IP_CACHE") )) -lt 300 ]; then
        WB_EXIT_IP=$(cat "$EXIT_IP_CACHE")
    else
        WB_EXIT_IP=$(curl -s --max-time 3 https://api.ipify.org 2>/dev/null)
        [ -n "$WB_EXIT_IP" ] && echo "$WB_EXIT_IP" > "$EXIT_IP_CACHE"
    fi
    WB_CONNECTED=1

elif ip link show nordlynx 2>/dev/null | grep -q "UP"; then
    WB_PROVIDER="NordVPN"
    STATUS=$(nordvpn status)
    WB_SERVER=$(echo "$STATUS" | grep "Server:" | awk '{print $2, $3}')
    WB_CITY=$(echo "$STATUS" | grep "City:" | awk '{print $2}')
    WB_TUNNEL_IP=$(ip addr show nordlynx 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)
    WB_EXIT_IP=$(echo "$STATUS" | grep "^IP:" | awk '{print $2}')
    WB_CONNECTED=1

else
    WB_PROVIDER=""
    WB_SERVER=""
    WB_CITY=""
    WB_TUNNEL_IP=""
    WB_EXIT_IP=""
    WB_CONNECTED=0
fi

# --- Carrier IP ---
if ip link show wwan0 2>/dev/null | grep -q "UP"; then
    WB_CARRIER_IP=$(ip addr show wwan0 | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)
    WB_CARRIER_IFACE="wwan0"
    WB_IS_WWAN=1
elif ip link show wlp0s20f3 2>/dev/null | grep -q "UP"; then
    WB_CARRIER_IP=$(ip addr show wlp0s20f3 | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)
    WB_CARRIER_IFACE="wlp0s20f3"
    WB_IS_WWAN=0
else
    WB_CARRIER_IP=""
    WB_CARRIER_IFACE=""
    WB_IS_WWAN=0
fi

# --- DNS ---
WB_DNS_UPSTREAM=$(resolvectl status 2>/dev/null | grep "Current DNS Server" | awk '{print $NF}')
WB_DNS_STUB=$(grep '^nameserver' /etc/resolv.conf | head -1 | awk '{print $2}')

# Write atomic cache
TMPFILE=$(mktemp)
cat > "$TMPFILE" << CACHEEOF
WB_PROVIDER="$WB_PROVIDER"
WB_SERVER="$WB_SERVER"
WB_CITY="$WB_CITY"
WB_TUNNEL_IP="$WB_TUNNEL_IP"
WB_EXIT_IP="$WB_EXIT_IP"
WB_CARRIER_IP="$WB_CARRIER_IP"
WB_CARRIER_IFACE="$WB_CARRIER_IFACE"
WB_IS_WWAN="$WB_IS_WWAN"
WB_DNS_UPSTREAM="$WB_DNS_UPSTREAM"
WB_DNS_STUB="$WB_DNS_STUB"
WB_CONNECTED="$WB_CONNECTED"
WB_REGION="${WB_REGION:-}"
WB_ISP="${WB_ISP:-}"
CACHEEOF
mv "$TMPFILE" "$CACHE_FILE"
flock -u 9
