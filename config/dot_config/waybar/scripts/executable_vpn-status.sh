#!/usr/bin/env bash
# shellcheck disable=SC1090
#

vpn=$(nmcli --fields NAME,TYPE connection show --active | grep "vpn")
if [ "$vpn" != "" ]; then
    name=$(echo "$vpn" | cut -d ' ' -f 1)
    cat <<EOF
{"tooltip":"VPN: $name","class":"connected","percentage":100}
EOF
else
    cat <<EOF
{"tooltip":"VPN Disconnected","class":"disconnected","percentage":0}
EOF
fi
