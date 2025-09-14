{ pkgsUnstable }:
let
  shell = pkgsUnstable.callPackage ./shell { };
in
{
  inherit (shell) gabyx-shell-run;
  inherit (shell) gabyx-shell-source;

  gabyx-python = pkgsUnstable.callPackage ./python { };
}
