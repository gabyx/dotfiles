{
  lib,
  pkgs,
  pkgsStable,
  inputs,
  outputs,
  ...
}:
let
  # Define some special packages.
  wezterm-nightly = inputs.wezterm.packages."${pkgs.system}".default;
  githooks = inputs.githooks.packages."${pkgs.system}".default;
in
{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  home.packages = [
    # Basics
    pkgs.zoxide # A smarter cd.
    pkgs.age # Encryption tool.
    pkgs.libsecret # secret-tool to access gnome-keyring
    pkgs.git
    pkgs.git-lfs
    pkgs.git-town
    githooks
    pkgs.tig
    pkgs.seahorse
    pkgs.zenity # For dialogs over githooks and calendar.

    # Terminal
    pkgs.starship
    pkgs.kitty
    wezterm-nightly

    # Editors
    pkgs.vscode
    # neovim configured in `astronvim.nix`

    # Tools
    pkgs.restic # Backup tool
    pkgs.lf # File manager
    pkgs.chafa # For Sixel pictures in terminal
    pkgs.exiftool # For image meta preview.
    pkgs.atool # For archive preview
    pkgs.bat # For text preview with syntax highlight and Git integration.
    pkgs.poppler_utils # For image conversions.
    pkgs.ffmpegthumbnailer # For video thumbnails.
    pkgs.trash-cli # Trash command line to move stuff to trash.
    pkgs.gparted # Disk utility.
    pkgs.gnome-disk-utility # Easy disk utility `gdisk`.

    # Programming
    (lib.hiPrio pkgs.parallel)
    pkgs.chezmoi
    pkgs.lazygit
    pkgs.delta
    pkgs.meld
    pkgs.kubectl
    pkgs.kind # Simple kubernetes for local development.
    pkgs.k9s # Kubernetes management CLI tool
    pkgs.kdiff3
    pkgs.jq
    pkgs.yq-go
    pkgs.yarn
    pkgs.just
    pkgs.dive # Inspect container images.

    # FHS Environment with nix-alien
    inputs.nixAlien.packages.${pkgs.system}.nix-alien

    # Linters
    pkgs.markdownlint-cli
    pkgs.yamllint
    pkgs.nodePackages.jsonlint
    pkgs.codespell
    pkgs.typos
    pkgs.shfmt
    pkgs.shellcheck

    ## Lsp
    # rust-analyzer and clangd come with
    # the toolchain.
    pkgs.gopls
    pkgs.golangci-lint-langserver
    pkgs.texlab
    pkgs.typos-lsp
    pkgs.nixd
    pkgs.marksman
    pkgs.lua-language-server
    pkgs.nodePackages.dockerfile-language-server-nodejs
    pkgs.nodePackages.bash-language-server
    pkgs.nodePackages.vscode-json-languageserver
    pkgs.nodePackages.yaml-language-server

    ## Debug Adapters
    # lldb-code is installed in llvm
    pkgs.delve

    ## C
    pkgs.gnumake
    pkgs.autoconf
    pkgs.libtool
    pkgs.pkg-config

    ## C++
    pkgs.cmake

    ## Go
    pkgs.go
    pkgs.goreleaser
    pkgs.golangci-lint
    pkgs.gotools

    ## Node
    pkgs.nodejs

    ## Java
    pkgs.openjdk

    ## Rust
    pkgs.rustup

    ## Python
    pkgs.python311
    pkgs.python311Packages.pip
    pkgs.python311Packages.isort
    pkgs.python311Packages.black
    pkgs.pyright

    ## Nix
    pkgs.nix-tree
    pkgs.nixpkgs-lint
    pkgs.stdenv.cc # for neovim treesitter.
    pkgs.alejandra
    pkgs.nixfmt-rfc-style
    pkgs.dconf2nix # To generate the `dconf` settings.

    ## Lua
    pkgs.stylua

    # Config Files
    pkgs.nodePackages.prettier

    # Writing
    pkgs.texlive.combined.scheme-full
    pkgs.pandoc

    # Calendar/Mail
    pkgs.khal # CLI Calendar
    pkgs.batz # Timezone converter (for nextmeeting)

    # MultiMedia
    pkgs.bitwarden # Password manager
    pkgs.bitwarden-cli
    pkgs.bazecor # Dygma Defy Keyboard.
    pkgs.signal-desktop # Messaging app
    pkgs.element-desktop # Matrix client.
    pkgs.slack # Messaging app
    pkgs.transmission_3-gtk
    pkgs.ffmpeg # Movie converter
    pkgs.vlc # Movie player
    pkgs.showmethekey # Screencast the key-presses.

    pkgs.inkscape # Vector graphics
    pkgs.krita # Painting
    pkgs.nomacs # Image viewer
    pkgs.zathura # Simple document viewer
    pkgs.kdePackages.okular # Another PDF viewer
    pkgs.pdfarranger # PDF arranger
    pkgs.ghostscript
    pkgs.imagemagick_light # Converter tools
    pkgs.ymuse # Sound player
    pkgs.zoom-us # Video calls
    pkgs.deluge # Bittorrent client
    pkgs.firefox
    pkgs.google-chrome
    pkgs.libreoffice

    # Sound
    pkgs.headsetcontrol
    pkgs.noson # Sonos device

    # VPN
    pkgs.wgnord

    # Remote Desks
    pkgs.anydesk

    # Dictionaries
    pkgs.aspell
    pkgs.aspellDicts.en
    pkgs.aspellDicts.en-computers
    pkgs.hunspell
    pkgs.hunspellDicts.en-us
  ];

  # # Install Neovim nightly if needed. Careful with Astrovim Setup.
  # nixpkgs.overlays = [
  #   (import (builtins.fetchTarball {
  #     url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
  #   }))
  #   (self: super: {
  #    neovim = super.neovim.override {
  #      viAlias = true;
  #      vimAlias = true;
  #    };
  #  })
  # ];
}
