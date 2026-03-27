#!/usr/bin/env bash
# shellcheck disable=SC2015,SC1091,SC2153

if [ "${GABYX_LIB_K3S:-}" != "loaded" ]; then

    function gabyx::get_k3s_killall_script() {
        local temp
        temp=$(mktemp)

        curl -sL https://raw.githubusercontent.com/smartin77/create-k3s-killall/main/create-k3s-killall.sh -o "$temp"
        if [ "$(sha256sum "$temp" | cut -d ' ' -f 1)" != "b93e95218beb47cf37ca4313e61d0fab26514aa168e8aea610a21a04f5780a8e" ]; then
            gabyx::print_error "SHA sum of script does not match!" >&2
            return 1
        fi
        cd ~/.config/kube || return 1

        gabyx::print_info "Writing 'k3s-killall.sh' to '~/.config/kube'"
        bash "$temp"

        rm -f "$temp"
    }

    # Kill all `k3s` (kubernetes) instances.
    function gabyx::k3s_killall() {
        if [ ! -f ~/.config/kube/k3s-killall.sh ]; then
            gabyx::get_k3s_killall_script
        fi

        ~/.config/kube/k3s-killall.sh
    }

    export GABYX_LIB_K3S="loaded"
fi
