{ lib, ... }: {
  # Make the `images.iso` variant a hybrid image (USB + EFI bootable).
  image.modules.iso = {
    # Never mount the target disk layout from disko on # the iso variant.
    disko.enableConfig = lib.mkForce false;

    isoImage = {
      compressImage = true;
      makeUsbBootable = true;
      makeEfiBootable = true;
    };
  };
}
