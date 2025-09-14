#!/usr/bin/env bash
# shellcheck disable=SC2015,SC1091,SC2153

. "$GABYX_LIB_DIR/common/source.sh"

# Remove `docker` or `podman` images with a regex `$1`.
# Use `--use-podman` as first argument if
# you want `podman` instead of `docker`.
function gabyx::internal::docker_remove_images() {
    local builder="docker"

    if [ "$1" = "--use-podman" ]; then
        shift 1
        builder="podman"
    fi

    [ -z "$1" ] && {
        gabyx::print_error "Empty regex given."
        return 1
    }
    images=$("$builder" images --format '{{.ID}}|{{.Repository}}:{{.Tag}}' | grep -v '<none>' |
        grep -xE "(\w+)\|$1" | sed -E "s/(\w+)\|.*/\1/g")
    [ -z "$images" ] && {
        gabyx::print_warning "No images found."
        return 0
    }

    gabyx::print_info "Deleting images:"
    echo "$images"
    echo "$images" | xargs -n 1 "$builder" rmi --force
}

function gabyx::internal::docker_images_to_podman() {
    transport="docker-daemon"

    [ -z "$1" ] && {
        gabyx::print_error "Empty regex given."
        return 1
    }

    gabyx::print_info "Copying images with regex '$1' from docker to podman."
    images=$(docker images --format "$transport:{{.Repository}}:{{.Tag}}" | grep -v '<none>' | grep -xE "$transport:$1")

    echo "$images" | xargs printf "  - '%s'\n"
    echo "$images" | xargs podman pull
}
