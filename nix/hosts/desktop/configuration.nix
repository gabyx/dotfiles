{
  lib,
  inputs,
  ...
}:
{
  imports = [
    ./configuration-base.nix

    ./filesystem.nix

    inputs.self.nixosModules.secrets
    inputs.self.nixosModules.bluetooth
    inputs.self.nixosModules.apfs

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
            inputs.self.nixosModules.music
          ];
        };
    };

    # The Lix specialization.
    lix = lib.mkIf false {
      inheritParentConfig = true;
      configuration =
        { ... }:
        {
          imports = [
            inputs.self.nixosModules.lix
          ];
        };
    };
  };
}
