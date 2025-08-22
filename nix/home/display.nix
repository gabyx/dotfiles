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
    name = "macOS-Monterey";
    size = 32;
  };

  gtk.enable = true;
}
