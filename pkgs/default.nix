# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{ inputs, pkgs, ... }:
let
  nvimBuilds = import ./nvim {
    inherit inputs;
    pkgs = pkgs.unstable;
  };
in
{
  # Neovim builds.
  inherit (nvimBuilds) nvim-gabyx nvim-gabyx-nightly nvim-gabyx-config;

  # Package which ads a Filesystem Hierarchy Standard environment
  # with `fhs`. Build with `nix build .#fhs`
  # fhs = pkgs.callPackage ./fhs.nix {};

  # Batman Timezone Converter.
  # batz = pkgs.callPackage ./batz { };
}
