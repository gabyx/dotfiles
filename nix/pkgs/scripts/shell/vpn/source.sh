#!/usr/bin/env bash
# shellcheck disable=SC2015,SC1091,SC2153

if [ "${GABYX_LIB_VPN:-}" != "loaded" ]; then
    # Connect the NordVPN connection.
    function gabyx::nordvpn_connect() {
        wgnord-up "$@"
    }

    # Disconnect the NordVPN connection.
    function gabyx::nordvpn_disconnect() {
        wgnord-down "$@"
    }

    # Connect to the named VPN connection.
    function gabyx::vpn_connect() {
        local name="${1:-"eth-zurich"}"
        nmcli connection up "$name" --ask
    }

    GABYX_LIB_VPN="loaded"
fi
