{
  config,
  pkgs,
  ...
}:
{
  home.pointerCursor = {
    package = pkgs.apple-cursor;
    name = "macOS-Monterey";
    size = 32;
  };
}
