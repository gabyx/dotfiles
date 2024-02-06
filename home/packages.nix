{
  lib,
  pkgs,
  pkgsStable,
  inputs,
  ...
}: let
  # Define some special packages.
  wezterm-nightly = inputs.wezterm.packages."${pkgs.system}".default;

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
    git
    git-lfs
    tig

    gnome.zenity # For dialogs over githooks.

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
    trash-cli
    etcher
    gparted
    gnome.gnome-disk-utility

    # Programming
    (lib.hiPrio parallel)
    chezmoi
    lazygit
    delta
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
    rnix-lsp
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
    pkgconf

    ## C++
    cmake
    # cppcheck
    # gcc13
    # gdb
    # llvmPkgs.bintools
    # llvmPkgs.openmp
    # # (hiPrio llvmPkgs.lld)
    # llvmPkgs.llvm
    # llvmPkgs.lldb
    # # # llvmPkgs.libclc
    # llvmPkgs.libclang
    # llvmPkgs.libllvm
    # llvmPkgs.libcxx
    # (hiPrio llvmPkgs.libstdcxxClang)

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
    nodePackages.pyright

    ## Nix
    nixpkgs-lint
    stdenv.cc
    alejandra
    nixfmt

    ## Lua
    stylua

    # Config Files
    nodePackages.prettier

    # Writing
    texlive.combined.scheme-full
    pandoc

    # MultiMedia
    bitwarden # Password manager
    bitwarden-cli
    signal-desktop # Messaging app
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
    thunderbird
    libreoffice

    ## Sonos Device
    noson
    (mkchromecast.override {enableSonos = true;})

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
