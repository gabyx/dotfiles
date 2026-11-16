{ pkgs, ... }:
# Create an FHS (Filesystem Hierarchy Standard) environment using the command `fhs`,
# enabling the execution of non-NixOS packages in NixOS!
# See https://nixos.org/manual/nixpkgs/stable/#sec-fhs-environments.
let
  base = pkgs.appimageTools.defaultFhsEnvArgs;

  addPkgs = with pkgs; [
    pkg-config
    ncurses
    # Feel free to add more packages here if needed.
  ];
in
pkgs.buildFHSUserEnv (
  base
  // {
    name = "fhs";

    targetPkgs =
      pkgs:
      (
        # pkgs.buildFHSUserEnv provides only a minimal FHS environment,
        # lacking many basic packages needed by most software.
        # Therefore, we need to add them manually.
        #
        # pkgs.appimageTools provides basic packages required by most software.
        (base.targetPkgs pkgs) ++ addPkgs
      );

    profile = "export FHS=1";
    runScript = "zsh";
    extraOutputsToInstall = [ "dev" ];
  }
)
