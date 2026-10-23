{
  pkgsUnstable,
  ...
}:
{
  environment.systemPackages = [
    # Basic
    pkgsUnstable.mkpasswd

    pkgsUnstable.gnutar
    pkgsUnstable.zip
    pkgsUnstable.unzip

    pkgsUnstable.binutils
    pkgsUnstable.coreutils-full
    pkgsUnstable.findutils
    pkgsUnstable.binutils
    pkgsUnstable.moreutils

    pkgsUnstable.efibootmgr # Writing NVRAM boot entries.
    pkgsUnstable.hdparm
    pkgsUnstable.exfatprogs
    pkgsUnstable.xfsprogs
    pkgsUnstable.zfs

    pkgsUnstable.dmidecode # BIOS read tool.
    pkgsUnstable.lshw
    pkgsUnstable.pciutils
    pkgsUnstable.usbutils
    pkgsUnstable.xev # For keyboard key press properties.
    pkgsUnstable.xkbcomp # For checking xkb keyboard symbol tables.

    pkgsUnstable.libGL
    pkgsUnstable.libGLU

    pkgsUnstable.mlocate
    pkgsUnstable.ncurses5

    pkgsUnstable.fd
    pkgsUnstable.tree
    pkgsUnstable.file
    pkgsUnstable.fzf
    pkgsUnstable.fzf-git-sh
    pkgsUnstable.eza

    pkgsUnstable.netcat-gnu
    pkgsUnstable.wget
    pkgsUnstable.curl
    pkgsUnstable.openvpn
    pkgsUnstable.keychain # ssh agent.

    pkgsUnstable.btop
    pkgsUnstable.killall
    pkgsUnstable.ripgrep

    # Some minimal stuff, for basic admin stuff.
    pkgsUnstable.zsh
    pkgsUnstable.bash
    pkgsUnstable.neovim
    pkgsUnstable.just
    pkgsUnstable.git
    pkgsUnstable.git-lfs
    pkgsUnstable.git-filter-repo
    pkgsUnstable.kitty

    # Nix tools
    pkgsUnstable.nvd
    pkgsUnstable.nix-output-monitor
  ];
}
