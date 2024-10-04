# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{ pkgs, ... }:
{
  # example = pkgs.callPackage ./example { };

  # Package which ads a Filesystem Hierarchy Standard environment
  # with `fhs`. Build with `nix build .#fhs`
  # fhs = pkgs.callPackage ./fhs.nix {};

  # Batman Timezone Converter
  batz = pkgs.callPackage ./batz { };

  i3-back = pkgs.callPackage ./i3-back { };
}
