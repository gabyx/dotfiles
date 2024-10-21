{ pkgs, ... }:
{
  # Used to find the project root
  projectRootFile = ".git/config";

  # Markdown, JSON, YAML, etc.
  programs.prettier.enable = true;

  # Shellscripts (which we should not have!)
  programs.shfmt = {
    enable = true;
    indent_size = 4;
  };

  # Nix.
  programs.nixfmt.enable = true;
}
