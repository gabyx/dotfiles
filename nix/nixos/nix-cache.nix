{ config, ... }:
{
  age.secrets.netrc-nix-cache = {
    file = builtins.path {
      path = ./secrets/netrc-nix-cache.age;
    };
    mode = "0400";
  };

  nix = {
    settings = {
      extra-substituters = [ ];

      extra-trusted-public-keys = [ ];

      netrc-file = "${config.age.secrets.netrc-nix-cache.path}";
    };
  };

  # Nix Cache
  # programs.ssh.extraConfig = ''
  #   Match localuser root host nix-cache.swisscustodian.ch
  #     User nix-ssh
  #     IdentityFile ${config.age.secrets.ssh-read-nix-cache-swisscustodian-ch.path}
  #     IdentitiesOnly yes
  # '';
}
