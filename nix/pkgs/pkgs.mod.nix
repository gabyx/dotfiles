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

      nvim-nvf = import ./nvf {
        inherit lib;
        inherit inputs;
        inherit inputs';

        # The pinned packages.
        pkgs = inputs'.nvim-nixpkgs.legacyPackages;
        # The unstable packages.
        inherit pkgsUnstable;
      };
    in
    {
      packages = {
        inherit (nvim-nvf) nvim-gabyx nvim-gabyx-config;
        inherit neural-amp-modeler-lv2;
        inherit age-plugin-fido2prf;
        inherit age-plugin-fido2-hmac;
      }
      // gabyx-scripts;
    };
}
