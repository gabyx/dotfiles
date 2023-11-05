{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Basic
    autoconf
    bash
    binutils
    coreutils-full
    curl
    direnv
    dmidecode
    fd
    file
    findutils
    fzf
    killall
    libGL
    libGLU 
    lshw
    mkpasswd
    mlocate
    ncurses5
    openvpn
    pciutils
    ripgrep
    # (pkgs.ripgrep-all.overrideAttrs (old: { 
    # 	doInstallCheck = false; 
    # })) 
    gnome.seahorse
    gnutar
    unzip
    wget
    zsh
    # Editors
    neovim
    vscode
    #
    # Tools
    dunst
    delta
    etcher
    gparted
    kdiff3
    rofi # Window Switcher
    tmux
    wezterm
    chezmoi
    silver-searcher
    appimage-run
    #
    # Devices (Wacom)
    libwacom
    wacomtablet
    xf86_input_wacom
    #
    # Virtualisation
    docker
    docker-compose
    libguestfs # Needed to virt-sparsify qcow2 files
    libvirt
    spice # For automatic window resize if this conf is used as OS in VM
    spice-vdagent
    virt-manager
    # Programming
    llvmPackages_16.clang-unwrapped
    cmake
    gcc
    gdb
    git
    git-lfs
    gnumake
    go
    libclang
    libtool
    llvm
    nodejs
    openjdk
    rustup
    texlive.combined.scheme-full
    #
    # MultiMedia
    pandoc
    transmission
    transmission-gtk
    ffmpeg
    vlc
    inkscape
    krita
    xclip
    screenfetch
    scrot
    redshift
    zoom-us
    firefox
    google-chrome
    # Dictionaries
    aspell
    aspellDicts.en
    aspellDicts.en-computers
    hunspell
    hunspellDicts.en-us
    # GTK Engins (GUI Library)
    gtk-engine-murrine
    gtk_engines
    gsettings-desktop-schemas
    lxappearance
    # Nix
    nixpkgs-lint
    stdenv.cc
    nixpkgs-fmt
    nixfmt
  ];


  # Install Neovim nightly if needed. Carefull with Astrovim Setup.
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
