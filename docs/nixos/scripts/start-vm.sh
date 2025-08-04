#!/usr/bin/env bash
# shellcheck disable=SC1091
#
# Copied from /var/log/libvirt/qemu/nixos.log
# This is the simplified command virt-manager used to start the VM.
#

set -e
set -u

ROOT=$(git rev-parse --show-toplevel)

. "$ROOT/nixos/.env-os-vm"

# Port Forwarding for SSH
# with -nic user,hostfwd=tcp::60022-:22

/usr/bin/qemu-system-x86_64 \
    -enable-kvm \
    -m 8G \
    -smp 8 \
    -hda "$NIXOS_DISK" \
    -netdev user,id=net0,net=192.168.0.0/24,dhcpstart=192.168.0.9 \
    -device virtio-net-pci,netdev=net0 \
    -vga qxl \
    -device AC97 \
    -nic user,hostfwd=tcp::60022-:22 \
    "$@"
