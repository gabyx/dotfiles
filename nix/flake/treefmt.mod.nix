{ inputs, ... }:
{
  perSystem =
    { inputs', pkgsUnstable, ... }:
    let
      pkgs = pkgsUnstable // {
        nixfmt = inputs'.nixfmt-rs.packages.default;
      };

      treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
      treefmt = treefmtEval.config.build.wrapper;
    in
    {
      packages.treefmt = treefmt;
      formatter = treefmt;
    };
}
