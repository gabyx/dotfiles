{
  vdirsyncer,
  coreutils,
}:
# We need a patched version with some more dependencies.
# We need `cat` in `vdirsyncer` available to extract secrets.
vdirsyncer.overrideAttrs (prevAttrs: {
  propagatedBuildInputs = prevAttrs.propagatedBuildInputs ++ [ coreutils ];
})
