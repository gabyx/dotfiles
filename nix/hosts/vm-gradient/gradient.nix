# Gradient CI (server, local worker, PostgreSQL and nginx).
# Adapted from `nix/standalone/default.nix` in https://github.com/wavelens/gradient.
# The web frontend is reachable on the host at `http://localhost:8080`.
{
  inputs,
  pkgs,
  ...
}:
let
  stateDir = "/var/lib/gradient-vm";
  url = "http://localhost:8080";
in
{
  imports = [ inputs.gradient.nixosModules.default ];

  services.gradient = {
    enable = true;
    domain = "localhost";

    serveUrl = url;
    useTls = false;

    postgres.enable = true;
    registration.enable = false;

    secrets = {
      jwtFile = "${stateDir}/jwt";
      cryptFile = "${stateDir}/crypt";
    };

    worker = {
      enable = true;
      capabilities = {
        network = true;
        secrets = true;
        eval = true;
        build = true;
      };
    };

    state.users.admin = {
      email = "admin@localhost";
      password_file = "${stateDir}/admin-password-hash";
      superuser = true;
    };
  };

  # Gradient needs PostgreSQL 18 or newer.
  services.postgresql.package = pkgs.postgresql_18;

  networking.firewall.allowedTCPPorts = [ 80 ];

  nix.settings = {
    sandbox = true;
  };

  # Generate the secrets and the admin password on first boot.
  systemd.services.gradient-vm-secrets = {
    wantedBy = [ "multi-user.target" ];
    requiredBy = [ "gradient-server.service" ];
    before = [ "gradient-server.service" ];

    path = [
      pkgs.openssl
      pkgs.libargon2
    ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      StateDirectory = "gradient-vm";
      StateDirectoryMode = "0700";
      UMask = "0077";
    };
    script = ''
      cd ${stateDir}
      [ -e jwt ] || openssl rand -base64 48 > jwt
      [ -e crypt ] || openssl rand -base64 48 > crypt
      if [ ! -e admin-password-hash ]; then
        openssl rand -base64 18 > admin-password
        tr -d '\n' < admin-password | argon2 "$(openssl rand -hex 16)" -id -e > admin-password-hash
      fi
    '';
  };

  # Print the login to the console.
  systemd.services.gradient-vm-login = {
    wantedBy = [ "multi-user.target" ];
    after = [
      "gradient-server.service"
      "nginx.service"
    ];
    requires = [ "gradient-vm-secrets.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      StandardOutput = "journal+console";
    };
    script = ''
      echo "Gradient is running at ${url} - log in with admin / $(cat ${stateDir}/admin-password)"
    '';
  };
}
