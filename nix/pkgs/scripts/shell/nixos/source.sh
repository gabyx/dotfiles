#!/usr/bin/env bash
# shellcheck disable=SC2015,SC1091,SC2153

if [ "${GABYX_LIB_NIXOS:-}" != "loaded" ]; then
    # Get the last boot log.
    function gabyx::nixos_last_boot_log() {
        journalctl -b -1 -e
    }

    # Get the whole log for all user systemd services.
    function gabyx::nixos_systemd_log() {
        journalctl --user -e
    }

    # Get the log of the systemd service with name `$1`.
    # User log is: `user@1000`.
    function gabyx::nixos_systemd_log_for() {
        local service="$1"
        journalctl -u "$service.service" -e
    }

    # Get the log of the home-manager systemd service.
    function gabyx::nixos_hm_log() {
        journalctl -u home-manager-nixos.service -e
    }

    # List all running kernel modules.
    function gabyx::nixos_kernel_modules() {
        lsmod
    }

    GABYX_LIB_NIXOS="loaded"
fi
