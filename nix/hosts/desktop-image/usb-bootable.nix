{ ... }: {
  # Make the `images.iso` variant a hybrid image (USB + EFI bootable).
  image.modules.iso = {
    isoImage = {
      makeUsbBootable = true;
      makeEfiBootable = true;
      compressImage = true;
    };
  };
}
