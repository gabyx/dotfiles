{
  nixpak,
  lib,
  pkgs,
  nvim,
  ...
}:
let
  mkNixPak = nixpak.lib.nixpak {
    inherit lib pkgs;
  };

  wrapped = mkNixPak {
    config =
      { sloth, ... }:
      {
        app.package = nvim;

        dbus.enable = true;

        bubblewrap = {
          network = true;
          bind.rw = [
            (sloth.env "XDG_RUNTIME_DIR")
            (sloth.concat' (sloth.env "XDG_CACHE_HOME") (sloth.concat' "/" (sloth.env "NVIM_APPNAME")))
            (sloth.concat' (sloth.env "XDG_CONFIG_HOME") (sloth.concat' "/" (sloth.env "NVIM_APPNAME")))
            (sloth.concat' (sloth.env "XDG_DATA_HOME") (sloth.concat' "/" (sloth.env "NVIM_APPNAME")))
            (sloth.env "PWD")
          ];
        };
      };
  };
in
wrapped.config.script
