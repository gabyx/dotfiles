# Define different shells.
{
  lib,
  inputs,
  repo,
  ...
}:
{
  perSystem =
    {
      pkgs,
      repo',
      ...
    }:
    {
      # Define all shells over the set of `devenvModules`.
      devShells = lib.attrsets.mapAttrs (
        _name: modules:
        repo.lib.shell.mkShell {
          inherit
            pkgs
            modules
            inputs
            ;
          inherit (pkgs) system;
        }
      ) repo'.devenvModules;
    };
}
