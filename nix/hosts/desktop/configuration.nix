{
  inputs,
  lib,
  ...
}:
{
  imports = [
    ./configuration-base.nix

    ./hardware-configuration.nix

    inputs.self.modules.nixos.secrets
    inputs.self.modules.nixos.bluetooth

    ./settings.nix
    ../common/yubikey.nix
    ../common/notempfs.nix
  ];

  specialisation = {
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
