{
  lib,
  stdenv,
  fetchgit,
  freetype,
  pango,
  zlib,
  p7zip,
  unzip,
  wget,
  zip,
  curl,
  coreutils,
  which,
  python3,
  pkg-config,
  cmake,

  wrapQtAppsHook,
  qtbase,
  qttools,
  qtwayland,

  alsa-lib,
  alsa-lib-with-plugins,

  dbus,
  pipewire,
  jack1,

  # Add these missing dependencies
  glib,
  pcre,
  pcre2,
  xorg, # To access xorg.libpthreadstubs and xorg.xproto
  libuuid,
  libxcb-util,
  mesa,
}:
let
  version = "0.0.12";
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
