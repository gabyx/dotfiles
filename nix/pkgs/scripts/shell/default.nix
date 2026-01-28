{
  writeShellApplication,
  sudo,
  coreutils,
  findutils,
  git,
  bash,
  zfs,
  gnugrep,
  gnused,
  fd,
  expect,
}:
let
  lib = ./.;
  # Derivation to dispatch over a bash shell which has all
  # dependencies.
  gabyx-shell-run = writeShellApplication {
    name = "gabyx::shell-run";

    runtimeInputs = [
      sudo
      coreutils
      findutils
      git
      bash
      zfs
      gnugrep
      gnused

      fd

      expect
    ];

    text =
      # bash
      ''
        # For sudo which is in this folder:
        export PATH="/run/wrappers/bin:$PATH"

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
        # shellcheck disable=SC2016
        echo 'export PATH="${gabyx-shell-run}/bin:$PATH"'
        echo 'export GABYX_LIB_DIR="${lib}"'
        echo 'source "${lib}/source.sh"'
      '';
  };
in
{
  inherit gabyx-shell-run gabyx-shell-source;
}
