#!/usr/bin/env bash
# shellcheck disable=SC1090
#

# Check VPN over network-manager.
vpn=$(nmcli --fields NAME,TYPE connection show --active 2>/dev/null | grep "vpn")
if [ "$vpn" != "" ]; then
    name=$(echo "$vpn" | cut -d ' ' -f 1)
    cat <<EOF
{"tooltip":"VPN: $name","class":"connected","percentage":100}
EOF
    exit 0
fi

# Check if NordVPN has an ip address.
if ip addr show wgnord 2>/dev/null | grep -q "inet "; then
    cat <<EOF
{"tooltip":"VPN: wgnord","class":"connected","percentage":100}
EOF
    exit 0
fi

cat <<EOF
{"tooltip":"VPN Disconnected","class":"disconnected","percentage":0}
EOF
