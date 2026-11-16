{
  ...
}:
{
  repo.lib.shell = {
    # Make a devenv shell from some modules.
    mkShell =
      {
        inputs,
        modules ? [ ],
        pkgs ? null,
        system ? null,
      }:
      inputs.quitsh.lib.mkShell {
        inherit inputs pkgs system;
        modules = modules ++ [
          {
            # Disable pure-evaluation mode which needs a devenv-root input
            # override in flake.nix.
            env = {
              QUITSH_NIX_NO_DEVENV_ROOT_INPUT_OVERRIDE = "true";
              QUITSH_NIX_NO_PURE_EVAL = "true";
            };
          }
        ];
      };
  };
}
