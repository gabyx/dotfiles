{ pkgs, outputs, ... }:
let
  system = pkgs.system;
in
{
  home.packages = [
    outputs.packages.${system}.gabyx-shell-run
    outputs.packages.${system}.gabyx-shell-source
    outputs.packages.${system}.gabyx-python
  ];
}
