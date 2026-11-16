{
  lib,
  stdenvNoCC,
  stdenv,
  fetchurl,
  unzip,
  autoPatchelfHook,
  libx11,
  libxcb,
  libxcb-util,
  libxcb-cursor,
  libxcb-keysyms,
  libxkbcommon,
  freetype,
  glib,
  cairo,
  pango,
  fontconfig,
  libpng,
  zlib,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "mt-powerdrumkit";
  version = "2.1.5.1";

  # Prebuilt VST3 bundle from the vendor (no sources are published).
  src = fetchurl {
    url = "https://cdn1.resources.manda-audio.com/DOWNLOADS/products/mtpdk2_free/2.1.5/MTPDK-${finalAttrs.version}-VST3-64bit-Linux-FULL.zip";
    hash = "sha256-lb8RuIdLgDC2y9KSF6hlWXWKlt4jI8tndWk/WVanpGo=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    unzip
    autoPatchelfHook
  ];

  # The libraries listed in the upstream "INSTALL on Arch.txt"; the binary is
  # patched to find them in the store instead of the system library path.
  buildInputs = [
    stdenv.cc.cc.lib
    libx11
    libxcb
    libxcb-util
    libxcb-cursor
    libxcb-keysyms
    libxkbcommon
    freetype
    glib
    cairo
    pango
    fontconfig
    libpng
    zlib
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    bundle=$(find . -type d -name 'MT-PowerDrumKit.vst3' -print -quit)
    if [ -z "$bundle" ]; then
      echo "MT-PowerDrumKit.vst3 not found in the archive" >&2
      exit 1
    fi

    mkdir -p $out/lib/vst3
    cp -r "$bundle" $out/lib/vst3/

    runHook postInstall
  '';

  meta = {
    description = "Free acoustic drum sampler plugin (VST3) with a groove library";
    homepage = "https://www.powerdrumkit.com/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
  };
})
