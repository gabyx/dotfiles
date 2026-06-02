{
  config,
  osConfig,
  lib,
  outputs,
  inputs',
  pkgs,
  pkgsUnstable,
  system,
  ...
}:
let
  inherit (lib) mkOption types;
  cfg = config.settings;
in
{
  options = {
    settings = {
      programs.archiver = mkOption {
        description = "The default archiver.";
        default = pkgsUnstable.file-roller;
        type = types.package;
      };

      programs.browser = mkOption {
        description = "The default browser.";
        default = inputs'.zen-browser.packages.zen-browser;
        type = types.package;
      };

      programs.signal = mkOption {
        description = "The signal messenger.";
        default = pkgsUnstable.signal-desktop;
        type = types.package;
      };

      programs.videoPlayer = mkOption {
        description = "The video player.";
        default = pkgsUnstable.vlc;
        type = types.package;
      };

      programs.mail = mkOption {
        description = "The mail client.";
        default = osConfig.programs.evolution.package;
        type = types.package;
        internal = true;
      };

      programs.fileBrowser = mkOption {
        description = "The file browser.";
        default = lib.findFirst (
          x: lib.hasInfix "thunar-with-plugins" (x.name or x.pname)
        ) null osConfig.environment.systemPackages;
        type = types.package;
        internal = true;
      };

      programs.terminals = mkOption {
        description = "All terminals. First is the main one.";
        default = [
          inputs'.wezterm.packages.default
          pkgsUnstable.kitty
          pkgsUnstable.ghostty
        ];
        type = types.listOf types.package;
      };

      programs.editors = mkOption {
        description = "All editors. First is the main one.";
        default = [
          outputs.packages.${system}.nvim # Pinned version.
          outputs.packages.${system}.nvim-new
          outputs.packages.${system}.nvim-nightly
          pkgsUnstable.vscode
        ];
        type = types.listOf types.package;
      };

      programs.images = mkOption {
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
  };

  config = {
    home.packages = [
      cfg.programs.archiver
      cfg.programs.browser
      cfg.programs.fileBrowser
      cfg.programs.signal
      cfg.programs.videoPlayer
    ]
    ++ cfg.programs.images
    ++ cfg.programs.terminals
    ++ cfg.programs.editors;
  };
}
