{
  config,
  pkgs,
  inputs,
  ...
}:
{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs.unstable; [
    # Basic
    mkpasswd

    gnutar
    unzip

    binutils
    coreutils-full
    findutils
    binutils
    moreutils

    hdparm
    exfatprogs
    zfs
    baobab # Analyze disks.

    dmidecode # BIOS read tool.
    lshw
    pciutils
    usbutils
    xorg.xev # For keyboard key press properties.
    xorg.xkbcomp # For checking xkb keyboard symbol tables.

    libGL
    libGLU

    mlocate
    ncurses5

    fd
    tree
    file
    fzf
    fzf-git-sh
    eza

    nmap
    wget
    curl
    openvpn
    keychain # ssh agent.

    btop
    killall
    ripgrep

    # Some minimal stuff, for basic admin stuff.
    zsh
    bash
    just
    git
    git-lfs
    kitty

    # Other virtualisation stuff.
    # libguestfs # Needed to virt-sparsify qcow2 files
    # libvirt
    # spice # For automatic window resize if this conf is used as OS in VM
    # spice-vdagent
    # virt-manager

    # Nix tools
    nvd
    nix-output-monitor
  ];
}
