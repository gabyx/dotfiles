{
  config,
  inputs,
  inputs',
  self,
  self',
  system,
  packages,
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
    home-manager.users.${config.settings.user.name} = self.modules.homeManager.gabyx;
    home-manager.extraSpecialArgs = {
      inherit
        inputs
        inputs'
        self
        self'
        system
        packages
        pkgs
        pkgsUnstable
        ;
    };
    home-manager.backupFileExtension = "backup";
  };
}
