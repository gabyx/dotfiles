{
  config,
  pkgs,
  ...
}:
let
  # This is a workaround for
  # https://github.com/nix-community/home-manager/issues/1011
  homeManagerSessionVars = "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh";
in
{
  ### Environment ================================================================
  environment = {
    shells = [ "/run/current-system/sw/bin/zsh" ];

    enableAllTerminfo = true;
  };

  # Load home manager session variables.
  environment.extraInit = "[[ -f ${homeManagerSessionVars} ]] && source ${homeManagerSessionVars}";
  # ===========================================================================
}
