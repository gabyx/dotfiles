{
  config,
  inputs,
  outputs,
  pkgsUnstable,
  ...
}: {
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.${config.settings.user.name} = import (inputs.self + /home/home.nix);
  home-manager.extraSpecialArgs = {inherit inputs outputs pkgsUnstable;};
}
