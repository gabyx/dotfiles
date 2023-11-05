{ config, pkgs, ... }:

{
  ### Keyboard Settings =================================================
  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver = {
    layout = "programmer";
    xkbVariant = "";
    xkbOptions = "caps:ctrl_modifier";
    extraLayouts.programmer = {
      description = "Programmer (US)";
      languages = [ "eng" ];
      symbolsFile = ../configs/keyboard/symbols/programmer;
    };
  };

  console = {
    keyMap = "us";
  };
  # ===========================================================================
}
