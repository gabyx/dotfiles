{
  inputs,
  lib,
  ...
}:
{
  perSystem =
    { pkgs, pkgsUnstable, ... }:
    let
      shell = import ./jailed/shell.nix {
        inherit lib pkgs pkgsUnstable;
        inherit (inputs) jail-nix;
      };

      apps = import ./jailed/apps.nix {
        inherit lib pkgs pkgsUnstable;
        inherit (inputs) jail-nix;
      };
    in
    {
      packages = shell // apps;
    };
}
