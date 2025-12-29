{
  outputs,
  system,
  ...
}:
{
  home.file.".lv2/neural-amp-modeler" = {
    source = outputs.packages.${system}.neural-amp-modeler-lv2;
  };
}
