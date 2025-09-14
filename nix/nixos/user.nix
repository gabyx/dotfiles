{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption types;
  cfg = config.settings.user;
in
{
  options = {
    # My settings.
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

        chezmoi.workspace = mkOption {
          description = "The chezmoi workspace to choose.";
          default = "private";
          type = types.str;
        };
      };
    };
  };

  imports = [ ./user-icon.nix ];

  config = {
    ### User Settings ==========================================================
    users = {
      users.${cfg.name} = {
        shell = pkgs.zsh;

        useDefaultShell = false;

        initialPassword = "nixos";
        isNormalUser = true;

        extraGroups = [
          "wheel"
          "disk"
          "audio"
          "video"
          "input"
          "messagebus"
          "systemd-journal"
          "networkmanager"
          "network"
          "davfs2"
          "dialout" # For bazecor and the Dygma keyboard.
        ];

        # Extent the user `uid/gid` ranges to make podman work better.
        # This is for using https://gitlab.com/qontainers/pipglr
        subUidRanges = [
          {
            startUid = 100000;
            count = 65539;
          }
        ];
        subGidRanges = [
          {
            startGid = 100000;
            count = 65539;
          }
        ];

        # Authorized keys to access the machine if openssh is enabled.
        openssh.authorizedKeys.keyFiles = cfg.openssh.authKeyFiles;
      };
    };
    # ===========================================================================
  };
}
