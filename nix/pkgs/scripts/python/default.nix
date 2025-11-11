{
  python313,
  perl,
  writeShellApplication,
}:
let
  script = ./file-regex-replace.py;
in
writeShellApplication {
  name = "gabyx::file-regex-replace";

  runtimeInputs = [
    python313
    perl
  ];

  text =
    # bash
    ''
      ${python313}/bin/python "${script}" "$@"
    '';
}
