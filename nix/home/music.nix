{
  self,
  system,
  ...
}:
{
  home.file.".lv2/neural-amp-modeler" = {
    source = "${self.packages.${system}.neural-amp-modeler-lv2}/lib/lv2/neural_amp_modeler.lv2";
  };
}
