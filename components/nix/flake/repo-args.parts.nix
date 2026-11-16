{ config, ... }:
{
  # Make the `repo` function parameter available in flake-parts modules.
  _module.args.repo = config.repo;

  # Make the `repo'` function parameter available in `perSystem`.
  perSystem =
    {
      config,
      ...
    }:
    {
      _module.args.repo' = config.repo;
    };
}
