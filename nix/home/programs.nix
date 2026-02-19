{ inputs, pkgs, ... }:
{
  imports = [
    inputs.direnv-instant.homeModules.direnv-instant
  ];

  programs = {
    direnv-instant.enable = true;
    direnv = {
      enable = true;
      package = pkgs.direnv;
      nix-direnv = {
        enable = true;
        package = pkgs.nix-direnv;
      };
    };
  };
}
