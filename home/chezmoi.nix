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

  sep =
    if length cfg.extraArgsInit != 0
    then "\\"
    else "";
  addArgsInit = lib.strings.concatStringsSep " " (map (a: "'${a}'") cfg.extraArgsInit);

  # Write the chezmoi config file `chezmoi.yaml` to the Nix store (derivation).
  configFile =
    pkgs.runCommand "chezmoi-init" {preferLocalBuild = true;} ''
    '';

  # Write the chezmoi configuration to the Nix store (derivation).
  destDir = pkgs.runCommandLocal "chezmoi-directory" {preferLocalBuild = true;} ''
    tempHome="$out"
    mkdir -p "$tempHome/.local/share"

    # Copy source to the default writable directory.
    srcDir="$tempHome/.local/share/chezmoi"
    cp -rf "${cfg.sourceDir}" "$srcDir"
    chmod +w "$srcDir"

    export HOME="$tempHome"

    # Init chezmoi with default prompts
    ${cfg.package}/bin/chezmoi init \
      -C "$out/chezmoi.yaml" \
      --promptChoice "What type of workspace are you on=private"

    uname -a
    ${cfg.package}/bin/chezmoi execute-template "{{ .chezmoi.osRelease }}"
    cat /etc/os-release
    exit 1
    ${cfg.package}/bin/chezmoi apply \
      --destination "$tempHome"
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

    extraArgsInit = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Additional chezmoi init arguments, e.g. to fill default prompts.";
    };

    dest = mkOption {
      type = types.package;
      description = "The chezmoi workspace option in .chezmoi.yaml.tmpl";
    };
  };

  config = lib.mkIf cfg.enable {
    chezmoi.dest = destDir;
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
