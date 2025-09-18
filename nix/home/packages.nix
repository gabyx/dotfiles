{
  inputs,
  outputs,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}:
let
  system = pkgs.system;
  # Define some special packages.
  wezterm-nightly = inputs.wezterm.packages."${system}".default;
  githooks = inputs.githooks.packages."${system}".default;

  nvim = outputs.packages.${system}.nvim;
  nvim-nightly = outputs.packages.${system}.nvim-nightly;
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

    # Terminal
    pkgsUnstable.kitty
    pkgsUnstable.ghostty
    wezterm-nightly

    # Editors
    pkgsUnstable.vscode
    nvim
    nvim-nightly

    # Tools
    pkgsUnstable.lf # File manager
    pkgsUnstable.chafa # For Sixel pictures in terminal
    pkgsUnstable.exiftool # For image meta preview.
    pkgsUnstable.atool # For archive preview
    pkgsUnstable.bat # For text preview with syntax highlight and Git integration.
    pkgsUnstable.poppler_utils # For image conversions.
    pkgsUnstable.ffmpegthumbnailer # For video thumbnails.
    pkgsUnstable.trash-cli # Trash command line to move stuff to trash.

    # Disk
    pkgsUnstable.dua # Disk Usage Analyzer.
    pkgsUnstable.baobab # Analyze disks.
    pkgsUnstable.restic # Backup tool
    pkgsUnstable.gparted # Disk utility.
    pkgsUnstable.gnome-disk-utility # Easy disk utility `gdisk`.

    # Programming
    pkgsUnstable.parallel
    (lib.hiPrio pkgsUnstable.chezmoi)
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
    pkgsUnstable.yarn
    pkgsUnstable.remarshal
    pkgsUnstable.just
    pkgsUnstable.dive # Inspect container images.

    # FHS Environment with nix-alien
    inputs.nix-alien.packages.${pkgs.system}.nix-alien

    # Linters
    pkgsUnstable.markdownlint-cli
    pkgsUnstable.yamllint
    pkgsUnstable.nodePackages.jsonlint
    pkgsUnstable.codespell
    pkgsUnstable.typos
    pkgsUnstable.shfmt
    pkgsUnstable.shellcheck

    ## Lsp
    # rust-analyzer and clangd come with
    # the toolchain.
    pkgsUnstable.gopls
    pkgsUnstable.golangci-lint-langserver
    # pkgsUnstable.texlab
    pkgsUnstable.typos-lsp
    pkgsUnstable.nixd
    pkgsUnstable.marksman
    pkgsUnstable.lua-language-server
    pkgsUnstable.nodePackages.dockerfile-language-server-nodejs
    pkgsUnstable.nodePackages.bash-language-server
    pkgsUnstable.nodePackages.vscode-json-languageserver
    pkgsUnstable.nodePackages.yaml-language-server

    ## Python
    pkgsUnstable.python313
    pkgsUnstable.python313Packages.pip
    pkgsUnstable.python313Packages.isort
    pkgsUnstable.python313Packages.black
    pkgsUnstable.pyright

    ## Node (markdown-preview)
    pkgsUnstable.nodejs

    ## Nix
    pkgsUnstable.nix-tree
    pkgsUnstable.nixpkgs-lint
    pkgsUnstable.stdenv.cc # for neovim treesitter.
    pkgsUnstable.nixfmt-rfc-style
    pkgsUnstable.dconf2nix # To generate the `dconf` settings.
    pkgsUnstable.comma # Run , jellyfin to quickly run a nix package.

    ## Lua
    pkgsUnstable.stylua

    # Config Files
    pkgsUnstable.nodePackages.prettier

    # Writing
    # pkgsUnstable.texlive.combined.scheme-full
    pkgsUnstable.pandoc

    # Calendar/Mail (our version)
    pkgs.khal # CLI Calendar

    # MultiMedia
    pkgsUnstable.bitwarden # Password manager
    pkgsUnstable.bitwarden-cli
    pkgsUnstable.bazecor # Dygma Defy Keyboard.
    pkgsUnstable.signal-desktop-bin # Messaging app
    pkgsUnstable.element-desktop # Matrix client.
    pkgsUnstable.slack # Messaging app
    pkgsUnstable.transmission_3-gtk
    pkgsUnstable.ffmpeg # Movie converter
    pkgsUnstable.vlc # Movie player
    pkgsUnstable.amberol # Music player
    pkgsUnstable.showmethekey # Screencast the key-presses.

    pkgsUnstable.inkscape # Vector graphics
    pkgsUnstable.krita # Painting
    pkgsUnstable.nomacs # Image viewer
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
    pkgsUnstable.firefox
    pkgsUnstable.google-chrome
    pkgsUnstable.libreoffice

    # News
    pkgsUnstable.newsflash # RSS Reader

    # Sound
    pkgsUnstable.headsetcontrol
    pkgsUnstable.noson # Sonos device
    pkgs.ardour # Music recording

    # VPN
    pkgsUnstable.wgnord

    # Camera
    pkgsUnstable.guvcview # Camera control

    # Remote Desks
    pkgsUnstable.rustdesk # Remote desktop
    pkgsUnstable.anydesk

    # Dictionaries
    pkgsUnstable.aspell
    pkgsUnstable.aspellDicts.en
    pkgsUnstable.aspellDicts.en-computers
    pkgsUnstable.hunspell
    pkgsUnstable.hunspellDicts.en-us
  ];

}
