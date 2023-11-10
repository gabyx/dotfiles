{
  config,
  pkgs,
  pkgs-unstable,
  ...
}: {
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
    tree
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
    usbutils
    btop
    xorg.xev # For keyboard key press properties.
    xorg.xkbcomp # For checking xkb keyboard symbol tables.
    git
    git-lfs
    gnome.seahorse
    gnutar
    unzip
    wget
    zsh
    pkgs-unstable.wezterm
    tmux
    #
    # Editors
    pkgs-unstable.neovim
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
    qalculate-gtk
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
    shfmt
    shellcheck
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
    python311Packages.black
    nodePackages.pyright
    stylua
    nodePackages.prettier
    texlive.combined.scheme-full
    #
    # MultiMedia
    bitwarden # Password manager
    signal-desktop # Messaging app
    slack # Messaging app
    pandoc # Markdown processor
    transmission # Bittorent
    transmission-gtk
    ffmpeg # Movie converter
    vlc # Movie player
    inkscape # Vector graphics
    krita # Painting
    zathura # Simple document viewer
    ymuse # Sound player
    screenfetch
    scrot
    redshift
    zoom-us # Video calls
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
    alejandra
    nixfmt
  ];

  # # Install Neovim nightly if needed. Carefull with Astrovim Setup.
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
