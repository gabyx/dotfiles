{
  config,
  pkgs,
  ...
}: {
  ### Keyboard Settings =================================================
  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    keyMap = "us";
  };

  services.xserver = {
    layout = "programmer";
    xkbVariant = "";
    xkbOptions = "ctrl:nocaps";
    extraLayouts.programmer = {
      description = "Programmer (US)";
      languages = ["eng"];
      symbolsFile = ../../config/keyboard/linux/symbols/programmer;
    };
  };

  # Logitech Receiver and Solaar Gui
  hardware.logitech.wireless = {
    enable = true;
    enableGraphical = true;
  };

  # Tablets
  hardware.opentabletdriver.enable = true;

  environment.systemPackages = with pkgs; [
    # Logitech
    solaar
    xorg.xmodmap

    # Tablets (Wacom)
    libwacom
    wacomtablet
    # xf86_input_wacom #Only on non-wayland.
  ];

  # ===========================================================================
}
