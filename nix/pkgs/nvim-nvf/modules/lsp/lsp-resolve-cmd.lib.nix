{ lib, pkgs, ... }:
let
  resolveCmd =
    target:
    let
      resolve = (
        pkgs.writeShellScriptBin "resolve"
          # Bash
          ''
            exe=$("${pkgs.which}/bin/which" "${target}")
            exe=$("${pkgs.coreutils}/bin/realpath" "$exe")
            if [ -x "$exe" ] ; then
                exec "$exe" "$@"
            fi

            echo "Could not resolve '${target}' for LSP start." &>2
            exit 1
          ''
      );
    in
    "${pkgs.lib.getExe resolve}";
in
{
  inherit resolveCmd;
}
