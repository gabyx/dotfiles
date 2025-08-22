# My own settings to build the NixOS configurations.
{
  lib,
  config,
  ...
}:
let
  setts = config.settings;
in
with lib;
{
  # Some option declarations which can be used to specify
  # in `config.settings.???`
  options = {
    settings = {
      windowing = {
        manager = mkOption {
          description = "Window manager to use.";
          default = "sway";
          type = types.enum [
            "sway"
            "hyprland"
          ];
        };
      };

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

        icon = mkOption {
          description = "The profile picture in PNG to use. (you can set it to a )";
          default = ../../config/dot_config/profile-icons/nixos.png;
          type = types.path;
        };

        opensshAuthKeyFiles = mkOption {
          description = "The openssh public key files.";
          default = [ ../../config/private_dot_ssh/gabyx_ed25519.pub ];
          type = types.oneOf [
            types.str
            types.path
          ];
        };
      };
    };
  };
}
