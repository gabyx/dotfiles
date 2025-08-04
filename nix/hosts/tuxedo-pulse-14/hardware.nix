{
  pkgs,
  lib,
  ...
}:
{
  # Enable bluetooth
  hardware.bluetooth = {
    enable = true; # enables support for Bluetooth
    powerOnBoot = true; # powers up the default Bluetooth controller on boot
  };

  services.blueman.enable = true;

  # Enable tuxedo-rs and tuxedo-drivers.
  hardware.tuxedo-drivers.enable = true;
  hardware.tuxedo-rs = {
    enable = true;
    tailor-gui.enable = true;
  };

  # Setup OpenCL for AMD GPU
  hardware.graphics.extraPackages = with pkgs; [ rocmPackages.clr.icd ];

  # Power Management
  # The hardware includes for Tuxedo define if `tpl` is used or not.
  services.tlp = {
    # We are not using `tlp` for now.
    enable = lib.mkForce false;

    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 80;

      # Optional helps save long term battery health
      START_CHARGE_THRESH_BAT0 = 50; # 50 and bellow it starts to charge
      STOP_CHARGE_THRESH_BAT0 = 95; # 95 and above it stops charging
    };
  };

  # We use `auto-cpufreq` tool.
  programs.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        governor = "powersave";
        turbo = "never";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };
  };
}
