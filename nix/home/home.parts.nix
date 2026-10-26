{ ... }:
let
  modules = {
    # List your module files here:
    chezmoi = import ./chezmoi/chezmoi.nix;

    home-gabyx = import ./gabyx/home.nix;
    home-gabyx-work = import ./gabyx-work/home.nix;
    home-vm = import ./vm/home.nix;
  };

  # Expose all home manager modules on the flake.
  flake.homeModules = modules;
in
{
  inherit flake;
}
