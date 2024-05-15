{
  vdirsyncer,
  coreutils,
}:
vdirsyncer.overrideAttrs (prevAttrs: {
  propagatedBuildInputs = prevAttrs.propagatedBuildInputs ++ [coreutils];
})
