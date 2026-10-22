{
  inputs,
  pkgs,
  pkgsUnstable,
  ...
}:
{
  imports = [
    inputs.direnv-instant.homeModules.direnv-instant
  ];

  programs = {
    direnv-instant.enable = true;
    direnv = {
      enable = true;
      package = pkgs.direnv;
      nix-direnv = {
        enable = true;
        package = pkgs.nix-direnv;
      };
    };

    nushell = {
      enable = true;
      package = pkgsUnstable.nushell;
      plugins = [
        pkgsUnstable.nushellPlugins.formats
      ];
    };
  };
}
