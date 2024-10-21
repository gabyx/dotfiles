#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091,SC2034

function get_platform_os() {
    local -n _platformOS="$1"
    local platformOSDist=""
    local platformOSVersion=""

    if [[ $OSTYPE == "linux-gnu"* ]]; then
        _platformOS="linux"
    elif [[ $OSTYPE == "linux-musl"* ]]; then
        # Alpine linux
        _platformOS="linux"
    elif [[ $OSTYPE == "darwin"* ]]; then
        _platformOS="darwin"
    elif [[ $OSTYPE == "freebsd"* ]]; then
        _platformOS="freebsd"
    else
        # Resort to `uname` for windows stuff.
        local name
        name=$(uname -a)
        case "$name" in
        CYGWIN*) _platformOS="windows" && platformOSDist="cygwin" ;;
        MINGW*) _platformOS="windows" && platformOSDist="mingw" ;;
        *Msys) _platformOS="windows" && platformOSDist="msys" ;;
        *) die "Platform: '$name' not supported." ;;
        esac
    fi

    if [ "$_platformOS" = "linux" ]; then

        if [ "$(lsb_release -si 2>/dev/null)" = "Ubuntu" ]; then
            platformOSDist="ubuntu"
            platformOSVersion=$(grep -m 1 "VERSION_CODENAME=" "/etc/os-release" |
                sed -E "s|.*=[\"']?(.*)[\"']?|\1|")
        elif grep -qE 'ID="?debian' "/etc/os-release"; then
            platformOSDist="debian"
            platformOSVersion=$(grep -m 1 "VERSION_CODENAME=" "/etc/os-release" |
                sed -E "s|.*=[\"']?(.*)[\"']?|\1|")
        elif grep -qE 'ID="?alpine' "/etc/os-release"; then
            platformOSDist="alpine"
            platformOSVersion=$(grep -m 1 "VERSION_ID=" "/etc/os-release" |
                sed -E 's|.*="?([0-9]+\.[0-9]+).*|\1|')
        elif grep -qE 'ID="?nixos' "/etc/os-release"; then
            platformOSDist="nixos"
            platformOSVersion=$(grep -m 1 "VERSION_ID=" "/etc/os-release" |
                sed -E 's|.*="?([0-9]+\.[0-9]+).*|\1|')
        elif grep -qE 'ID="?rhel' "/etc/os-release"; then
            platformOSDist="redhat"
            platformOSVersion=$(grep -m 1 "VERSION_ID=" "/etc/os-release" |
                sed -E 's|.*="?([0-9]+\.[0-9]+).*|\1|')
        else
            die "Linux Distro '/etc/os-release' not supported currently:" \
                "$(cat /etc/os-release 2>/dev/null)"
        fi

        # Remove whitespaces
        platformOSDist="${platformOSDist// /}"
        platformOSVersion="${platformOSVersion// /}"

    elif [ "$_platformOS" = "darwin" ]; then

        platformOSDist=$(sw_vers | grep -m 1 'ProductName' | sed -E 's/.*:\s+(.*)/\1/')
        platformOSVersion=$(sw_vers | grep -m 1 'ProductVersion' | sed -E 's/.*([0-9]+\.[0-9]+\.[0-9]+)/\1/g')
        # Remove whitespaces
        platformOSDist="${platformOSDist// /}"
        platformOSVersion="${platformOSVersion// /}"

    elif [ "$_platformOS" = "windows" ]; then
        platformOSVersion=$(systeminfo | grep -m 1 'OS Version:' | sed -E "s/.*:\s+([0-9]+\.[0-9]+\.[0-9]+).*/\1/")
        platformOSVersion="${platformOSVersion// /}"
    else
        die "Platform '$_platformOS' not supported currently."
    fi

    if [ -n "${2:-}" ]; then
        local -n _platformOSDist="$2"
        _platformOSDist="$platformOSDist"
    fi

    if [ -n "${3:-}" ]; then
        local -n _platformOSVersion="$3"
        _platformOSVersion="$platformOSVersion"
    fi

    return 0
}

function get_platform_arch() {
    local -n _arch="$1"

    _arch=""
    if uname -m | grep -q "x86_64" &>/dev/null; then
        _arch="amd64"
        return 0
    elif uname -m | grep -q -E "aarch64|arm64" &>/dev/null; then
        _arch="arm64"
        return 0
    elif uname -a | grep -q -E "aarch64|arm64" &>/dev/null; then
        _arch="arm64"
    else
        die "Architecture: '$(uname -m)' not supported."
    fi
}
