# The home profile `home-gabyx` for work machines.
{ self, ... }:
{
  imports = [ self.homeModules.home-gabyx ];

  settings.windowing.workspace = "work";
}
