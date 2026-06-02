{ config, lib, ... }:
let
  inherit (lib) mkOption types;
  cfg = config.settings.user;
in
{
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
          default = "/home/${cfg.name}";
          type = types.oneOf [
            types.str
            types.path
          ];
        };

        icon = mkOption {
          description = "The profile picture in PNG to use. (you can set it to a )";
          default = ../../config/dot_config/profile-icons/nixos-logo.png;
          type = types.path;
        };

        openssh.authKeyFiles = mkOption {
          description = "The openssh public key files.";
          default = [ ../../config/private_dot_ssh/gabyx_ed25519.pub ];
          type = types.oneOf [
            types.str
            types.path
          ];
        };

        chezmoi.workspace = mkOption {
          description = "The chezmoi workspace to choose.";
          default = "private";
          type = types.str;
        };
      };
    };
  };
}
