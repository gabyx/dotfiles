{
  inputs,
  lib,
  config,
  ...
}:
let
  cfg = config.system.nixos;
in
{
  system.nixos.label =
    (inputs.self.shortRev or "dirty")
    + ":"
    + (lib.concatStringsSep "-" ((lib.sort (x: y: x < y) cfg.tags) ++ [ cfg.version ]));
}
