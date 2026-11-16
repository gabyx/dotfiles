{ pkgsUnstable, ... }:
{
  # Extra bundled packages with nvim.
  # WARNING: LSPs etc. are specifically not bundled here,
  # because this is bound to the repository and its toolchain.
  vim.extraPackages = [
    pkgsUnstable.ripgrep
    pkgsUnstable.fd
  ];
}
