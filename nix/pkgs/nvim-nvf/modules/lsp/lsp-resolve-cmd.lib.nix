{ lib, pkgs, ... }:
let
  inherit (lib.generators) mkLuaInline toLua;

  getBaked =
    bakedDrvOrPath:
    if lib.isDerivation bakedDrvOrPath then "${lib.getExe bakedDrvOrPath}" else bakedDrvOrPath;

  lspStart =
    pkgs.writeShellScriptBin "lsp-start"
      # Bash
      ''
        echo "gabyx:: Starting LSP: " "$@" >&2

        if ! exec "$@"; then
          echo "gabyx:: Could not start LSP." >&2
          exit 1
        fi
      '';

  resolveCmd =
    exeName: bakedDrvOrPath:
    let
      bakedExe = getBaked bakedDrvOrPath;
      resolve = (
        pkgs.writeShellScriptBin "resolve"
          # Bash
          ''
            exe=$("${pkgs.which}/bin/which" "${exeName}")
            exe=$("${pkgs.coreutils}/bin/realpath" "$exe")

            if [ -x "$exe" ]; then
                exec "${lib.getExe lspStart}" "$exe" "$@"
            elif [ -x "${bakedExe}" ]; then
              echo "gabyx:: Could not resolve exec. '${exeName}' for LSP start." >&2
              echo "gabyx:: Using baked target '${bakedExe}'." >&2
              exec "${lib.getExe lspStart}" "${bakedExe}" "$@"
            else
              echo "gabyx:: Could not resolve exec. '${exeName}' or '${bakedExe}' for LSP start." >&2
            fi

            exit 1
          ''
      );
    in
    "${pkgs.lib.getExe resolve}";

  # exeName  : name to look up on $PATH (e.g. "gopls")
  # bakedDrv : derivation to fall back to if not found on PATH
  # extraArgs: extra CLI args to append after the resolved executable (default [])
  resolveCmdLua =
    exeName: bakedDrvOrPath: extraArgs:
    let
      bakedExe = getBaked bakedDrvOrPath;
      argsLua = toLua { } extraArgs;
    in
    mkLuaInline
      # Lua
      ''
        function(dispatchers, config)
          return require("gabyx.lsp").start(
            dispatchers, "${lib.getExe lspStart}",
            "${exeName}", "${bakedExe}", ${argsLua})
        end
      '';
in
{
  inherit resolveCmd resolveCmdLua;
}
