# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs, ...}: {
  # example = pkgs.callPackage ./example { };

  # Package which ads a Filesystem Hierarchy Standard environment
  # with `fhs`. Build with `nix build .#fhs`
  # fhs = pkgs.callPackage ./fhs.nix {};

  # Batman Timezone Converter
  batz = pkgs.callPackage ./batz {};

  # # Google calendar integration into waybar.
  # nextmeeting = pkgs.callPackage ./nextmeeting {};
}
