{
  lib,
  python3,
  perl,
  writeShellApplication,
}:
let
  script = ./file-regex-replace.py;
in
writeShellApplication {
  name = "gabyx::file-regex-replace";

  runtimeInputs = [
    python3
    perl
  ];

  text =
    # bash
    ''
      ${lib.getExe python3} "${script}" "$@"
    '';
}
