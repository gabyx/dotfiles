{ ... }:
{
  yubikey = {
    enable = true;

    identifiers = {
      # Testing this fido2 key goes with:
      # ssh-keygen -Y sign -f ~/.ssh/gabyx_ed25519_fido2_yubikey -n test <<< "hello"
      "gabyx_ed25519_fido2_yubikey" = 34053549;

      # The security key (backup with less features)
      # Can only detect one security key.
      # Security Key 1: `ykman credential --list` -> credential_id: dac2c26edc4ab927da1e4efc3006902f0a51679a434efb37f87d85b9a138cf89a729c8cd07e08f2de0ed3ac2a733001b
      "gabyx_s1_ed25519_fido2_yubikey" = "[FIDO]";

      # Security Key 2: `ykman credential --list` -> credential_id: dac2c26edc4ab927da1e4efc3006902f0a51679a434efb37f87d85b9a138cf89a729c8cd07e08f2de0ed3ac2a733001b
      # "gabyx_s2_ed25519_fido2_yubikey" = "[FIDO]";
    };

    autoScreenLock = true;
    autoScreenUnlock = true;
  };
}
