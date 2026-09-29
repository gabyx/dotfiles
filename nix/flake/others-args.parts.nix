{ inputs, ... }:
{
  # Expose the wrappers library.
  _module.args.wrappersLib = inputs.wrappers.lib;

  perSystem = { ... }: {
    _module.args.wrappersLib = inputs.wrappers.lib;
  };
}
