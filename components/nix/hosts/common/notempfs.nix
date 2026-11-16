{ lib, ... }:
{
  specialisation = {
    # Dont use tempfs (ram) for the /tmp.
    # Sometimes useful when building large stuff which exhausts memory.
    notempfs = {
      inheritParentConfig = true;
      configuration = {
        boot.tmp.useTmpfs = lib.mkForce false;
      };
    };
  };
}
