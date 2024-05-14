# My own settings to build the NixOS home configurations.
{lib, ...}:
with lib; {
  # Some option declarations which can be used to specify
  # in `config.settings.???`
  options = {
    settings = {
      user.name = mkOption {
        description = "The default user name.";
        default = "Gabriel Nützi";
        type = types.str;
      };

      user.email = mkOption {
        description = "The default email of the user.";
        default = "gnuetzi" + "@" + "gmail.com";
        type = types.str;
      };

      user.emailWork = mkOption {
        description = "The default work email of the user.";
        default = "nuetzig" + "@" + "ethz.ch";
        type = types.str;
      };

      user.emailWorkEnable = mkOption {
        description = "If we setup the work email also.";
        default = true;
        type = types.bool;
      };
    };
  };
}
