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
    xorg.xev # Keyboard Key Press Properties
    # (pkgs.ripgrep-all.overrideAttrs (old: {
    # 	doInstallCheck = false;
    # }))
    git
    git-lfs
    gnome.seahorse
    gnutar
    unzip
    wget
    zsh
    wezterm
    tmux
    #
    # Editors
    neovim
    vscode
    #
    # Tools
    appimage-run
    chezmoi
    delta
    etcher
    gparted
    kdiff3
    lazygit
    silver-searcher
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
    #
    # Programming
    jq
    yq
    llvmPackages_16.clang-unwrapped
    cmake
    gcc
    gdb
    gnumake
    go
    libclang
    libtool
    llvm
    nodejs
    openjdk
    rustup
    python311
    python311Packages.pip
    texlive.combined.scheme-full
    #
    # MultiMedia
    bitwarden # Password Manager
    signal-desktop
    slack
    pandoc
    transmission
    transmission-gtk
    ffmpeg
    vlc
    inkscape
    krita
    zathura
    screenfetch
    scrot
    redshift
    zoom-us
    firefox
    google-chrome
    thunderbird
    #
    # Dictionaries
    aspell
    aspellDicts.en
    aspellDicts.en-computers
    hunspell
    hunspellDicts.en-us
    # # GTK Engins (GUI Library)
    # gtk-engine-murrine
    # gtk_engines
    # gsettings-desktop-schemas
    # lxappearance
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
