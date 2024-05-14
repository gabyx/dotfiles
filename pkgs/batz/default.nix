{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  bash,
  coreutils,
  findutils,
  gum,
  tz,
}: let
  wrapperPath = with lib; makeBinPath [coreutils findutils bash gum tz];
in
  stdenv.mkDerivation rec {
    pname = "batz";
    version = "2.5.1";

    src = fetchFromGitHub {
      owner = "chmouel";
      repo = "batzconverter";
      rev = "${version}";
      sha256 = "sha256-GVUpbZekPLbPuUR5C9Et2Ogm2CGRSS3uDHw+k1AbrcE=";
    };

    nativeBuildInputs = [makeWrapper];
    # buildInputs = [bash gum];

    doCheck = false;

    buildCommand = ''
      install -Dm755 "${src}/batz.sh" "$out/bin/${pname}"
      install -Dm755 "${src}/share/rofibatz.sh" "$out/bin/rofi-${pname}"

      substituteInPlace "$out/bin/${pname}" --replace-fail '/usr/share/zoneinfo' '/etc/zoneinfo'

      # # Stupid bug.
      # substituteInPlace "$out/bin/rofi-${pname}" --replace-fail 'tz|' 'tz -q|'

      wrapProgram "$out/bin/${pname}" \
        --prefix PATH : "${wrapperPath}"

      # wrapProgram "$out/bin/rofi-${pname}" \
      #   --prefix PATH : "$out/bin:${wrapperPath}"
    '';

    meta = with lib; {
      description = "Batman Timezone Converter";
      mainProgram = pname;
      homepage = "https://github.com/chmouel/batzconverter";
      license = licenses.mit;
      maintainers = with maintainers; [gabyx];
    };
  }
