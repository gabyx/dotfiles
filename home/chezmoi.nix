{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib; let
  cfg = config.chezmoi;
  # settingsFormat = pkgs.formats.yaml {};

  # Write the chezmoi.yaml to the store.
  # configFile =
  #   settingsFormat.generate "chezmoi.yaml" cfg.settings;

  # Write the chezmoi config file `chezmoi.yaml` to the Nix store (derivation).
  configFile = pkgs.runCommand "chezmoi-init" {preferLocalBuild = true;} ''
    HOME=${config.home.homeDirectory}
    mkdir -p $out
    ${cfg.package}/bin/chezmoi init \
      --config-path "$out/chezmoi.yaml" \
      --promptChoice workspace=${cfg.workspace} \
      --source ${cfg.sourceDir}
  '';

  # Write the chezmoi configuration to the Nix store (derivation).
  destDir = pkgs.runCommand "chezmoi-directory" {preferLocalBuild = true;} ''
    HOME=${config.home.homeDirectory}
    mkdir -p $out
    ${cfg.package}/bin/chezmoi apply \
      --config ${configFile} \
      --source ${cfg.sourceDir} \
      --destination $out
  '';
in {
  # Options for chezmoi configuration
  options.chezmoi = {
    enable = mkEnableOption "chemzoi";

    package = mkOption {
      type = types.package;
      default = pkgs.chezmoi;
      description = "The chezmoi package to use.";
    };

    sourceDir = mkOption {
      type = types.path;
      description = "The source directory to use for generating dotfiles.";
    };

    workspace = mkOption {
      type = type.string;
      default = "private";
      description = "The chezmoi workspace option in .chezmoi.yaml.tmpl";
    };
  };

  config = lib.mkIf cfg.enable {
    # This defines the home-manager file settings, which will
    # symlink the `destDir` store path from `chezmoi apply` into
    # the home folder
    # home.file.chezmoi-directory = {
    #   target = ".";
    #   source = destDir;
    #   recursive = true;
    # };

    # # HACK: Override home-files to fix recursively-linked directories.
    # home-files = let
    #   sourceStorePath = file: let
    #     sourcePath = toString file.source;
    #     sourceName = config.lib.strings.storeFileName (baseNameOf sourcePath);
    #   in
    #     if builtins.hasContext sourcePath
    #     then file.source
    #     else
    #       builtins.path {
    #         path = file.source;
    #         name = sourceName;
    #       };
    # in
    #   mkForce (pkgs.runCommandLocal
    #     "home-manager-files"
    #     {
    #       nativeBuildInputs = [pkgs.xorg.lndir];
    #     }
    #     (''
    #         mkdir -p $out
    #
    #         # Needed in case /nix is a symbolic link.
    #         realOut="$(realpath -m "$out")"
    #
    #         function insertFile() {
    #           local source="$1"
    #           local relTarget="$2"
    #           local executable="$3"
    #           local recursive="$4"
    #
    #           # If the target already exists then we have a collision. Note, this
    #           # should not happen due to the assertion found in the 'files' module.
    #           # We therefore simply log the conflict and otherwise ignore it, mainly
    #           # to make the `files-target-config` test work as expected.
    #           if [[ -e "$realOut/$relTarget" ]]; then
    #             if [[ $recursive && -d "$realOut/$relTarget" && -d "$source" ]]; then
    #               : skip
    #             else
    #               echo "File conflict for file '$relTarget'" >&2
    #               return
    #             fi
    #           fi
    #
    #           # Figure out the real absolute path to the target.
    #           local target
    #           target="$(realpath -m "$realOut/$relTarget")"
    #
    #           # Target path must be within $HOME.
    #           if [[ ! $target == $realOut* ]] ; then
    #             echo "Error installing file '$relTarget' outside \$HOME" >&2
    #             exit 1
    #           fi
    #
    #           mkdir -p "$(dirname "$target")"
    #           if [[ -d $source ]]; then
    #             if [[ $recursive ]]; then
    #               mkdir -p "$target"
    #               lndir -silent "$source" "$target"
    #             else
    #               ln -s "$source" "$target"
    #             fi
    #           else
    #             [[ -x $source ]] && isExecutable=1 || isExecutable=""
    #
    #             # Link the file into the home file directory if possible,
    #             # i.e., if the executable bit of the source is the same we
    #             # expect for the target. Otherwise, we copy the file and
    #             # set the executable bit to the expected value.
    #             if [[ $executable == inherit || $isExecutable == $executable ]]; then
    #               ln -s "$source" "$target"
    #             else
    #               cp "$source" "$target"
    #
    #               if [[ $executable == inherit ]]; then
    #                 # Don't change file mode if it should match the source.
    #                 :
    #               elif [[ $executable ]]; then
    #                 chmod +x "$target"
    #               else
    #                 chmod -x "$target"
    #               fi
    #             fi
    #           fi
    #         }
    #       ''
    #       + concatStrings (
    #         mapAttrsToList
    #         (n: v: ''
    #           insertFile ${
    #             escapeShellArgs [
    #               (sourceStorePath v)
    #               v.target
    #               (
    #                 if v.executable == null
    #                 then "inherit"
    #                 else toString v.executable
    #               )
    #               (toString v.recursive)
    #             ]
    #           }
    #         '')
    #         config.home.file
    #       )));
  };
}
