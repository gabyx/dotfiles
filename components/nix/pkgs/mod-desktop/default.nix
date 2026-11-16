{
  lib,
  alsa-lib,
  alsa-lib-with-plugins,
  cmake,
  coreutils,
  curl,
  dbus,
  fetchgit,
  freetype,
  # Add these missing dependencies
  glib,
  jack1,
  libuuid,
  libxcb-util,
  mesa,
  p7zip,
  pango,
  pcre,
  pcre2,
  pipewire,
  pkg-config,
  python3,
  qtbase,
  qttools,
  qtwayland,
  stdenv,
  unzip,
  wget,
  which,
  wrapQtAppsHook,
  xorg, # To access xorg.libpthreadstubs and xorg.xproto
  zip,
  zlib,
}:
let
  version = "3200693d73c1c75f484c15679bdc9fd6f3e507e7";
in

stdenv.mkDerivation {
  pname = "mod-desktop";
  inherit version;

  dontUseCmakeConfigure = true;

  src = fetchgit {
    url = "https://github.com/mod-audio/mod-desktop";
    rev = "${version}";
    fetchSubmodules = true;
    hash = "sha256-yAz200xRUHW+LzAdzIJ7mdWvIGQU+ZPozjo9gXkPU0Q=";
  };

  postPatch = ''
    export HOME="$PWD/temphome";
    patchShebangs .
  '';

  preBuild = ''
    export HOME="$PWD/temphome";
    wrapQtAppsHook
  '';

  QT_PLUGIN_PATH = "${qtbase}/${qtbase.qtPluginPrefix}";

  buildInputs = [
    alsa-lib-with-plugins
    qtbase
    qtwayland
    dbus
    pipewire
    jack1
  ];

  nativeBuildInputs = [
    wrapQtAppsHook
    qttools
    cmake
    curl
    glib
    coreutils
    freetype
    pango
    zlib
    p7zip
    unzip
    wget
    zip
    which
    python3
    pkg-config
    alsa-lib
    alsa-lib-with-plugins
    qtbase
    qtwayland
    jack1
    glib
    pcre
    pcre2
    libx11
    libxcb-util
    libxrandr
    libxrender
    xorgproto
    libuuid
    libxcb
    mesa
  ];
}
