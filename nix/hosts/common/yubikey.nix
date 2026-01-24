{ ... }:
{
  yubikey = {
    enable = true;
    identifiers = {
      # Testing this fido2 key goes with:
      # ssh-keygen -Y sign -f ~/.ssh/gabyx_ed25519_fido2_yubikey -n test <<< "hello"
      "gabyx_ed25519_fido2_yubikey" = 34053549;
    };

    # autoScreenLock = true;
    # autoScreenUnlock = true;
  };
}
