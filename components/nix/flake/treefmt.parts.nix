{ inputs, lib, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
    inputs.pedantix.flakeModules.default
  ];

  perSystem =
    {
      inputs',
      config,
      pkgsUnstable,
      ...
    }:
    let
      pkgs = pkgsUnstable // {
        nixfmt = inputs'.nixfmt-rs.packages.default;
      };

      treefmt = config.treefmt.build.wrapper;
    in
    {
      # Define formatter for `nix fmt`.
      formatter = treefmt;
      packages.treefmt = treefmt;

      treefmt = {
        inherit pkgs;

        # Used to find the project root
        projectRootFile = ".git/config";

        settings.global.excludes = [
          "wezterm/shell-integration.sh"
          "components/config/keyboard/linux/docs/**"
          "**/fzf-git.sh"
          "**/*nmcli-rofi.sh"
        ];

        # Markdown, JSON, YAML, etc.
        programs.prettier = {
          enable = true;
          settings = {
            printWidth = 80;
            tabWidth = 2;
            semi = false;
            singleQuote = false;
            overrides = [
              {
                files = "*.md";
                options = {
                  proseWrap = "always";
                  tabWidth = 2;
                };
              }
            ];
          };
        };

        # Nix.
        programs.nixfmt.enable = true;
        programs.statix = {
          enable = true;

          disabled-lints = [
            "empty_pattern"
          ];
        };
        programs.pedantix = {
          enable = true;
          package = pkgs.pedantix;

          settings = {
            args.first = [
              "self"
              "self'"
              "inputs"
              "inputs'"
              "output"
              "outputs'"
              "config"
              "repo"
              "lib"
              "pkgs"
              "pkgsUnstable"
              "system"
              "mvs"
            ];

            # Do not reorder attribute sets; sets that are not
            # reordered keep their blank lines.
            attrs.sort = false;
            formatter = "off";

            preset = "nixos-module";
          };
        };

        # Secret scanning (no treefmt-nix program exists yet).
        # Does not modify files; exits non-zero when a leak is found.
        settings.formatter.betterleaks = {
          command = lib.getExe pkgs.betterleaks;
          options = [
            "dir"
            "--no-banner"
            "--redact"
            "--log-level=warn"
            "--verbose"
            "--config=${../../../tools/configs/betterleaks/conf.toml}"
          ];
          includes = [ "*" ];
        };

        # Shellscripts (which we should not have!)
        programs.shfmt = {
          enable = true;
          indent_size = 4;
        };

        programs.shellcheck.enable = true;

        # Lua.
        programs.stylua.enable = true;

        # Go.
        programs.gofmt.enable = true;
      };
    };
}
