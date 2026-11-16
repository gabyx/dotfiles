{
  self,
  self',
  inputs,
  inputs',
  config,
  pkgs,
  pkgsUnstable,
  system,
  mvs,
  packages,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  config = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;

    home-manager.users.${config.settings.user.name} = self.homeModules.${config.settings.user.profile};

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
        mvs
        ;
    };
    home-manager.backupFileExtension = "backup";
  };
}
