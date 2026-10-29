{ config, lib, ... }:
let
  inherit (lib) mkOption mkEnableOption types;
  cfg = config.settings.user;
in
{
  options = {
    settings = {
      secrets = {
        enable = mkOption {
          description = "Enable secrets over agenix.";
          default = true;
          type = types.bool;
        };
      };

      networking = {
        wlan-profiles.enable = mkEnableOption "WLAN networking profiles.";

        vpn.tailscale = {
          client.enable = mkEnableOption "tailscale VPN client";
        };
      };

      user = {
        profile = mkOption {
          description = "The home profile to load from homeModules.";
          default = "home-gabyx";
          type = types.str;
        };

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
          default = ../home/config/profile-icons/nixos-logo.png;
          type = types.path;
        };

        openssh.authKeyFiles = mkOption {
          description = "The openssh public key files.";
          default = [ ../../config/private_dot_ssh/readonly_gabyx_ed25519.pub ];
          type = types.listOf (
            types.oneOf [
              types.str
              types.path
            ]
          );
        };

        chezmoi.workspace = mkOption {
          description = "The chezmoi workspace to choose.";
          default = "private";
          type = types.str;
        };
      };

      music = {
        enable = mkEnableOption "all music related things";
      };
    };
  };
}
