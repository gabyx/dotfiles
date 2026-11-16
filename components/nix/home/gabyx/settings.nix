{
  config,
  osConfig,
  lib,
  self,
  inputs',
  pkgsUnstable,
  system,
  ...
}:
let
  inherit (lib) mkOption mkEnableOption types;
  cfg = config.settings;
in
{
  options = {
    settings = {
      programs = {
        archiver = mkOption {
          description = "The default archiver.";
          default = pkgsUnstable.file-roller;
          type = types.package;
        };

        browsers = mkOption {
          description = "The default browser.";
          default = [
            inputs'.zen-browser.packages.zen-browser
            pkgsUnstable.firefox
            pkgsUnstable.google-chrome
          ];
          type = types.listOf types.package;
        };

        signal = mkOption {
          description = "The signal messenger.";
          default = pkgsUnstable.signal-desktop;
          type = types.package;
        };

        videoPlayer = mkOption {
          description = "The video player.";
          default = pkgsUnstable.vlc;
          type = types.package;
        };

        mail = mkOption {
          description = "The mail client.";
          default = osConfig.programs.evolution.package;
          type = types.package;
          internal = true;
        };

        fileBrowser = mkOption {
          description = "The file browser.";
          default = lib.findFirst (
            x: lib.hasInfix "thunar-with-plugins" (x.name or x.pname)
          ) null osConfig.environment.systemPackages;
          type = types.package;
          internal = true;
        };

        terminals = mkOption {
          description = "All terminals. First is the main one.";
          default = [
            inputs'.wezterm.packages.default
            pkgsUnstable.kitty
            pkgsUnstable.ghostty
          ];
          type = types.listOf types.package;
        };

        editors = mkOption {
          description = "All editors. First is the main one.";
          default = [
            # NVF builds.
            self.packages.${system}.nvim-gabyx
            self.packages.${system}.nvim-gabyx-nightly

            pkgsUnstable.vscode
          ];
          type = types.listOf types.package;
        };

        images = mkOption {
          description = "All image manipulation programs.";
          default = [
            pkgsUnstable.swappy
            pkgsUnstable.nomacs
            pkgsUnstable.krita
            pkgsUnstable.inkscape
          ];
          type = types.listOf types.package;
        };
      };

      music = {
        enable = mkEnableOption "all the musics related stuff for the musics specialisation.";
      };
    };
  };

  config = {
    home.packages = [
      cfg.programs.archiver
      cfg.programs.fileBrowser
      cfg.programs.signal
      cfg.programs.videoPlayer
    ]
    ++ cfg.programs.browsers
    ++ cfg.programs.images
    ++ cfg.programs.terminals
    ++ cfg.programs.editors;
  };
}
