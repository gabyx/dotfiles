{ ... }:
{
  networking.hostName = "nixos-tuxedo";

  settings = {
    user.chezmoi.workspace = "work";

    backup = {
      enable = true;
      backups.system.enable = true;
    };
  };

  yubikey = {
    enable = true;
    identifiers = {
      # Testing this fido2 key goes with:
      # sudo ssh-keygen -Y sign -f ~/.ssh/gabyx_ed25519_fido2_yubikey -n test test.txt
      "gabyx_ed25519_fido2_yubikey" = 34053549;
    };
  };
}
