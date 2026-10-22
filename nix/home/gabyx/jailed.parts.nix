{
  inputs,
  lib,
  ...
}:
{
  perSystem =
    {
      system,
      pkgs,
      pkgsUnstable,
      inputs',
      ...
    }:
    let
      shell = import ./jailed/shell.nix {
        inherit lib pkgs pkgsUnstable;
        inherit (inputs) jail-nix;
      };

      apps = import ./jailed/apps.nix {
        inherit lib pkgs pkgsUnstable;
        inherit (inputs) jail-nix;
      };

      agents = import ./jailed/agents.nix {
        inherit system;
        inherit lib pkgs pkgsUnstable;
        inherit (inputs) agent-sandbox;
        inherit (inputs'.claude-code.packages) claude-code;
      };
    in
    {
      packages = shell // apps // agents;
    };
}
