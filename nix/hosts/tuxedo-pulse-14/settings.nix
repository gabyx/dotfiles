{ ... }:
{
  networking.hostName = "nixos-tuxedo";

  settings = {
    backup = {
      enable = true;
    };

    chezmoi.workspace = "work";
  };
}
