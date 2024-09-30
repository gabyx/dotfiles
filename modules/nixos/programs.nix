{
  config,
  pkgs,
  ...
}:
{
  ### Program Settings ========================================================
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs = {
    # This ensures downloaded binaries not managed with NixOS
    # can be run by forwarding the /lib64/ld-linux-x86-64.so.2 to the NixOS one.
    nix-ld.enable = true;

    # Shell
    zsh.enable = true;

    mtr.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = false;
    };

    git = {
      enable = true;
      package = pkgs.gitFull;
      config.credential.helper = "${pkgs.gitFull}/bin/git-credential-libsecret";
    };

    # Archive Manager
    file-roller.enable = true;

    # File Manager
    thunar = {
      enable = true;
      plugins = with pkgs; [
        xfce.thunar-archive-plugin # for archives.
        xfce.tumbler # for image thumbnails.
        xfce.thunar-volman
      ];
    };

    # Crendential Manager.
    seahorse.enable = true;

    # Email.
    evolution = {
      enable = true;
      plugins = with pkgs; [ evolution-ews ];
    };
  };
  # ===========================================================================
}
