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
    xkb = {
      layout = "programmer-defy";
      variant = "";
      options = "ctrl:nocaps";

      extraLayouts.programmer-defy = {
        description = "Prog. Defy (US)"; # Must have the same naming as in the file !!!
        languages = ["eng"];
        symbolsFile = ../../config/keyboard/linux/symbols/programmer-defy;
      };

      extraLayouts.programmer = {
        description = "Prog. Mx (US)";
        languages = ["eng"];
        symbolsFile = ../../config/keyboard/linux/symbols/programmer;
      };
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
