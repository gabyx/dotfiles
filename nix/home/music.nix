{
  lib,
  osConfig,
  pkgsUnstable,
  ...
}:
{
  home.file.".lv2/neural-amp-modeler" = lib.mkIf osConfig.settings.music.enabled {
    source = "${pkgsUnstable.neural-amp-modeler-lv2}/lib/lv2/neural_amp_modeler.lv2";
  };
}
