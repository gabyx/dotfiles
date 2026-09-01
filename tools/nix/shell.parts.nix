{ lib, ... }:
{
  perSystem =
    {
      self',
      inputs',
      pkgsUnstable,
      ...
    }:
    {
      devShells = {
        default = pkgsUnstable.mkShellNoCC {
          packages = [
            (lib.hiPrio pkgsUnstable.git)
            pkgsUnstable.git-lfs
            pkgsUnstable.bash
            pkgsUnstable.coreutils
            pkgsUnstable.findutils
            pkgsUnstable.direnv # Auto apply stuff on entering directory `cd`.
            pkgsUnstable.just # Command executor like `make` but better.
            pkgsUnstable.fd
            pkgsUnstable.nushell
            pkgsUnstable.nix-output-monitor

            inputs'.multiverse.packages.mvs

            self'.packages.treefmt
          ];

          shellHook = ''
            just --list
          '';
        };
      };
    };
}
