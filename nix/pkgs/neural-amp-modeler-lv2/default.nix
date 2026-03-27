{
  stdenv,
  fetchgit,
  cmake,
  ninja,
}:
let
  version = "0.1.9";
in

stdenv.mkDerivation {
  pname = "neural-amp-modeler-lv2";
  inherit version;

  src = fetchgit {
    url = "https://github.com/mikeoliphant/neural-amp-modeler-lv2";
    rev = "v${version}";
    fetchSubmodules = true;
    hash = "sha256-hgHuN+cwFxaPuQLHbamdPtvsDE0ErTViJaCb5gYmLJE=";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];
}
