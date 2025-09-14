{
  writeShellApplication,
  coreutils,
  findutils,
  git,
  bash,
  zfs,
  gnugrep,
  gnused,
  fd,
}:
let
  lib = ./.;
in
{
  # Derivation to dispatch over a bash shell which has all
  # dependencies.
  gabyx-shell-run = writeShellApplication {
    name = "gabyx::shell-run";

    runtimeInputs = [
      coreutils
      findutils
      git
      bash
      zfs
      gnugrep
      gnused
      fd
    ];

    text =
      # bash
      ''
        export GABYX_LIB_DIR="${lib}"
        # shellcheck disable=SC1091
        source "${lib}/source.sh"

        "$@"
      '';
  };

  # Here for sourcing `eval $(gabyx::shell-source)` to get all
  # public functions which some of them
  # dispatch over `gabyx::shell-run`.
  gabyx-shell-source = writeShellApplication {
    name = "gabyx::shell-source";
    text =
      # bash
      ''
        echo 'export GABYX_LIB_DIR="${lib}"'
        echo 'source "${lib}/source.sh"'
      '';
  };
}
