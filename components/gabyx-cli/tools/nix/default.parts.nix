{
  ...
}:
{
  perSystem =
    {
      pkgsUnstable,
      repo',
      ...
    }:
    {
      packages = {
        gabyx-cli = pkgsUnstable.callPackage ./. { };
      };

      repo.devenvModules = {
        gabyx-cli =
          let
            m = repo'.devenvModules;
          in
          m.common ++ m.build-go ++ m.lint-go ++ m.dev-go;
      };
    };
}
