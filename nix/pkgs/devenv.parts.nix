{
  lib,
  ...
}:
{
  perSystem =
    {
      pkgsUnstable,
      inputs',
      self',
      ...
    }:
    let
      pkgs = pkgsUnstable;
    in
    {
      repo.devenvModules =
        let
          go = pkgs.go_1_26;

          build-go = [
            {
              quitsh.toolchains = [ "build-go" ];
              quitsh.languages.go = {
                enable = true;
                # To make CGO and the debugger delve work.
                # https://nixos.wiki/wiki/Go#Using_cgo_on_NixOS
                enableHardeningWorkaround = true;
                package = go;
              };

              packages = [
                pkgs.git
              ];
            }
          ];

          lint-go = [
            {
              quitsh.toolchains = [ "lint-go" ];

              packages = [
                pkgs.git
                pkgs.golangci-lint
                go
              ];
            }
          ];

          # Go development.
          dev-go = [
            {
              packages = [
                pkgs.golangci-lint
                pkgs.golangci-lint-langserver
                pkgs.typos-lsp
              ];
            }
          ];

          common = [
            {
              packages = [
                (lib.hiPrio pkgs.git)
                pkgs.git-lfs
                pkgs.bash
                pkgs.coreutils
                pkgs.findutils
                pkgs.direnv # Auto apply stuff on entering directory `cd`.
                pkgs.just # Command executor like `make` but better.
                pkgs.fd
                pkgs.cachix
                pkgs.nushell
              ];
            }
          ];

          default = common ++ [
            {
              quitsh.toolchains = [ "general" ];
              packages = [
                pkgsUnstable.nix-output-monitor
                inputs'.multiverse.packages.mvs

                pkgsUnstable.caligula # Burn ISOs to USB.
                self'.packages.gabyx-cli
              ];

              enterShell = ''
                just --list
              '';
            }
          ];

          gabyx-cli = common ++ build-go ++ lint-go ++ dev-go;
        in
        {
          # Main shells:
          inherit default gabyx-cli;

          # Toolchains:
          inherit build-go lint-go dev-go;
        };
    };
}
