{ ... }: {
  services.smartd = {
    enable = true;
    notifications.systembus-notify.enable = true;
  };
}
