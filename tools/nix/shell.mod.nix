{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      devShells = {
        default = pkgs.mkShellNoCC {
          packages = with pkgs; [
            coreutils
            findutils

            (lib.hiPrio pkgs.git)
            pkgs.git-lfs
            pkgs.bash

            pkgs.coreutils
            pkgs.findutils
            pkgs.direnv # Auto apply stuff on entering directory `cd`.
            pkgs.just # Command executor like `make` but better.

            pkgs.fd
          ];
        };
      };
    };
}
