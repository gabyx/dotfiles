{
  pkgs,
  config,
  inputs,
  ...
}:
{
  # Setup encryption for secrets in this NixOS configuration.
  # So far we do not use this yet, since we would need to provide a non-passhrase protected
  # private key which we dont want.
  age = {
    identityPaths = [
      # This is the private SSH key, which is passphrase-protected.
      # This wont work with the `agenix.service` since the underlying `age`
      # prompts for a password.
      "${config.home.homeDirectory}/.ssh/gabyx_ed25519"
    ];
  };

  # Add `agenix` tool to the packages.
  home.packages = [ inputs.agenix.packages.${pkgs.system}.default ];

  # age.secrets.mysecret.file = ./secrets/secret1.age;
}
