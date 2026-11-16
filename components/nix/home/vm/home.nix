{ ... }:
{
  imports = [
    ./shell.nix
    ./session.nix
    ./tmux.nix
    ./packages.nix
  ];

  # Enable home-manager.
  programs.home-manager.enable = true;

  home.stateVersion = "26.05";
}
