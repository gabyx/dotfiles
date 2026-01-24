{
  inputs,
  lib,
  ...
}:
{
  imports = [
    ./configuration-base.nix

    ./hardware-configuration.nix
    ./cpu.nix
    ./boot.nix
    ./hardware.nix

    inputs.self.modules.nixos.secrets
    inputs.self.modules.nixos.bluetooth

    ./settings.nix
    ../common/yubikey.nix
  ];

  specialisation = {
    # Dont use tempfs (ram) for the /tmp.
    # Sometimes useful when building large stuff which exhausts memory.
    notempfs = {
      inheritParentConfig = true;
      configuration = {
        boot.tmp.useTmpfs = lib.mkForce false;
      };
    };

    # The music specialization.
    music = {
      inheritParentConfig = true;
      configuration =
        { ... }:
        {
          imports = [
            inputs.self.modules.nixos.music
          ];
        };
    };
  };
}
