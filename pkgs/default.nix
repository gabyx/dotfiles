# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  # nvfBuilds = import ./nvf {
  #   inherit inputs;
  #   pkgs = pkgs.unstable;
  # };

  nvimBuilds = import ./neovim {
    inherit inputs lib;
    pkgs = pkgs.unstable;
  };
in
{
  # Neovim.
  # inherit (nvfBuilds) nvim-gabyx nvim-gabyx-nightly nvim-gabyx-config;
  inherit (nvimBuilds) nvim nvim-nightly nvim-treesitter-install;

  # Package which ads a Filesystem Hierarchy Standard environment
  # with `fhs`. Build with `nix build .#fhs`
  # fhs = pkgs.callPackage ./fhs.nix {};

  # Batman Timezone Converter.
  # batz = pkgs.callPackage ./batz { };
}
