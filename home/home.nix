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
  outputs,
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

    ./environment.nix
    ./packages.nix
    ./programs.nix
    ./services.nix
    ./xdg.nix

    outputs.homeManagerModules.tmux
    outputs.homeManagerModules.chezmoi
    outputs.homeManagerModules.astronvim
    outputs.homeManagerModules.bazecor

    inputs.nix-index-database.hmModules.nix-index
  ];

  home = rec {
    username = osConfig.settings.user.name;
    homeDirectory = "/home/${osConfig.settings.user.name}";

    # Add support for .local/bin
    sessionPath = ["${homeDirectory}/.local/bin"];
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;
  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # Enable chezmoi and its config files.
  chezmoi = {
    enable = true;
    url = "https://github.com/gabyx/dotfiles.git";
    ref = "main";
    workspace = "private";
  };

  # Enable astronmvim setup.
  astronvim = {
    enable = true;
    astroVimUserUrl = "https://github.com/gabyx/astrovim.git";
    astroVimUserRef = "main";
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
