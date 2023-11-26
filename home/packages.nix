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
    git
    git-lfs

    gnome.seahorse

    kitty
    wezterm-nightly

    # Editors
    vscode
    # neovim configured in `astronvim.nix`

    # Tools
    lf # File manager
    chafa # For Sixel pictures in terminal
    exiftool # For image meta preview.
    atool # For archive preview
    bat # For text preview with syntax highlight and Git integration.
    poppler_utils # For image conversions.
    ffmpegthumbnailer # For video thumbnails.

    trash-cli
    chezmoi
    etcher
    gparted
    lazygit
    delta

    # FHS Environment with nix-alien
    inputs.nixAlien.packages.${pkgs.system}.nix-alien

    # Programming
    kdiff3
    jq
    yq
    shfmt
    shellcheck
    just

    ## C
    gnumake
    autoconf
    libtool
    pkgconf

    ## C++
    cmake
    valgrind
    cppcheck
    # gcc13
    gdb
    llvmPkgs.bintools
    llvmPkgs.openmp
    llvmPkgs.lld
    llvmPkgs.llvm
    llvmPkgs.lldb
    # llvmPkgs.libclc
    llvmPkgs.libclang
    llvmPkgs.libllvm
    llvmPkgs.libcxx
    (hiPrio llvmPkgs.libstdcxxClang)

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
    signal-desktop # Messaging app
    slack # Messaging app
    transmission-gtk
    ffmpeg # Movie converter
    vlc # Movie player
    inkscape # Vector graphics
    krita # Painting
    zathura # Simple document viewer
    pdfarranger # PDF arranger
    ymuse # Sound player
    zoom-us # Video calls
    firefox
    google-chrome
    thunderbird
    libreoffice
    ## Sonos Device
    noson
    (mkchromecast.override {enableSonos = true;})

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
