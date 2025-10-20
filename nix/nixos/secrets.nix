{
  pkgs,
  inputs,
  ...
}:
{
  config = {
    # Setup encryption for secrets in this NixOS configuration.
    # So far we do not use this yet, since we would need to provide a non-passhrase protected
    # private key which we dont want.
    age = {
      # Private keys:
      # Defaults to `config.services.openssh.hostKeys`.
      identityPaths = [
        # Passphrase protected keys dont work.

        # Add another possible location for a root key.
        #  - sudo chown root:root host-ed25519
        #  - sudo chmod 600 host-ed25519
        #  - sudo chmod 644 host-ed25519.pub
        # Must be at a location which is mounted during boot.
        "/persist/etc/ssh/host-ed25519"
      ];
    };

    # Add `agenix` tool to the packages.
    environment.systemPackages = [ inputs.agenix.packages.${pkgs.system}.default ];
  };
}
