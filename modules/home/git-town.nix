{
  lib,
  pkgs,
  pkgsStable,
  inputs,
  ...
}: let
  # Override `git-town` derivation for newer version.
  gitTown = pkgs.callPackage ./pkgs/git-town {};
in {
  home.packages = [
    gitTown
  ];
}
