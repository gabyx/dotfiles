{
  lib,
  pkgs,
  pkgsStable,
  inputs,
  outputs,
  ...
}: let
  # Define some special packages.
  wezterm-nightly = inputs.wezterm.packages."${pkgs.system}".default;
  githooks = inputs.githooks.packages."${pkgs.system}".default;

  # llvm 16 packages have a problem:
  # https://github.com/NixOS/nixpkgs/issues/244609
  llvmPkgs = pkgs.llvmPackages_15;
  clangTools = pkgs.clang-tools_15;
in {
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  home.packages = with pkgs; [
    # Basics
    age # Encryption tool.
    libsecret # secret-tool to access gnome-keyring
    git
    git-lfs
    git-town
    githooks
    tig

    gnome.zenity # For dialogs over githooks and calendar.

    gnome.seahorse

    starship
    kitty
    wezterm-nightly

    # Editors
    vscode
    # neovim configured in `astronvim.nix`

    # Tools
    restic # Backup tool
    lf # File manager
    chafa # For Sixel pictures in terminal
    exiftool # For image meta preview.
    atool # For archive preview
    bat # For text preview with syntax highlight and Git integration.
    poppler_utils # For image conversions.
    ffmpegthumbnailer # For video thumbnails.
    trash-cli # Trash command line to move stuff to trash.
    gparted # Disk utility.
    gnome.gnome-disk-utility # Easy disk utility `gdisk`.

    # Programming
    (lib.hiPrio parallel)
    chezmoi
    lazygit
    delta
    meld
    kubectl
    kind # Simple kubernetes for local development.
    k9s # Kubernetes management CLI tool
    kdiff3
    jq
    yq-go
    yarn
    just

    # FHS Environment with nix-alien
    inputs.nixAlien.packages.${pkgs.system}.nix-alien

    # Linters
    markdownlint-cli
    yamllint
    nodePackages.jsonlint
    codespell
    typos
    shfmt
    shellcheck

    ## Lsp
    # rust-analyzer and clangd come with
    # the toolchain.
    gopls
    golangci-lint-langserver
    texlab
    nil
    marksman
    lua-language-server
    nodePackages.dockerfile-language-server-nodejs
    nodePackages.bash-language-server
    nodePackages.vscode-json-languageserver
    nodePackages.yaml-language-server

    ## Debug Adapters
    # lldb-code is installed in llvm
    delve

    ## C
    gnumake
    autoconf
    libtool
    pkg-config

    ## C++
    cmake

    ## Go
    go
    goreleaser
    golangci-lint
    gotools

    ## Node
    nodejs

    ## Java
    openjdk

    ## Rust
    rustup

    ## Python
    python311
    python311Packages.pip
    python311Packages.isort
    python311Packages.black
    nodePackages.pyright

    ## Nix
    nix-tree
    nixpkgs-lint
    stdenv.cc
    alejandra
    nixfmt-rfc-style
    dconf2nix # To generate the `dconf` settings.

    ## Lua
    stylua

    # Config Files
    nodePackages.prettier

    # Writing
    texlive.combined.scheme-full
    pandoc

    # Calendar/Mail
    khal # CLI Calendar
    nextmeeting # Show meeting in waybar
    gcalcli # Google Calender CLI (used also in nextmeeting)
    batz # Timezone converter (for nextmeeting)

    # MultiMedia
    bitwarden # Password manager
    bitwarden-cli
    bazecor # Dygma Defy Keyboard.
    signal-desktop # Messaging app
    element-desktop # Matrix client.
    slack # Messaging app
    transmission-gtk
    ffmpeg # Movie converter
    vlc # Movie player
    inkscape # Vector graphics
    krita # Painting
    nomacs # Image viewer
    zathura # Simple document viewer
    pdfarranger # PDF arranger
    ghostscript
    imagemagick_light # Converter tools
    ymuse # Sound player
    zoom-us # Video calls
    deluge # Bittorrent client
    firefox
    google-chrome
    libreoffice

    # Sound
    headsetcontrol
    noson # Sonos device
    (mkchromecast.override {enableSonos = true;}) # Cast to Sonos device.

    # VPN
    wgnord

    # Dictionaries
    aspell
    aspellDicts.en
    aspellDicts.en-computers
    hunspell
    hunspellDicts.en-us
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
