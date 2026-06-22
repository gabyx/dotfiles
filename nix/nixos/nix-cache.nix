{ config, ... }:
{
  age.secrets.ssh-read-nix-cache-swisscustodian-ch = {
    file = builtins.path {
      path = ./secrets/ssh-read-nix-cache-swisscustodian-ch.age;
    };
    mode = "0400";
  };

  nix = {
    settings = {
      extra-substituters = [
        "ssh://nix-ssh@nix-cache.swisscustodian.ch"
      ];

      extra-trusted-public-keys = [
        "nix-cache.swisscustodian.ch.1:rPQnp1nJav3UluO5MeomJTEPeqffeIu7Y41xpecBqMA="
      ];
    };
  };

  # Nix Cache
  programs.ssh.extraConfig = ''
    Match localuser root host nix-cache.swisscustodian.ch
      User nix-ssh
      IdentityFile ${config.age.secrets.ssh-read-nix-cache-swisscustodian-ch.path}
      IdentitiesOnly yes
  '';
}
