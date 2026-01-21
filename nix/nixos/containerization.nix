{
  config,
  pkgsUnstable,
  ...
}:
{
  ### Virtualisation ==========================================================
  users.users.${config.settings.user.name}.extraGroups = [
    # "docker" # If you do this, you dont need to run `sudo`
    # but this gives root shell access.
    "podman"
  ];

  # Docker =================================
  virtualisation.docker = {
    enable = true;
    package = pkgsUnstable.docker;
    enableOnBoot = true;

    rootless = {
      enable = false;
      setSocketVariable = true;
    };

    # Auto prune podman resources.
    autoPrune = {
      dates = "weekly";
      flags = [ "--external" ];
    };
  };
  # =======================================

  # Podman ================================
  virtualisation.podman = {
    enable = true;
    package = pkgsUnstable.podman;

    # Create a `docker` alias for podman, to use it as a drop-in replacement
    # dockerCompat = true;
    # dockerSocket = {
    #   enable = true;
    # };

    # Required for containers under podman-compose to be able to talk to each other.
    defaultNetwork.settings.dns_enabled = true;

    # Auto prune podman resources.
    autoPrune = {
      dates = "weekly";
      flags = [ "--external" ];
    };
  };

  virtualisation.containers = {
    # Podman already enables this, I guess.
    enable = true;

    # storage.settings = {
    #   storage = {
    #     driver = "overlay";
    #     graphroot = "/var/lib/containers/storage";
    #     runroot = "/run/containers/storage";
    #     options.overlay = {
    #       mount_program = lib.getExe pkgs.fuse-overlayfs;
    #       mountopt = "nodev,fsync=0";
    #     };
    #   };
    # };
  };
  # =======================================

  security.pam.loginLimits = [
    {
      domain = "*";
      type = "-";
      item = "nofile";
      value = "65536";
    }
    {
      domain = "*";
      type = "-";
      item = "nproc";
      value = "1048576";
    }
  ];

  # Packages
  environment.systemPackages = [
    pkgsUnstable.podman-compose
    pkgsUnstable.docker-buildx
  ];
  # ===========================================================================
}
