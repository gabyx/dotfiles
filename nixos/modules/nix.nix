{ config, pkgs, ... }:

{
  ### Nix Specific Settings ===================================================
  nix = {
    settings = {
      auto-optimise-store = true;
    };

    package = pkgs.nixFlakes;

    extraOptions = ''
    experimental-features = nix-command flakes
    # use-xgd-base-directories = true
    '';

    # Garbage collector
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "electron-12.2.3"
        "electron-19.1.9"
      ]; };
  };
  # ===========================================================================
}
