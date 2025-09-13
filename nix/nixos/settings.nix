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
  # in `config.settings.xxx`
  options = {
    settings = {

      backup = {
        enable = mkOption {
          type = types.bool;
          default = false;
        };

        name = mkOption {
          default = config.networking.hostName;
          type = types.str;
          apply =
            v:
            assert lib.assertMsg (builtins.match "^[a-z.-]+$" v) "Backup name must be '[a-z.-]+'.";
            v;
          description = "The backup name.";
        };
      };

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

        openssh.authKeyFiles = mkOption {
          description = "The openssh public key files.";
          default = [ ../../config/private_dot_ssh/gabyx_ed25519.pub ];
          type = types.oneOf [
            types.str
            types.path
          ];
        };

        agenix.defaultRecipients = mkOption {
          description = "The agenix default recipients for which we by default encrypt secrets.";
          type = types.listOf types.str;
          default = [
            # Chezmoi
            "age1messaj8qqseag2nuvr5d453qqnkszt3rmwldvpjw8fapd0xfkajs7x6mld"
            # Host Key
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEpmbTaLprMrAofmt2vmF3qlB0Kah2qLRQKv4zJ+pmS7 nixos@linux-nixos"
          ];
        };
      };
    };
  };
}
