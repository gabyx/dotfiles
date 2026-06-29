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
      ...
    }:
    let
      # Package which ads a Filesystem Hierarchy Standard environment
      # with `fhs`. Build with `nix build .#fhs`
      # fhs = pkgs.callPackage ./fhs.nix {};

      # Batman Timezone Converter.
      # batz = pkgs.callPackage ./batz { };

      gabyx-scripts = import ./scripts { inherit pkgsUnstable; };
      neural-amp-modeler-lv2 = pkgsUnstable.callPackage ./neural-amp-modeler-lv2 { };

      age-plugin-fido2prf = pkgsUnstable.callPackage ./age-plugin-fido2prf { };
      age-plugin-fido2-hmac = pkgsUnstable.callPackage ./age-plugin-fido2-hmac { };

      nvim = import ./nvim-nvf {
        inherit lib;
        inherit inputs;
        inherit inputs';

        # The pinned nvim packages.
        pkgs = inputs'.nvim-nixpkgs.legacyPackages;

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

        inherit neural-amp-modeler-lv2;

        inherit age-plugin-fido2prf;
        inherit age-plugin-fido2-hmac;

        inherit docker-sbx;
      }
      // gabyx-scripts;
    };
}
