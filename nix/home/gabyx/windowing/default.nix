# Links the window manager configs (`./sway`, `./hypr`, `./niri`) as whole folders to
# `~/.config/<name>`. Files which are included conditionally are included over the
# generated file `conf` in the folder.
{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption types;
  cfg = config.settings.windowing;
  confDir = ./../../config;

  isSwayFX = lib.getName osConfig.programs.sway.package == "swayfx";

  # Copies the config folder `src` and adds the generated file `conf` (the conditional includes).
  # All files are real files in one directory (no `symlinkJoin`): Window manager resolve relative
  # includes in included files against the directory of their real path.
  mkConfigDir =
    name: src: conf:
    pkgs.runCommand "${name}-config" { } ''
      cp -r ${src} $out
      chmod u+w $out
      cp ${pkgs.writeText "conf" conf} $out/conf
    '';
in
{
  imports = [
    ./waybar.nix
  ];

  options.settings.windowing = {
    workspace = mkOption {
      description = "The workspace which selects the display configuration (outputs/monitors).";
      default = "private";
      type = types.enum [
        "private"
        "work"
      ];
    };
  };

  config = {
    xdg.configFile = {
      "sway" = {
        force = true;
        source = mkConfigDir "sway" (confDir + "/sway") (
          lib.concatLines (
            [
              "include config-${cfg.workspace}"
            ]
            ++ lib.optional isSwayFX "include config-swayfx"
          )
        );
      };
      "swaylock" = {
        force = true;
        source = confDir + "/swaylock";
      };
      "swaync" = {
        force = true;
        source = confDir + "/swaync";
      };

      "hypr" = {
        force = true;
        source = mkConfigDir "hypr" (confDir + "/hypr") (
          lib.concatLines [
            "source = ~/.config/hypr/monitors-${cfg.workspace}.conf"
          ]
        );
      };

      "niri" = {
        force = true;
        source = (confDir + "/niri");
      };

      # General Stuff
      "mako" = {
        force = true;
        source = confDir + "/mako";
      };
      "rofi" = {
        force = true;
        source = confDir + "/rofi";
      };
      "way-displays" = {
        force = true;
        source = ./../../config/way-displays;
      };
      "wallpapers" = {
        force = true;
        source = ./../../config/wallpapers;
      };
    };
  };
}
