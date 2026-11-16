# `nvim` Configuration

This is my nvim configuration. Its a rip-of of
[astronvim](https://astronvim.com) which I used for years but becomes
unmanagable on a Nix/NixOS system due to integrated package managers and other
non deterministic non-sense where a Nix solution is 100x better.

You can run it **without interfering with your current `nvim` installation** by
doing

```bash
nix run "github:gabyx/dotfiles#nvim-gabyx" -- [--help]
```

# Features

Almost everything astronvim has:

- Language server/formatter setup where some language servers/formatters are
  baked and used as fallback if nothing else is on the `PATH` mostly provided by
  a Git repository Nix shell.
