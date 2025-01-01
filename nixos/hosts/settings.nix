# My own settings to build the NixOS configurations.
{ lib, config, ... }:
let
  setts = config.settings;
in
with lib;
{
  # Some option declarations which can be used to specify
  # in `config.settings.???`
  options = {
    settings = {
      user = {
        name = mkOption {
          description = "The main user.";
          default = "nixos";
          type = types.str;
        };

        home = mkOption {
          description = "The home folder.";
          default = "/home/${setts.user.name}";
          type = types.oneOf [
            types.str
            types.path
          ];
        };

        profilePicture = mkOption {
          description = "The profile picture in PNG to use. (you can set it to a )";
          default = "/home/${setts.user.name}/.config/profile-icons/nixos.png";
          type = types.oneOf [
            types.str
            types.path
          ];
        };
      };
    };
  };
}
