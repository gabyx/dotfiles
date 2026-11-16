{
  ...
}:
{
  perSystem =
    {
      pkgsUnstable,
      ...
    }:
    {
      packages = {
        gabyx-cli = pkgsUnstable.callPackage ./. { };
      };
    };
}
