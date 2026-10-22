{
  inputs,
  ...
}:
{
  flake.lib.nixpkgs = {
    # Shorthand to access the std library in the `nix repl`.
    lib = inputs.nixpkgs.lib;

    importPkgs =
      {
        system,
      }:
      import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
  };
}
