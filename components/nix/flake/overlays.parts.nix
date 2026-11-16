{
  ...
}:
let
  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # We need a patched version with some dependencies (for the systemd service).
    vdirsyncer = prev.callPackage ../pkgs/vdirsyncer { vdirsyncer = prev.vdirsyncer; };
  };

in
{
  flake.overlays = {
    inherit modifications;
  };
}
