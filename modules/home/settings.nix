# My own settings to build the NixOS home configurations.
{lib, ...}:
with lib; {
  # Some option declarations which can be used to specify
  # in `config.settings.???`
  options = {
    settings = {
      setupWorkEmail = mkOption {
        description = "If we setup the work email also.";
        default = true;
        type = types.bool;
      };
    };
  };
}
