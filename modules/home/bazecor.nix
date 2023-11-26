{
  lib,
  pkgs,
  pkgsStable,
  inputs,
  ...
}: let
  # Override `bazecor` derivation for newer version.
  bazecorLatest = pkgs.callPackage ./pkgs/bazecor {};
in {
  home.packages = [
    bazecorLatest
  ];
}
