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
  mvs,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  config = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.${config.settings.user.name} = self.homeModules.gabyx;

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
