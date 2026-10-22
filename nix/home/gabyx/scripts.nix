{
  self,
  system,
  ...
}:
{
  home.packages = [
    self.packages.${system}.gabyx-cli
  ];
}
