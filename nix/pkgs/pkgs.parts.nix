{
  lib,
  inputs,
  ...
}:
{
  perSystem =
    {
      inputs',
      pkgsUnstable,
      mvs,
      ...
    }:
    let
      # Package which ads a Filesystem Hierarchy Standard environment
      # with `fhs`. Build with `nix build .#fhs`
      # fhs = pkgs.callPackage ./fhs.nix {};

      # Batman Timezone Converter.
      # batz = pkgs.callPackage ./batz { };

      gabyx-cli = pkgsUnstable.callPackage ./gabyx-cli { };
      tone3000-plugin = pkgsUnstable.callPackage ./tone3000-plugin { };
      mt-powerdrumkit = pkgsUnstable.callPackage ./mt-powerdrumkit { };

      nvim = import ./nvim-nvf {
        inherit lib;
        inherit inputs;
        inherit inputs';

        # The pinned nvim packages.
        # nixos-unstable.
        pkgs = mvs.at "567a49d1913ce81ac6e9582e3553dd90a955875f";

        # The unstable packages.
        inherit pkgsUnstable;
      };

      docker-sbx = pkgsUnstable.callPackage ./docker-sbx { };
    in
    {
      packages = {
        inherit (nvim)
          nvim-gabyx
          nvim-gabyx-config
          nvim-gabyx-nightly
          nvim-gabyx-nightly-config
          ;

        inherit
          tone3000-plugin
          mt-powerdrumkit
          ;

        inherit docker-sbx;
        inherit gabyx-cli;
      };
    };
}
