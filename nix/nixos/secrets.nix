{
  system,
  inputs,
  ...
}:
{
  config = {
    # Setup encryption for secrets in this NixOS configuration.
    age = {
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
    environment.systemPackages = [ inputs.agenix.packages.${system}.default ];
  };
}
