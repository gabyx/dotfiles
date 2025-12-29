{
  inputs,
  ...
}:
{
  imports = [
    ../desktop/configuration.nix
    inputs.self.modules.nixos.music
  ];
}
