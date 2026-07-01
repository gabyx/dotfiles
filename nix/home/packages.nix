{
  inputs,
  inputs',
  system,
  packages,
  pkgs,
  pkgsUnstable,
  ...
}:
let
  # Define some special packages.
  githooks = inputs'.githooks.packages.default;
  nixfmt-rs = inputs'.nixfmt-rs.packages.default;
in
{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  home.packages = [
    # Basics
    pkgsUnstable.zoxide # A smarter cd.
    pkgsUnstable.age # Encryption tool.
    pkgsUnstable.libsecret # secret-tool to access gnome-keyring
    pkgsUnstable.git
    pkgsUnstable.git-lfs
    pkgsUnstable.git-town
    githooks
    pkgsUnstable.tig
    pkgsUnstable.seahorse
    pkgsUnstable.zenity # For dialogs over githooks and calendar.
    pkgsUnstable.witr
    pkgsUnstable.gitstatus

    # Shells
    packages.zsh-jailed

    # Qemu
    pkgsUnstable.quickemu

    # Tools
    pkgsUnstable.lf # File manager
    pkgsUnstable.chafa # For Sixel pictures in terminal
    pkgsUnstable.exiftool # For image meta preview.
    pkgsUnstable.atool # For archive preview
    pkgsUnstable.bat # For text preview with syntax highlight and Git integration.
    pkgsUnstable.poppler-utils # For image conversions.
    pkgsUnstable.ffmpegthumbnailer # For video thumbnails.
    pkgsUnstable.trash-cli # Trash command line to move stuff to trash.

    # Disk
    pkgsUnstable.dua # Disk Usage Analyzer.
    pkgsUnstable.baobab # Analyze disks.
    pkgsUnstable.restic # Backup tool
    pkgsUnstable.gparted # Disk utility.
    pkgsUnstable.gnome-disk-utility # Easy disk utility `gdisk`.

    # Programming
    pkgs.shellclear
    pkgsUnstable.parallel
    pkgsUnstable.lazygit
    pkgsUnstable.delta
    pkgsUnstable.difftastic
    pkgsUnstable.meld
    pkgsUnstable.kubectl
    pkgsUnstable.kind # Simple kubernetes for local development.
    pkgsUnstable.k9s # Kubernetes management CLI tool
    pkgsUnstable.kdiff3
    pkgsUnstable.jq
    pkgsUnstable.yq-go
    pkgsUnstable.remarshal
    pkgsUnstable.just
    pkgsUnstable.dive # Inspect container images.
    packages.claude-jailed

    # FHS Environment with nix-alien
    inputs.nix-alien.packages.${system}.nix-alien

    # Linters/LSPs
    pkgsUnstable.markdownlint-cli
    pkgsUnstable.yamllint
    pkgsUnstable.codespell
    pkgsUnstable.typos
    pkgsUnstable.shfmt
    pkgsUnstable.nufmt
    pkgsUnstable.stylua
    pkgsUnstable.prettier
    nixfmt-rs
    pkgsUnstable.shellcheck

    ## Python
    pkgsUnstable.python3
    pkgsUnstable.python3Packages.ruff

    ## Nix
    pkgsUnstable.nix-tree
    pkgsUnstable.nixpkgs-lint
    pkgsUnstable.dconf2nix # To generate the `dconf` settings.
    pkgsUnstable.comma # Run , jellyfin to quickly run a nix package.

    ## Lua

    # Writing
    # pkgsUnstable.texlive.combined.scheme-full
    pkgsUnstable.pandoc

    # Calendar/Mail (our version)
    pkgs.khal # CLI Calendar
    pkgs.protonmail-bridge-gui

    # Trains
    pkgs.sbb-tui # SBB TUI app.

    # MultiMedia
    pkgsUnstable.mediawriter # Like balena etcher.
    pkgsUnstable.bitwarden-desktop # Password manager
    pkgsUnstable.bitwarden-cli
    pkgsUnstable.bazecor # Dygma Defy Keyboard.
    pkgsUnstable.element-desktop # Matrix client.
    pkgsUnstable.slack # Messaging app
    pkgsUnstable.ffmpeg # Movie converter
    pkgsUnstable.vlc # Movie player
    pkgsUnstable.amberol # Music player
    pkgsUnstable.showmethekey # Screencast the key-presses.

    pkgsUnstable.viu # Terminal image viewer
    pkgsUnstable.sxiv # Terminal image viewer
    pkgsUnstable.zathura # Simple document viewer
    pkgsUnstable.xournalpp # Another PDF viewer
    pkgsUnstable.pdfarranger # PDF arranger
    pkgsUnstable.ghostscript
    pkgsUnstable.imagemagick_light # Converter tools
    pkgsUnstable.ymuse # Sound player
    pkgsUnstable.zoom-us # Video calls
    pkgsUnstable.deluge # Bittorrent client
    pkgsUnstable.libreoffice

    # News
    pkgsUnstable.newsflash # RSS Reader

    # Sound
    pkgsUnstable.headsetcontrol
    pkgsUnstable.noson # Sonos device

    # VPN
    pkgsUnstable.wgnord

    # Networking
    pkgsUnstable.dig # DNS lookup tool.

    # Camera
    pkgsUnstable.guvcview # Camera control

    # Remote Desks
    pkgsUnstable.rustdesk # Remote desktop
    # FIXME: https://github.com/NixOS/nixpkgs/pull/518524
    # pkgsUnstable.anydesk

    # Dictionaries
    pkgsUnstable.aspell
    pkgsUnstable.aspellDicts.en
    pkgsUnstable.aspellDicts.en-computers
    pkgsUnstable.hunspell
    pkgsUnstable.hunspellDicts.en-us
  ];

}
