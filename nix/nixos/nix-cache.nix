{ lib, config, ... }:
{
  config = {
    age.secrets.netrc-nix-cache = lib.mkIf config.settings.secrets.enable {
      file = builtins.path {
        path = ./secrets/netrc-nix-cache.age;
      };
      mode = "0400";
    };

    nix = {
      settings = {
        # Trusted substituters can be requested by the client.
        extra-trusted-substituters = [
          "https://nix-community.cachix.org"
          "https://cache.nixos-cuda.org"
          "https://devenv.cachix.org"

          "https://gabyx.cachix.org"
          "https://nixos-jetson.cachix.org"
        ];
        extra-trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
          "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="

          "gabyx.cachix.org-1:5y5PWAuHEyaPnqKg0qhvUMibVooTFGVA9h5L8uBKY40="
          "nixos-jetson.cachix.org-1:tH3HqoxpZzF9tel7DgV2iOHFohD8swtQNrYK0XMBpRY="
        ];

        netrc-file = lib.mkIf config.settings.secrets.enable "${config.age.secrets.netrc-nix-cache.path}";
      };
    };

    # Nix Cache
    # programs.ssh.extraConfig = ''
    #   Match localuser root host nix-cache.swisscustodian.ch
    #     User nix-ssh
    #     IdentityFile ${config.age.secrets.ssh-read-nix-cache-swisscustodian-ch.path}
    #     IdentitiesOnly yes
    # '';
  };
}
