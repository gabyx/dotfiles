with import <nixpkgs> { };
mkShell {
  packages = with pkgs; [
    pavucontrol
    libjack2
    jack2
    qjackctl
    jack_capture
  ];

  NIX_LD_LIBRARY_PATH = lib.makeLibraryPath [
    pkgs.stdenv.cc.cc
    pkgs.alsa-lib-with-plugins
    pkgs.qt5.qtbase
    pkgs.qt5.qtwayland

    pkgs.dbus
    pkgs.pipewire
    pkgs.jack2

    pkgs.pipewire.jack
    "/home/nixos/.local/share/chezmoi/tests/mod-desktop-0.0.12-linux-x86_64/mod-desktop/jack"
  ];

  QT_PLUGIN_PATH = "${qt5.qtbase}/${qt5.qtbase.qtPluginPrefix}:${qt5.qtwayland.bin}/${qt5.qtbase.qtPluginPrefix}";
  QML2_IMPORT_PATH = "${qt5.qtdeclarative}/${qt5.qtbase.qtQmlPrefix}:${qt5.qtwayland.bin}/${qt5.qtbase.qtQmlPrefix}";

  NIX_LD = lib.fileContents "${stdenv.cc}/nix-support/dynamic-linker";
}
