#!/usr/bin/env bash
# shellcheck disable=SC2015,SC1091,SC2153

if [ "${GABYX_LIB_CONTAINER:-}" != "loaded" ]; then
    source "$GABYX_LIB_DIR/container/clean.sh"

    function gabyx::docker_remove_images() {
        gabyx::shell-run "gabyx::internal::docker_remove_images" "$@"
    }

    function gabyx::docker_images_to_podman() {
        gabyx::shell-run "gabyx::internal::docker_images_to_podman" "$@"
    }

    GABYX_LIB_CONTAINER="loaded"
fi
