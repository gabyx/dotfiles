{
  lib,
  pkgs,
  pkgsStable,
  inputs,
  ...
}: {
  programs = {
    neovim = {
      viAlias = true;
      vimAlias = true;
      plugins = [
        pkgs.vimPlugins.nvim-treesitter
        pkgs.vimPlugins.nvim-treesitter.withAllGrammars
      ];
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  home.packages = with pkgs; [
    # Basics
    git
    git-lfs

    gnome.seahorse

    kitty
    wezterm
    tmux

    # Editors
    pkgsStable.neovim
    vscode

    # Tools
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
    gcc
    gdb

    ## C++
    cmake
    llvmPackages_16.clang-unwrapped

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
    ymuse # Sound player
    zoom-us # Video calls
    firefox
    google-chrome
    thunderbird
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
