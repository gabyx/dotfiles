{ ... }:
let
  swapConfig = import ./swap-offset.nix;
in
{
  kernelParams = [
    # Hibernation parameters
    "resume=UUID=${baseNameOf config.fileSystems."/swap".device}"
    "resume_offset=${toString swapConfig.resumeOffset}"
  ];
}
