# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Allow proprietary software (such as the NVIDIA drivers).
  nixpkgs.config.allowUnfree = true;
  
  ### Bootloader ==============================================================
  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.useOSProber = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "nodev"; # or "nodev" for EFI only

  # Crypto
  boot.loader.grub.enableCryptodisk = true;
  boot.initrd.secrets {
    "/crypto_keyfile.bin" = null;
  }
  boot.initrd.luks.devices."luks-<YOUR_GUID>".keyfile = "/crypto_keyfile.bin";
  
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = false;
  # Allowing to change the boot order.
  boot.loader.efi.canTouchEfiVariables = true;
  # ===========================================================================

  ### Temp Files ==============================================================
  boot.tmp.useTmpfs = true;
  boot.tmp.cleanOnBoot = true;
  # ===========================================================================

  # Set your time zone.
  time.timeZone = "Europe/Zurich";
  
  ### Keyboard/Fonts Settings =================================================
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  services.xserver = {
    layout = "programmer";
    xkbVariant = "";
    xkbOptions = "ctrl:swapcaps";
    extraLayouts.programmer = {
      description = "Programmer (US)";
      languages = [ "eng" ];
      symbolsFile = "/home/nixos/nixos-configuration/configs/keyboard/symbols/programmer";
    };
  };

  console = {
    keyMap = "programmer";
    font = "JetBrainsMono Nerd Font";
  };

  # Fonts
  fonts.fonts = with pkgs; [
    corefonts
    ubuntu_font_family
    nerdfonts
  ];
  # ===========================================================================

  ### Shell ===================================================================
  programs.zsh.enable = true;
  # ===========================================================================
  
  ### Networking ==============================================================
  networking.hostName = "gabyx-nixos"; # Define your hostname.
  networking.networkmanager.enable = true;
  # networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp4s0.useDHCP = true;
  networking.interfaces.wlp3s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  # ===========================================================================

  ### Windowing (DisplayManager, DesktopManager, WindowManager)
  # Enable the X windowing system.
  services.xserver.enable = true;
  services.xserver.autorun = true;

  # Enable the Gnome Display Manager.
  services.xserver.displayManager.gdm.enable = true;
  # Do not use X11, use Wayland.
  services.xserver.displayManager.gdm.wayland = true;
  # Enable the Gnome Desktop Manager.
  services.xserver.desktopManager.gnome.enable = true;
  
  # Exclude some stupid gnome stuff.
  environment.gnome.excludePackages = (with pkgs; [ 
    gnome-photos, 
    gnome-tour 
  ])
  # ===========================================================================

  ### Graphics Settings =======================================================
  #services.xserver.videoDrivers = [ "nvidia" ];
  # services.xserver.videoDrivers = [ "nouveau" ];
  # hardware.opengl.driSupport32Bit = true;
  # ===========================================================================

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # so that gtk works properly
    extraPackages = with pkgs; [
      swaylock
      swayidle
      wl-clipboard
      wf-recorder
      # Notification daemon
      mako 
      # Screenshots
      grim
      slurp
      dmenu # Dmenu is the default in the config but i recommend wofi since its wayland native
    ];
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export _JAVA_AWT_WM_NONREPARENTING=1
      export MOZ_ENABLE_WAYLAND=1
    '';
  };

  programs.waybar.enable = true;

  # QT
  programs.qt5ct.enable = true;
  
  ### Printing ================================================================
  # Enable CUPS to print documents.
  services.printing.enable = true;
  # ===========================================================================
  
  ### Sound Settings ==========================================================
  # Enable sound.
  sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  # ===========================================================================
  
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  ### User Settings ==========================================================
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.gabyx = {
    isNormalUser = true;
    # Add libvirtd if using virt-manager
    extraGroups = [ 
      "wheel" 
      "disk" 
      "libvirtd" 
      "docker" 
      "audio" 
      "video" 
      "input" 
      "systemd-journal" 
      "networkmanager" 
      "network" 
      "davfs2" ];
  };

  users.extraGroups.vboxusers.members = [ "gabyx" ];
  # ===========================================================================

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
    ripgrep-all
    gnutar
    unzip
    wget
    zsh
    # Editors
    neovim-nightly
    vscode
    #
    # Tools
    gnome.gnome-tweaks
    dunst
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
    dockertools
    gnome3.dconf # Needed for saving settings in virt-manager
    libguestfs # Needed to virt-sparsify qcow2 files
    libvirt
    spice # For automatic window resize if this conf is used as OS in VM
    spice-vdagent
    virt-manager
    # Programming
    clang
    clangd
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
    chromium
    protonvpn-gui
    protonvpn-cli
    protonmail-bridge
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

  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
    }))
    (self: super: {
     neovim = super.neovim.override {
       viAlias = true;
       vimAlias = true;
     };
   })
  ];
  
  ### Program Settings ========================================================
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.git = {
    package = pkgs.gitFull;
    config.credential.helper = "libsecret";
  }
  # ===========================================================================
  
  ### Virtualisation ==========================================================
  programs.dconf.enable = true;
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
  #boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_blk" ];
  boot.kernelModules = [ "kvm-amd" ];

  virtualisation.libvirtd = {
    enable = true;
    qemu = { 
      ovmf.enable = true;
      runAsRoot = true;
    };
    onBoot = "ignore";
    onShutdown = "shutdown";
  };

  # Docker
  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = true;

  # virtualisation.virtualbox.guest.enable = true;
  # virtualisation.virtualbox.host.enable = true;
  # virtualisation.virtualbox.host.enableExtensionPack = true;
  # ===========================================================================

  ### Mounting ================================================================
  # Mount extra drive
  # fileSystems."/mnt/sdb1" = {
  # device = "/dev/sdb1";
  # fsType = "auto";
  # options = [ "defaults" "user" "rw" "utf8" "noauto" "umask=000" ];
  # };
  # ===========================================================================

  ### Services ================================================================
  # services.xrdp.enable = true;
  # services.xrdp.defaultWindowManager = "startplasma-x11";
  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
    };
  };
  networking.firewall.allowedTCPPorts = [ 22 ];
  # ===========================================================================

  ### Firewall ================================================================
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  # ===========================================================================

  ### NixOS Release Settings===================================================
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;
  system.stateVersion = "23.05";
  # ===========================================================================
}
