#!/usr/bin/env bash

set -e
set -u

sudo cryptsetup luksOpen "${MYDISK}p2" enc-physical-vol
DISKMAP=/dev/mapper/enc-physical-vol
sudo mkfs.btrfs -f $DISKMAP

MNTPNT="/mnt"
sudo mount -t btrfs $DISKMAP $MNTPNT
sudo btrfs subvolume create $MNTPNT/root
sudo btrfs subvolume create $MNTPNT/home
sudo btrfs subvolume create $MNTPNT/nix
sudo btrfs subvolume create $MNTPNT/persist
sudo btrfs subvolume create $MNTPNT/log
sudo btrfs subvolume create $MNTPNT/swap
sudo btrfs filesystem mkswapfile --size 38g --uuid clear $MNTPNT/swap/swapfile

sudo btrfs subvolume snapshot -r $MNTPNT/root $MNTPNT/root-blank
sudo umount $MNTPNT

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
sudo mount "${MYDISK}p1" $MNTPNT/boot
