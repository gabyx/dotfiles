{ pkgs, ... }:
{
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = false;
      gamescopeSession.enable = false;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };

    # gamescope = {
    #   enable = false;
    #   capSysNice = true;
    #   args = [
    #     "--rt"
    #     "--expose-wayland"
    #   ];
    # };
  };
}
