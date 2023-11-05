<img src="https://raw.githubusercontent.com/NixOS/nixos-artwork/4c449b822779d9f3fca2e0eed36c95b07d623fd9/ng/out/nix.svg" style="margin-left: 20pt; width: 150px" align="right">
<img src="config/docs/logo.svg" style="margin-left: 20pt; width:150px" align="right">
<h1>Dotfiles and NixOS Installation</h1>

These are my dotfiles managed with [chezmoi.io](https://www.chezmoi.io) and
NixOS configurations.

## NixOS Configurations

See the [documentation](nixos/README.md).

## Dotfiles

To install all files use [chezmoi.io](https://www.chezmoi.io):

```shell
chezmoi init https://github.com/gabyx/chezmoi.git
chezmoi diff
```

and to apply use

```shell
chezmoi apply
```

All together:

```shell
chezmoi init --apply --verbose https://github.com/gabyx/chezmoi.git
```
