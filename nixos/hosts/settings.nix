# My own settings to build the NixOS configurations.
{
  inputs,
  outputs,
  ...
}: {
  user = rec {
    name = "nixos";
    home = "/home/${name}";
  };
}
