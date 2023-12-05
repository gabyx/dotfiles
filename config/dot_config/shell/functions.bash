#!/usr/bin/env bash
# =========================================================================================
# Chezmoi Setup
#
# @date 17.3.2023
# @author Gabriel Nützi, gnuetzi@gmail.com
# =========================================================================================

function gabyx::compress_pdf() {
    local file="$1"
    local output="$2"
    local level="${3:-screen}"

    if [[ ! "$level" =~ (screen|ebook|prepress|default) ]]; then
        echo "The level must be something of 'screen|ebook|prepress|default'." >&2
        return 1
    fi

    gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 \
        "-dPDFSETTINGS=/$level" \
        -dNOPAUSE \
        -dBATCH \
        "-sOutputFile=$output" "$file"
}

function gabyx::bitwarden() {
    BW_SESSION=$(bw login gnuetzi@gmail.com --raw)
    export BW_SESSION
}

function gabyx::remove_docker_images() {
    local builder="docker"

    if [ "$1" = "--use-podman" ]; then
        shift 1
        builder="podman"
    fi

    [ -z "$1" ] && {
        echo "Empty regex given."
        return 1
    }
    images=$("$builder" images --format '{{.ID}}|{{.Repository}}:{{.Tag}}' | grep -v '<none>' |
        grep -xE "(\w+)\|$1" | sed -E "s/(\w+)\|.*/\1/g")
    [ -z "$images" ] && {
        echo "No images found."
        return 0
    }
    echo "Deleting images:"
    echo "$images"
    echo "$images" | xargs -n 1 docker rmi --force
}

function gabyx::copy_images_to_podman() {
    transport="docker-daemon"

    [ -z "$1" ] && {
        echo "Empty regex given."
        return 1
    }

    echo "Copying images with regex '$1' from docker to podman."
    images=$(docker images --format "$transport:{{.Repository}}:{{.Tag}}" | grep -v '<none>' | grep -xE "$transport:$1")

    echo "$images" | xargs printf "  - '%s'\n"
    echo "$images" | xargs podman pull
}

function gabyx::file_regex_replace() {
    "$HOME/.config/shell/file-regex-replace.py" "$@"
}

function gabyx::print_keycode_table {
    xmodmap -pke
}

function gabyx::get_keycode {
    xev
}

function gabyx::get_window_properties {
    swaymsg -t get_tree | jq
}

function gabyx::nixos_hm_log() {
    journalctl -u home-manager-nixos.service -e
}

function gabyx::nixos_rebuild() {
    local what="${1:?Specify how? 'switch,boot,test'}"
    shift 1
    local host="${1:?Specify a host to build}"
    shift 1

    (cd "$(readlink ~/nixos-config)" &&
        nixos-rebuild "$what" --flake ".#$host" --use-remote-sudo "$@")
}
