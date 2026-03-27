#!/usr/bin/env bash
# shellcheck disable=SC2015,SC1091,SC2153

source "$GABYX_LIB_DIR/common/source.sh"
source "$GABYX_LIB_DIR/container/source.sh"
source "$GABYX_LIB_DIR/filesystem/source.sh"
source "$GABYX_LIB_DIR/git/source.sh"
source "$GABYX_LIB_DIR/k3s/source.sh"
source "$GABYX_LIB_DIR/nixos/source.sh"
source "$GABYX_LIB_DIR/tmux/source.sh"
source "$GABYX_LIB_DIR/vpn/source.sh"
source "$GABYX_LIB_DIR/windowing/source.sh"

unset GABYX_LIB_COMMON
unset GABYX_LIB_CONTAINER
unset GABYX_LIB_FILESYSTEM
unset GABYX_LIB_GIT
unset GABYX_LIB_K3S
unset GABYX_LIB_NIXOS
unset GABYX_LIB_TMUX
unset GABYX_LIB_VPN
unset GABYX_LIB_WINDOWING
