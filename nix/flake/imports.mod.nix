{ inputs, ... }:
{
  imports = [
    inputs.home-manager.flakeModules.home-manager
    inputs.flake-parts.flakeModules.modules
  ];
}
