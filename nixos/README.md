<img src="https://raw.githubusercontent.com/NixOS/nixos-artwork/4c449b822779d9f3fca2e0eed36c95b07d623fd9/ng/out/nix.svg" style="margin-left: 20pt" align="right">
<h1>NixOS Installation</h1>

The file [`configuration.nix`](configuration.nix) contains the whole NixOS
configuration and will be used to install the complete system. It is influenced
by
[`nixos-starter-configs`](https://github.com/Misterio77/nix-starter-configs/tree/main).

The following steps describe how to end up with a NixOS installation. The best
starting point is to test the VM inside `qemu` before installing it into
bare-metal.

![Screenshot](./docs/screenshot.png)

## Prerequisites

Some key insights to ease understanding when working through the below NixOS
install.

- The configuration language `Nix` uses a basic type `String` (e.g. "this is a
  string") and `Path` (`/this/is/a/path`) which are two different things and
  treated differently.

- Check out the manual [NixOs](https://nixos.org/manual/nixos/stable) when
  searching for entry point documentation.

- During modifications consult the two pages:

  - [Package Search](https://search.nixos.org/packages?)
  - [Options Search](https://search.nixos.org/options?)

  for package names and options.

- **Read the first chapters in book
  [NixOS and Flakes](https://github.com/ryan4yin/nixos-and-flakes-book) to learn
  more about Nix flakes. Give him a star!.**

- Passing inputs to modules can be done in different ways, best is to not use
  overlays, but just using plain old functions.
  [Read more here](docs/pass-inputs-to-modules.md).

- This NixOS is using the `sway` (Wayland not X11) window manager. To get you
  started when the VM is booted up:

  - `Alt+d` to start a program or
  - press `Alt+Enter` to open `wezterm` terminal with `zsh`.

- The NixOS install is customized with my [`dotfiles`](../config) over `chezmoi`
  it is not yet built into Nix's
  [`homemanager`](https://github.com/nix-community/home-manager).

## Install NixOS into QEMU Virtual Machine

The documentation [NixOS Manual](https://nixos.org/manual/nixos/stable) provides
useful information when going through these steps:

1. Install `virt-manager` to create a QEMU virtual machine. On Debian systems
   use:

   ```shell
   sudo apt-get install virt-manager
   ```

1. Download the NixOS ISO file from
   [here](https://nixos.org/download#download-nixos).

1. Adjust `.env-os-vm` file from `.env-os.tmpl` for your variables.

### Create VM with `virt-manager` (not recommended)

1. Open `virt-manager` and create a new machine `nixos` by using the
   [downloaded NixOS ISO file](https://channels.nixos.org/nixos-23.05/latest-nixos-gnome-x86_64-linux.iso).
   Create a virtual disk `nixos.qcow2` somewhere.

1. Boot up the virtual machine `nixos` in `virt-manager`. The graphical
   installer should show up. Install NixOS by going through the
   [graphical installer](https://nixos.org/manual/nixos/stable/#sec-installation-graphical).
   Reboot after the install.

### Create VM with Script

1. Create the VM by doing `scripts/create-vm.sh` and clicking through the
   installer. Use an LUKS encrypted disk.

### Install VM NixOS Configuration.

1. Start the virtual machine with [`scripts/start-vm.sh`](scripts/start-vm.sh)
   and switch to the VM NixOS configuration by doing

   ```shell
      nixos-install switch --flake github:gabyx/dotfiles#vm
      reboot
   ```

   or directly from the repository with

   ```shell
   nixos-install --root /mnt --flake .#vm --impure
   reboot
   ```

Go to the section [first login](#first-login) for further instructions.

### Connect to VM over SSH

1. Start the virtual machine with [`scripts/start-vm.sh`](scripts/start-vm.sh).
1. On the host inside a terminal connect over SSH with

   ```shell
   ssh nixos@127.0.0.1 -p 60022
   ```

## Install NixOs on Desktop Hardware

We follow the tutorial from
[Pablo Ovelleiro](https://pablo.tools/blog/computers/nixos-encrypted-install)
[@pinpox](https://github.com/pinpox) and
[mt-caret](https://mt-caret.github.io/blog/posts/2020-06-29-optin-state.html).

Boot the NixOS ISO installer of the flashed USB.

### Partitioning

Partitioning in NixOS is manual and mostly the same as you would do in Arch or
any other "minimal" distribution. You can use `gparted` if you decided to boot
the graphical installer, but I find the process simpler with good-old `gdisk`.

We will be creating two partitions:

- EFI partition (500M)
- Encrypted physical volume for
  [LVM](https://de.wikipedia.org/wiki/Logical_Volume_Manager) (remaining space)

Furthermore, LVM will be used inside the encrypted physical volume and I will be
adding (100% + `sqrt(100%)) of my ram as a swap partition (e.g. 64GB = 72GB) if
we want proper hibernation. For the thoroughly-paranoid this has the added
benefit, that the swap partition will also be encrypted.

1. Assuming the drive you want to install to is `/dev/sda`, run `gdisk` and
   create the partitions: To not make mistakes run the following in the terminal
   (**replace the disk**):

   ```shell
   MYDISK=/dev/sda
   sudo gdisk $MYDISK
   ```

1. Then do the following:

   - `o` : Create empty `gpt` partition table.
   - `n` : Add partition, first sector: default, last sector: `+500M`, type
     `ef00 EFI` (this is `/dev/sda1`).
   - `n` : Add partition, remaining space, type `8e00` Linux LVM (this is
     `/dev/sda2`).
   - `w` : Write partition table and exit.

1. We can now set up the encrypted LUKS partition and open it using `cryptsetup`

   ```shell
   sudo cryptsetup luksFormat ${MYDISK}2
   sudo cryptsetup luksOpen ${MYDISK}2 enc-physical-vol
   ```

1. Format the partitions with:

   EFI Partition:

   ```shell
   sudo mkfs.fat -F 32 ${MYDISK}1
   ```

   LVM Partition:

   ```shell
   DISKMAP=/dev/mapper/enc-physical-vol
   sudo mkfs.btrfs $DISKMAP
   ```

1. Create subvolumes as follows:

   - `root`: The subvolume for `/`, which will be cleared on every boot.
   - `home`: The subvolume for `/home`, which should be backed up.
   - `nix`: The subvolume for `/nix`, which needs to be persistent but is not
     worth backing up, as it’s trivial to reconstruct.
   - `persist`: The subvolume for `/persist`, containing system state which
     should be persistent across reboots and possibly backed up.
   - `log`: The subvolume for `/var/log`. I’m not so interested in backing up
     logs but I want them to be preserved across reboots, so I’m dedicating a
     subvolume to logs rather than using the persist subvolume.
   - `swap`: A swap volume with size 72Gb which is also encrypted because we are
     paranoid.

   ```shell
   DISKMAP=/dev/mapper/enc-physical-vol
   MNTPNT="/mnt"
   sudo mount -t btrfs $DISKMAP $MNTPNT
   sudo btrfs subvolume create $MNTPNT/root
   sudo btrfs subvolume create $MNTPNT/home
   sudo btrfs subvolume create $MNTPNT/nix
   sudo btrfs subvolume create $MNTPNT/persist
   sudo btrfs subvolume create $MNTPNT/log

   sudo btrfs subvolume create $MNTPNT/swap
   sudo btrfs filesystem mkswapfile --size 72g --uuid clear $MNTPNT/swap/swapfile

   sudo btrfs subvolume snapshot -r $MNTPNT/root $MNTPNT/root-blank
   sudo umount $MNTPNT
   ```

   Above we also created an empty snapshot of the root volume. Later we might
   use it to reset to it when booting.

### Installing NixOS

The partitions just created have to be mounted, e.g. to `/mnt` so we can install
NixOS on them. At this point activating the swap (if you created one) is a good
idea. The `/boot` partition is mounted in a new folder `/mnt/boot` inside the
root partition.

1. Mount all filesystems by doing:

   ```shell
   DISKMAP=/dev/mapper/enc-physical-vol
   MNTPNT="/mnt"
   sudo mkdir -p $MNTPNT
   sudo mount -o subvol=root,compress=zstd,noatime $DISKMAP $MNTPNT

   sudo mkdir -p $MNTPNT/home
   sudo mount -o subvol=home,compress=zstd,noatime $DISKMAP $MNTPNT/home

   sudo mkdir -p $MNTPNT/nix
   sudo mount -o subvol=nix,compress=zstd,noatime $DISKMAP $MNTPNT/nix

   sudo mkdir -p $MNTPNT/persist
   sudo mount -o subvol=persist,compress=zstd,noatime $DISKMAP $MNTPNT/persist

   sudo mkdir -p $MNTPNT/var/log
   sudo mount -o subvol=log,compress=zstd,noatime $DISKMAP $MNTPNT/var/log

   sudo mkdir -p $MNTPNT/swap
   sudo mount -o subvol=swap,defaults,noatime $DISKMAP $MNTPNT/swap

   # Don't forget this!
   sudo mkdir -p $MNTPNT/boot
   sudo mount "${MYDISK}1" $MNTPNT/boot

   # Enable swap
   sudo swapon $MNTPNT/swap/swapfile
   ```

1. Then, let NixOS figure out the hardware configuration:

   ```
   sudo nixos-generate-config --root /mnt
   ```

   which will generate two files `/mnt/etc/nixos/hardware-configuration.nix` and
   a default NixOs configuration as `/mnt/etc/nixos/configuration.nix` (which we
   will not use to install our system).

   Now your hardware configuration should contain the following:

   ```nix
   fileSystems."/" =
     { device = "/dev/disk/by-uuid/a9504076-ec13-41e9-adb6-5385eb464a9f";
       fsType = "btrfs";
       options = [ "subvol=root" "compress=zstd" "noatime" ];
     };

   boot.initrd.luks.devices."enc-physical-vol".device = "/dev/disk/by-uuid/9cfdf03f-6872-499d-afd4-78fd74bd2e6b";

   fileSystems."/home" =
     { device = "/dev/disk/by-uuid/a9504076-ec13-41e9-adb6-5385eb464a9f";
       fsType = "btrfs";
       options = [ "subvol=home" "compress=zstd" "noatime" ];
     };

   fileSystems."/nix" =
     { device = "/dev/disk/by-uuid/a9504076-ec13-41e9-adb6-5385eb464a9f";
       fsType = "btrfs";
       options = [ "subvol=nix" "compress=zstd" "noatime" ];
     };

   fileSystems."/persist" =
     { device = "/dev/disk/by-uuid/a9504076-ec13-41e9-adb6-5385eb464a9f";
       fsType = "btrfs";
       options = [ "subvol=persist" "compress=zstd" "noatime" ];
     };

   fileSystems."/var/log" =
     { device = "/dev/disk/by-uuid/a9504076-ec13-41e9-adb6-5385eb464a9f";
       fsType = "btrfs";
       options = [ "subvol=log" "compress=zstd" "noatime" ];
       neededForBoot = true;
     };

   fileSystems."/swap" =
     { device = "/dev/disk/by-uuid/a9504076-ec13-41e9-adb6-5385eb464a9f";
       fsType = "btrfs";
       options = [ "subvol=swap" "defaults" "noatime" ];
     };

   swapDevices = [ { device = "/swap/swapfile"; } ];
   ```

   **Note the `neededForBoot = true;` for `/var/log`.**

1. Copy the hardware configuration to the repo for the installation:

   ```shell
   cp /mnt/etc/nixos/hardware-configuration.nix /mnt/persist/repos/dotfiles/nixos/hosts/<host>/hardware-configuration.nix
   ```

1. Apply the initial config files into the home directory with:

   **Config Files:**

   ```shell
   nix-shell -p chezmoi
   git clone https://github.com/dotfiles $MNTPNT/home/nixos/.local/share/chezmoi
   git lfs pull
   HOME=$MNTPNT/home/nixos chezmoi apply --exclude encrypted
   ```

   **Editor Setup:**

   ```shell
   git clone https://github.com/gabyx/astronvim.git ~/.config/nvim
   ```

This is only to make sure once you reboot and login you have `sway` starting
with the settings wanted already in your home directory.

TODO: Make this automated such that we bake the whole repository into a
derivation to be used/run when no `~/.config/chezmoi/chezmoi.yaml` is there (no
apply done) during activation. The activation should run a `nix run` application
defined in the `flake.nix`.

1. **Finally run the install command** by doing:

   ```shell
   nixos-install --root /mnt --flake github:gabyx/dotfiles#desktop
   reboot
   ```

   or directly from the repository with

   ```shell
   nixos-install --root /mnt --flake .#desktop --impure
   reboot
   ```

## First Login

1. Login with the initial login `nixos` and default password `nixos`.

1. Move the initial configuration out of the way and point to the new
   configuration (create a hardlink).

   ```shell
   sudo mv /etc/nixos /etc/nixos.bak # Backup the original configuration
   ln ~/nixos-config ~/.local/share/chezmoi
   sudo ln ~/nixos-config/ /etc/nixos
   ```

1. Change the password

   ```shell
   passwd
   ```

1. and reboot

   ```shell
   reboot
   ```

## Modify NixOS

1. Modify the [`configuration.nix`](configuration.nix) in this repo and use

   ```shell
   just deploy [desktop|vm|tuxedo]
   ```

   Use `build` to just build the NixOS system. Use `boot` to build the NixOS (a
   new generation) and add a new entry in the bootloader with the profile `test`
   and use `switch` to additionally switch live to the new generation. Use
   `--force` to make a new generation for the system profile and not using the
   default `test` (because of safety).

## Troubleshooting

### Resizing the _LUKS Encrypted_ Disk (if disk is full)

If `nixos-rebuild` fails due to too little disk space, use the following easy
fix. On the host do the following:

1. Resize the `.qcow2` file with

   ```shell
   source .env-os-vm
   qemu-img resize "$NIXOS_DISK" +40G
   ```

1. Mount the disk with

   ```shell
   source .env-os-vm
   sudo qemu-nbd -c /dev/nbd0 "$NIXOS_DISK"
   ```

1. Run `gparted` with:

   ```shell
   gparted /dev/nbd0
   ```

   and right-click and run `Open Encryption` to decrypt the partition.

1. Use `Partition -> Check` which does an automatic resize to fill the
   partition.

### Running Root GUI Application in Sway

See
[documentation here](https://wiki.archlinux.org/title/Running_GUI_applications_as_root#Using_xhost).
Running root application like `gparted` over `sway` must be done like that:

```shell
sudo -E gparted
```

## Todos

1. Use https://github.com/moverest/sway-interactive-screenshot which now
   supports rofi.
