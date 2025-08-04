{ inputs, lib, ... }:
{
  perSystem =
    { pkgsUnstable, ... }:
    let
      nvimBuilds = import ./neovim {
        inherit inputs lib;
        pkgs = pkgsUnstable;
      };

      # Package which ads a Filesystem Hierarchy Standard environment
      # with `fhs`. Build with `nix build .#fhs`
      # fhs = pkgs.callPackage ./fhs.nix {};

      # Batman Timezone Converter.
      # batz = pkgs.callPackage ./batz { };
    in
    {
      packages = {
        inherit (nvimBuilds) nvim nvim-nightly nvim-treesitter-install;
      };
    };
}
