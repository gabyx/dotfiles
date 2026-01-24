{
  ...
}:
{
  boot = {
    tmp.useTmpfs = true;
    tmp.cleanOnBoot = true;
  };

  services.qemuGuest.enable = true;
}
