{
  inputs,
  ...
}:
{
  imports = [
    inputs.self.nixosModules.home-manager
    inputs.self.nixosModules.secrets
    inputs.self.nixosModules.settings
    inputs.self.nixosModules.size-reduction
    inputs.self.nixosModules.system
    inputs.self.nixosModules.time
    inputs.self.nixosModules.user

    ../vm-desktop/boot.nix
    ./qemu.nix
    ./disko.nix

    ./gradient.nix
    ./settings.nix
  ];

  # The shell of the main user (see `user` module).
  programs.zsh.enable = true;
  services.openssh.enable = true;

  system.stateVersion = "26.11";
  # ===========================================================================
}
