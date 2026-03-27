set positional-arguments
set shell := ["bash", "-cue"]
root_dir := `git rev-parse --show-toplevel`
build_dir := root_dir / "build/nixos-install"
docs_dir := root_dir / "docs/nixos"
env_file := docs_dir / ".env-vm"

# Default command to list all commands.
list:
    @just --list -f "{{source_file()}}"
    @just -f "{{source_file()}}" config

# Create the VM (disk file) and start it.
[group('vm')]
[no-cd]
create:
    #!/usr/bin/env bash
    # shellcheck disable=SC1091
    set -e
    set -u
    . "{{docs_dir}}/.env-vm"

    mkdir -p "{{build_dir}}"
    cd "{{build_dir}}"

    if [ -f "$VM_NIXOS_DISK" ]; then
        echo "Disk '$VM_NIXOS_DISK' already existing!" >&2
        echo "Delete it if you want to reinstall NixOS." >&2
    else
        mkdir -p $(dirname "$VM_NIXOS_DISK")
        qemu-img create -f qcow2 "$VM_NIXOS_DISK" "$VM_NIXOS_DISK_SIZE"
    fi

    just -f "{{source_file()}}" start \
        -boot d \
        -cdrom "$VM_NIXOS_ISO"

# Start the NixOS VM from a downloaded ISO file.
[group('vm')]
[no-cd]
start *args:
    #!/usr/bin/env bash
    set -e
    set -u
    # Copied from /var/log/libvirt/qemu/nixos.log
    # This is the simplified command virt-manager used to start the VM.
    . "{{docs_dir}}/.env-vm"

    mkdir -p "{{build_dir}}"
    cd "{{build_dir}}"

    # Port Forwarding for SSH
    # with -nic user,hostfwd=tcp::60022-:22

    if [ ! -f "$VM_NIXOS_DISK" ]; then
        echo "ERROR: '$VM_NIXOS_DISK' not existing."
        echo "ERROR: Create the VM disk first with 'just vm::create-disk'." >&2
        just -f "{{source_file()}}" config

        exit 1
    fi

    cmd=(qemu-system-x86_64
        -enable-kvm
        -m 8G
        -smp 8
        -hda "$VM_NIXOS_DISK"
        -netdev user,id=net0,net=192.168.0.0/24,dhcpstart=192.168.0.9
        -device virtio-net-pci,netdev=net0
        -vga qxl \
        -device AC97
        -nic user,hostfwd=tcp::60022-:22
        "$@")

    if [ "${VM_QEMU_USE_SPICE:-}" = "true" ]; then

        cmd+=(
            -spice unix=on,addr=/tmp/spice.sock,disable-ticketing=on
            -device virtio-serial-pci
            -chardev spicevmc,id=ch1,name=vdagent
            -device virtserialport,chardev=ch1,name=com.redhat.spice.0
        )

        echo
        echo "IMPORTANT: Using spice: connect to it with 'remote-viewer spice+unix:///tmp/spice.sock'."
        echo
    fi

    if [ "${VM_QEMU_MOUNT_REPO:-}" = "true" ]; then
        cmd+=(
            -virtfs
            local,id=shared_dev,path="{{root_dir}}",mount_tag=hostshare,security_model=passthrough
        )
    fi

    echo "QEMU cmd: ${cmd[@]}"

    "${cmd[@]}"

# Print the configuration.
config:
    #!/usr/bin/env bash
    . "{{env_file}}" &>/dev/null && {
        echo
        echo "Configuration -----"
        echo " - File: '{{env_file}}'"
        echo " - VM_NIXOS_ISO: $VM_NIXOS_ISO"
        echo " - VM_NIXOS_DISK: $VM_NIXOS_DISK"
        echo " - VM_NIXOS_DISK_SIZE: $VM_NIXOS_DISK_SIZE"
        echo "-------------------"
    } || {
        echo "No env file '{{env_file}}"
    }
