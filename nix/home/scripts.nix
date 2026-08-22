{
  self,
  system,
  ...
}:
{
  home.packages = [
    self.packages.${system}.gabyx-shell-run
    self.packages.${system}.gabyx-shell-source
    self.packages.${system}.gabyx-python
  ];
}
