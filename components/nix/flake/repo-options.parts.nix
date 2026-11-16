{
  lib,
  flake-parts-lib,
  ...
}:
let
  inherit (flake-parts-lib) mkPerSystemOption;

  mkLibOption =
    desc:
    lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.raw;
      description = desc;
      default = { };
    };

  libDefs = {
    shell = mkLibOption "Nix dev. shell utilities.";
  };
in
{
  options = {
    # Define `lib` as flake output which is our
    # own standalone reusable library.
    flake.lib = libDefs;

    # Define the `repo` namespace with repository scoped functionality.
    repo.lib = libDefs;

    # Defining a `perSystem` scoped module option `repo`.
    perSystem = mkPerSystemOption (
      {
        lib,
        ...
      }:
      {
        options.repo = {
          devenvModules = lib.mkOption {
            type = lib.types.attrsOf lib.types.anything;
            description = "Attribute set of list of devenv modules.";
            default = { };
          };

          shells = lib.mkOption {
            type = lib.types.attrsOf lib.types.package;
            description = "All development Nix shells.";
            default = { };
          };
        };
      }
    );
  };
}
