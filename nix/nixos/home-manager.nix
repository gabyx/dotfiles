{
  config,
  inputs,
  outputs,
  system,
  pkgs,
  pkgsUnstable,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  config = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.${config.settings.user.name} = outputs.modules.homeManager.gabyx;
    home-manager.extraSpecialArgs = {
      inherit
        inputs
        outputs
        system
        pkgs
        pkgsUnstable
        ;
    };
    home-manager.backupFileExtension = "backup";
  };
}
