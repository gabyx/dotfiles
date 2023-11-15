# Add your reusable NixOS modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{
  # List your module files here
  display = import ./display.nix;
  display-resolution = import ./display-resolution.nix;
  environment = import ./environment.nix;
  fonts = import ./fonts.nix;
  home-manager = import ./home-manager.nix;
  keyboard = import ./keyboard.nix;
  networking = import ./networking.nix;
  nix = import ./nix.nix;
  packages = import ./packages.nix;
  printing = import ./printing.nix;
  programs = import ./programs.nix;
  security = import ./security.nix;
  services = import ./services.nix;
  sound = import ./sound.nix;
  time = import ./time.nix;
  user = import ./user.nix;
  virtualization = import ./virtualization.nix;
  windowing = import ./windowing.nix;
}
