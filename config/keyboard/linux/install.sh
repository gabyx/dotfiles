#!/usr/bin/env bash
#
# If that script does not work
# use
# sudo apt-get reinstall xkb-data
# to reinstall the default files.
#

set -u
set -e

DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
. "$DIR/../../common/platform.sh"
. "$DIR/../../common/log.sh"

function writeToXML() {
    local rootNode="$1"
    local finalNode="$2"
    local where="$3" # Either 'layout' or 'variant' under which the 'configItem' is created.
    local file="$4"

    short="en-prog"
    long="Programmer (En, US)"

    if ! xmlstarlet -q sel -Q -t -c "$finalNode" "$file"; then
        printInfo "Add new $where 'programmer' to '$file'."

        sudo xmlstarlet ed --inplace \
            -s "$rootNode" -t elem -n "$where" \
            -s '$prev' -t elem -n "configItem" \
            --var newN '$prev' \
            -s '$newN' -t elem -n name -v "programmer" \
            -s '$newN' -t elem -n "shortDescription" -v "$short" \
            -s '$newN' -t elem -n "description" -v "$long" \
            -s '$newN' -t elem -n "languageList" \
            -s '$prev' -t elem -n "iso639Id" -v "eng" \
            "$file" || die "Adding new $where 'programmer' to '$file' failed."
    else
        printInfo "Keyboard $where 'programmer' already existing."
    fi

    printInfo "Modify layout 'programmer'."
    sudo xmlstarlet ed --inplace \
        --var newN "$finalNode" \
        -u '$newN/shortDescription' -v "$short" \
        -u '$newN/description' -v "$long" \
        -u '$newN/languageList/iso639Id' -v "eng" \
        "$file" || die "Modify 'programmer' in '$file' failed."
}

function addVariant() {

    # file="$DIR/test.xml"
    file="/usr/share/X11/xkb/rules/evdev.xml"

    [ -f "$file" ] || die "File '$file' is not existing, cannot add variant."

    sudo cp "$file" "$file.backup" ||
        die "Could not create backup of '$file'."

    # # Install as variant 'programmer' in 'us' layout
    # local rootNode="/xkbConfigRegistry/layoutList/layout[configItem[name[text()='us']]]/variantList"
    # local finalNode="$rootNode/variant/configItem[name[text()='programmer']]"
    # writeToXML "$rootNode" "$finalNode" "variant" "$file"

    # Install as separate layout `programmer`
    rootNode="/xkbConfigRegistry/layoutList"
    finalNode="$rootNode/layout/configItem[name[text()='programmer']]"
    writeToXML "$rootNode" "$finalNode" "layout" "$file"

    if [ "$dist" = "ubuntu" ]; then
        sudo dpkg-reconfigure xkb-data || die "Could not 'dpkg-reconfigure xkb-data'."
    fi
}

function applyToGnome() {
    sudo gsettings set org.gnome.desktop.input-sources sources \
        "[('xkb', 'us'), ('xkb', 'programmer')]"

    # Ex.:
    # gsettings set org.gnome.desktop.input-sources sources
    # "[('xkb', 'us+kinesis_adv_dvorak_it'), ('xkb', 'us+rus')]"
    # This command would load the US layout with "kinesis_adv_dvorak_it"
    # custom variant AND the US layout with the "russian" standard phonetic variant
    # If you check the menu "Input sources" in
    # "Gnome Settings -> Region & Language" after running
    # this command you'll see the layout/variants listed.

    # Make `CAPS-LOCK` also a `CTRL` and the normal CTRL a HYPER key
    sudo gsettings set org.gnome.desktop.input-sources xkb-options "['ctrl:swapcaps_hyper']"
}

dist=""
getPlatformOS os dist

if [ "$dist" = "nixos" ]; then
    printWarning "Not going to install keyboard layout in NixOS." \
        "Install keyboard in NixOS over the" \
        "'https://nixos.org/manual/nixos/stable/#custom-xkb-layouts'."
    exit 0
fi

if ! command -v xmlstarlet &>/dev/null; then
    if [ "$dist" = "ubuntu" ]; then
        sudo apt-get install -y xmlstarlet
    else
        die "OS '$dist' not supported to install xmlstarlet."
    fi
fi

setxkbmap "-I$DIR/symbols" programmer -print |
    xkbcomp "-I$DIR" - "$DISPLAY" 2>/dev/null ||
# Test if the layout works
    die "The layout '$DIR/symbols/programmer' is invalid." \
    "Check with:" \
        "setxkbmap \"-I$DIR/symbols\" programmer -print \|" \
        "xkbcomp \"-I$DIR/symbols\" - \"$DISPLAY\""

target="/usr/share/X11/xkb/symbols/programmer"
printInfo "Move layout to '$target'"
sudo cp "$DIR/symbols/programmer" "$target" ||
    die "Could not move layout to '$target'."

addVariant

applyToGnome

printInfo 'Layout installed, logout, login and select it in the os.'
