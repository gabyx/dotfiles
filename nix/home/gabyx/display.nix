{
  config,
  pkgs,
  ...
}:
{
  home.pointerCursor = {
    x11.enable = true;
    gtk.enable = true;
    package = pkgs.apple-cursor;
    name = "macOS";
    size = 32;
  };

  gtk.enable = true;
}
