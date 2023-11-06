<h1 align="center">
    <img src="https://raw.githubusercontent.com/NixOS/nixos-artwork/4c449b822779d9f3fca2e0eed36c95b07d623fd9/ng/out/nix.svg" style="margin-left: 20pt; width: 150px" align="center"/>
    <span style="width:100px;display:inline-block;">+</span>
    <img src="config/docs/logo.svg" style="margin-left: 20pt; width:150px" align="center"/>
    <br>
    <br>
    Gabyx's Dotfiles & <br>NixOS Configuration
    <br>
</h1>

<p align="center">
<a href="./LICENSE"><img src="https://img.shields.io/badge/license-GPL-3.svg" alt="License"></a>
<a href="https://www.buymeacoffee.com/gabyx" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 20px !important;width: 87px;" ></a>
<a href="https://github.com/gabyx/dotfiles"><img src="https://img.shields.io/github/stars/gabyx/dotfiles?style=social" alt="Give me a Star"></a>
</p>

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
chezmoi init --apply --verbose https://github.com/gabyx/dotfiles.git
```
