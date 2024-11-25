{
  config,
  pkgs,
  ...
}:
{
  # Use `udevadm info -a -n /dev/sde1` to find relevant matching criteria.
  system.udev = {

    # Backup Rule (WIP)
    # extraRules = ''
    #   ACTION="add", SUBSYSTEM=="block", ATTRS{idVendor}=="0781", ATTRS{idProduct}=="55ae",  ATTRS{manufacturer}=="SanDisk", ATTRS{model}=="Extreme 55AE*", ENV{HOME}="${config.settings.user.home}", RUN+="/home/nixos/.config/restic/backup.sh --non-interactive"
    # '';

    packages = [
      pkgs.headsetcontrol
      pkgs.bazecor
    ];

  };

}
