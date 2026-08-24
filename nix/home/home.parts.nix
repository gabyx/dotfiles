{ ... }:
let
  modules = {
    # List your module files here:
    chezmoi = import ./chezmoi.nix;
    gabyx = import ./home.nix;
  };

  # Expose all home manager modules on the flake.
  flake.homeModules = modules;
in
{
  inherit flake;
}
