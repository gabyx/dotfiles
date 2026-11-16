{ inputs, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  perSystem =
    {
      config,
      inputs',
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

        # Shellscripts (which we should not have!)
        programs.shfmt = {
          enable = true;
          indent_size = 4;
        };

        programs.shellcheck.enable = true;

        # Lua.
        programs.stylua.enable = true;

        # Nix.
        programs.nixfmt.enable = true;

        # Go.
        programs.gofmt.enable = true;
      };
    };
}
