# My own settings to build the NixOS configurations.
{ lib, ... }:
with lib;
{
  # Some option declarations which can be used to specify
  # in `config.settings.???`
  options = {
    settings = {
      user = rec {
        name = mkOption {
          description = "The main user.";
          default = "nixos";
          type = types.str;
        };

        home = mkOption {
          description = "The home folder.";
          default = "/home/${name}";
          type = types.str;
        };
      };
    };
  };
}
