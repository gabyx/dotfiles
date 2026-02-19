{ ... }:
{
  flake.modules.nixos = {
    adblock-dns = import ./adblock-dns.nix;
    backup = import ./backup.nix;
    bluetooth = import ./bluetooth.nix;
    containerization = import ./containerization.nix;
    display = import ./display.nix;
    display-resolution = import ./display-resolution.nix;
    environment = import ./environment.nix;
    flatpak = import ./flatpak.nix;
    fonts = import ./fonts.nix;
    home-manager = import ./home-manager.nix;
    kernel = import ./kernel.nix;
    keyboard = import ./keyboard.nix;
    music = import ./music.nix;
    networking = import ./networking.nix;
    networking-profiles = import ./networking-profiles;
    nix = import ./nix.nix;
    packages = import ./packages.nix;
    printing = import ./printing.nix;
    programs = import ./programs.nix;
    secrets = import ./secrets.nix;
    security = import ./security.nix;
    services = import ./services.nix;
    sound = import ./sound.nix;
    steam = import ./steam.nix;
    system = import ./system.nix;
    time = import ./time.nix;
    user = import ./user.nix;
    virtualization = import ./virtualization.nix;
    vpn = import ./vpn.nix;
    vpn-wgnord = import ./vpn-wgnord.nix; # Pure Module.
    windowing = import ./windowing.nix;
    yubikey = import ./yubikey.nix;
  };
}
