{ ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      icon = ../../config/dot_config/profile-icons/nixos-logo.png;
    in
    {
      packages = {
        test =
          pkgs.writeShellScriptBin "test"
            # bash
            ''
              set -eu
              mkdir -p /var/lib/AccountsService/{icons,users}
              pic="${icon}"

              echo "$pic"
            '';
      };
    };
}
