{
  lib,
  pkgs,
  inputs,
  outputs,
  ...
}:
let
  # Define some special packages.
  wezterm-nightly = inputs.wezterm.packages."${pkgs.system}".default;
  githooks = inputs.githooks.packages."${pkgs.system}".default;
in
{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  home.packages = [
    # Basics
    pkgs.unstable.zoxide # A smarter cd.
    pkgs.unstable.age # Encryption tool.
    pkgs.unstable.libsecret # secret-tool to access gnome-keyring
    pkgs.unstable.git
    pkgs.unstable.git-lfs
    pkgs.unstable.git-town
    githooks
    pkgs.unstable.tig
    pkgs.unstable.seahorse
    pkgs.unstable.zenity # For dialogs over githooks and calendar.

    # Terminal
    pkgs.unstable.kitty
    pkgs.unstable.ghostty
    wezterm-nightly

    # Editors
    pkgs.unstable.vscode
    # neovim configured in `astronvim.nix`

    # Tools
    pkgs.unstable.restic # Backup tool
    pkgs.unstable.lf # File manager
    pkgs.unstable.chafa # For Sixel pictures in terminal
    pkgs.unstable.exiftool # For image meta preview.
    pkgs.unstable.atool # For archive preview
    pkgs.unstable.bat # For text preview with syntax highlight and Git integration.
    pkgs.unstable.poppler_utils # For image conversions.
    pkgs.unstable.ffmpegthumbnailer # For video thumbnails.
    pkgs.unstable.trash-cli # Trash command line to move stuff to trash.
    pkgs.unstable.gparted # Disk utility.
    pkgs.unstable.gnome-disk-utility # Easy disk utility `gdisk`.

    # Programming
    pkgs.unstable.parallel
    (lib.hiPrio pkgs.unstable.chezmoi)
    pkgs.unstable.lazygit
    pkgs.unstable.delta
    pkgs.unstable.difftastic
    pkgs.unstable.meld
    pkgs.unstable.kubectl
    pkgs.unstable.kind # Simple kubernetes for local development.
    pkgs.unstable.k9s # Kubernetes management CLI tool
    pkgs.unstable.kdiff3
    pkgs.unstable.jq
    pkgs.unstable.yq-go
    pkgs.unstable.yarn
    pkgs.unstable.remarshal
    pkgs.unstable.just
    pkgs.unstable.dive # Inspect container images.

    # FHS Environment with nix-alien
    inputs.nix-alien.packages.${pkgs.system}.nix-alien

    # Linters
    pkgs.unstable.markdownlint-cli
    pkgs.unstable.yamllint
    pkgs.unstable.nodePackages.jsonlint
    pkgs.unstable.codespell
    pkgs.unstable.typos
    pkgs.unstable.shfmt
    pkgs.unstable.shellcheck

    ## Lsp
    # rust-analyzer and clangd come with
    # the toolchain.
    pkgs.unstable.gopls
    pkgs.unstable.golangci-lint-langserver
    # pkgs.unstable.texlab
    pkgs.unstable.typos-lsp
    pkgs.unstable.nixd
    pkgs.unstable.marksman
    pkgs.unstable.lua-language-server
    pkgs.unstable.nodePackages.dockerfile-language-server-nodejs
    pkgs.unstable.nodePackages.bash-language-server
    pkgs.unstable.nodePackages.vscode-json-languageserver
    pkgs.unstable.nodePackages.yaml-language-server

    ## Python
    pkgs.unstable.python313
    pkgs.unstable.python313Packages.pip
    pkgs.unstable.python313Packages.isort
    pkgs.unstable.python313Packages.black
    pkgs.unstable.pyright

    ## Node (markdown-preview)
    pkgs.unstable.nodejs

    ## Nix
    pkgs.unstable.nix-tree
    pkgs.unstable.nixpkgs-lint
    pkgs.unstable.stdenv.cc # for neovim treesitter.
    pkgs.unstable.nixfmt-rfc-style
    pkgs.unstable.dconf2nix # To generate the `dconf` settings.

    ## Lua
    pkgs.unstable.stylua

    # Config Files
    pkgs.unstable.nodePackages.prettier

    # Writing
    # pkgs.unstable.texlive.combined.scheme-full
    pkgs.unstable.pandoc

    # Calendar/Mail (our version)
    pkgs.khal # CLI Calendar

    # MultiMedia
    pkgs.unstable.bitwarden # Password manager
    pkgs.unstable.bitwarden-cli
    pkgs.unstable.bazecor # Dygma Defy Keyboard.
    pkgs.unstable.signal-desktop-bin # Messaging app
    pkgs.unstable.element-desktop # Matrix client.
    pkgs.unstable.slack # Messaging app
    pkgs.unstable.transmission_3-gtk
    pkgs.unstable.ffmpeg # Movie converter
    pkgs.unstable.vlc # Movie player
    pkgs.unstable.amberol # Music player
    pkgs.unstable.showmethekey # Screencast the key-presses.

    pkgs.unstable.inkscape # Vector graphics
    pkgs.unstable.krita # Painting
    pkgs.unstable.nomacs # Image viewer
    pkgs.unstable.zathura # Simple document viewer
    pkgs.unstable.xournalpp # Another PDF viewer
    pkgs.unstable.pdfarranger # PDF arranger
    pkgs.unstable.ghostscript
    pkgs.unstable.imagemagick_light # Converter tools
    pkgs.unstable.ymuse # Sound player
    pkgs.unstable.zoom-us # Video calls
    pkgs.unstable.deluge # Bittorrent client
    pkgs.unstable.firefox
    pkgs.unstable.google-chrome
    pkgs.unstable.libreoffice

    # Sound
    pkgs.unstable.headsetcontrol
    pkgs.unstable.noson # Sonos device
    pkgs.ardour # Music recording

    # VPN
    pkgs.unstable.wgnord

    # Remote Desks
    pkgs.unstable.rustdesk # Remote desktop
    pkgs.unstable.anydesk

    # Dictionaries
    pkgs.unstable.aspell
    pkgs.unstable.aspellDicts.en
    pkgs.unstable.aspellDicts.en-computers
    pkgs.unstable.hunspell
    pkgs.unstable.hunspellDicts.en-us
  ];

}
