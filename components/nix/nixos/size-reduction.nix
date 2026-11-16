{ ... }: {
  # Cannot add this cause to much depends on perl.
  # imports = [ "${modulesPath}/profiles/perlless.nix" ];
  services.speechd.enable = false;
  programs.nano.enable = false;
}
