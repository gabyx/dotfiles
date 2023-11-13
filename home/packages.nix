{
  lib,
  pkgs,
  pkgsUnstable,
  ...
}: {
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  home.packages = with pkgs; [
    # Basics
    git
    git-lfs

    gnome.seahorse

    pkgsUnstable.kitty
    pkgsUnstable.wezterm
    pkgsUnstable.tmux

    # Editors
    pkgsUnstable.neovim
    vscode

    # Tools
    chezmoi
    etcher
    gparted
    lazygit
    delta

    # Programming
    kdiff3
    jq
    yq
    shfmt
    shellcheck

    gnumake
    autoconf
    libtool
    pkgconf
    gcc
    gdb

    cmake
    (lib.meta.hiPrio clang_16)
    clang-tools_16

    go

    nodejs
    openjdk

    rustup

    python311
    python311Packages.pip
    python311Packages.black
    nodePackages.pyright

    stylua

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
