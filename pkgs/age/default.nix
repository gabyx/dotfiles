{age}:
# We need a patched version of age such that decryption with `age -d` works
# by providing a passphrase over `AGE_PASSPHRASE` to run non-interactively.
age.overrideAttrs (prevAttrs: {
  patches = [./passphrase-from-env-patch.patch] ++ prevAttrs.patches;
})
