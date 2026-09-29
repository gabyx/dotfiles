{
  pkgs,
  mvs,
  wrappersLib,
  ...
}:
let
  rofi-rbw-wrapped = wrappersLib.wrapPackage {
    inherit pkgs;
    package = mvs.versions.rofi-rbw-wayland."1.7.0";
    flags = {
      "--target" = "password";
      "--clipboarder" = "wl-copy";
      "--clear-after" = "20";
      "--action" = "copy";
    };
  };

  rofi-rbw = (
    pkgs.buildEnv {
      name = "rofi-rbw-env";
      pname = "rofi-rbw-env";
      version = "1.7.0";
      paths = [
        (mvs.versions.rbw."1.15.0") # Bitwarden alternative CLI stateless.
        pkgs.pinentry-rofi
        rofi-rbw-wrapped
      ];
    }
  );

in
[
  pkgs.rofi # Menus for various things.

  pkgs.rofimoji # Emoji selector.
  pkgs.rofi-power-menu # Rofi powermenu.
  pkgs.rofi-bluetooth # Rofi bluetooth.
  pkgs.rofi-systemd # Rofi systemd.

  rofi-rbw # Rofi bitwarden.
]
