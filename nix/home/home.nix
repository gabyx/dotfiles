# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
# Search for all options using: https://mipmip.github.io/home-manager-option-search
{
  osConfig,
  inputs,
  outputs,
  system,
  ...
}:
{
  # You can import other home-manager modules here
  imports = [
    inputs.nix-index-database.homeModules.nix-index
    inputs.agenix.homeManagerModules.default

    ./environment.nix
    ./packages.nix
    ./scripts.nix
    ./tmux.nix
    ./programs.nix
    ./services.nix
    ./display.nix
    ./xdg.nix
    ./virtualization.nix
    ./mail.nix

    outputs.modules.homeManager.chezmoi
  ];

  home = rec {
    username = osConfig.settings.user.name;
    homeDirectory = osConfig.settings.user.home;

    # Add support for .local/bin
    sessionPath = [ "${homeDirectory}/.local/bin" ];
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

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.11";
}
