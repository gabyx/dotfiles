# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
# Search for all options using: https://mipmip.github.io/home-manager-option-search
{
  config,
  lib,
  pkgs,
  pkgsStable,
  osConfig,
  inputs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix

    ./packages.nix
    # ./chezmoi.nix
  ];

  home = rec {
    username = osConfig.settings.user.name;
    homeDirectory = "/home/${osConfig.settings.user.name}";
    # Add support for .local/bin
    sessionPath = ["${homeDirectory}/.local/bin"];
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];

  # Enable home-manager and git
  programs.home-manager.enable = true;
  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # Enable chezmoi and its config files.
  # chezmoi = {
  #   enable = true;
  #   sourceDir = inputs.self;
  #   extraArgsInit = [
  #     "--promptChoice"
  #     "What type of workspace are you on=private"
  #   ];
  # };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
