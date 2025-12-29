{ inputs, lib, ... }:
{
  perSystem =
    { pkgsUnstable, system, ... }:
    let
      nvimBuilds = import ./neovim {
        inherit system inputs lib;
        pkgs = pkgsUnstable;
      };

      # Package which ads a Filesystem Hierarchy Standard environment
      # with `fhs`. Build with `nix build .#fhs`
      # fhs = pkgs.callPackage ./fhs.nix {};

      # Batman Timezone Converter.
      # batz = pkgs.callPackage ./batz { };

      gabyx = import ./scripts { inherit pkgsUnstable; };

      neural-amp-modeler-lv2 = pkgsUnstable.callPackage ./neural-amp-modeler-lv2 { };
    in
    {
      packages = {
        inherit (nvimBuilds) nvim nvim-nightly nvim-treesitter-install;
        inherit neural-amp-modeler-lv2;
      }
      // gabyx;
    };
}
