{ inputs, ... }:
{
  perSystem =
    { pkgsUnstable, ... }:
    let
      treefmtEval = inputs.treefmt-nix.lib.evalModule pkgsUnstable ./treefmt.nix;
      treefmt = treefmtEval.config.build.wrapper;
    in
    {
      packages.treefmt = treefmt;
      formatter = treefmt;
    };
}
