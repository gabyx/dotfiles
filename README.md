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

These are my [dotfiles](config) managed with
[chezmoi.io](https://www.chezmoi.io) for Linux and MacOS (and partially the
other shit OS which desperately tries to convert itself into a \*nix OS) and
[NixOS](nixos) configurations for Desktop and VM.

![Screenshot](./nixos/docs/screenshot.png)

| Program                     | Name                                                                                                                                              |
| :-------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------ |
| Linux Distribution          | [NixOS](https://www.nixos.org/)                                                                                                                   |
| Window Manager              | [sway](https://github.com/swaywm/sway)                                                                                                            |
| Bar                         | [waybar](https://github.com/Alexays/Waybar)                                                                                                       |
| Wallpaper Setter            | [sway](https://github.com/swaywm/sway)                                                                                                            |
| Program Launcher & Menus    | [rofi](https://github.com/DaveDavenport/rofi)                                                                                                     |
| Clipboard                   | [copyq](https://hluk.github.io/CopyQ/) with special password ignore command                                                                       |
| Screenshot                  | [grimshot](https://search.nixos.org/packages?channel=23.05&show=sway-contrib.grimshot&from=0&size=50&sort=relevance&type=packages&query=grimshot) |
| Colorpicking                | [hyprpick](https://github.com/hyprwm/hyprpicker) and [gcolor3](https://gitlab.gnome.org/World/gcolor3)                                            |
| Nightshifting               | [gammastep](https://gitlab.com/chinstrap/gammastep)                                                                                               |
| Notification                | [swaync](https://github.com/ErikReider/SwayNotificationCenter)                                                                                    |
| Calendar and Meeting Status | [vdirsyncer](https://vdirsyncer.pimutils.org/en/stable) and [khal](https://khal.readthedocs.io/en/latest/)                                        |
| Browser                     | [Chrome](https://www.google.com/intl/de/chrome/)                                                                                                  |
| Editor                      | [Nvim](https://neovim.io/) with [Astrovim](https://github.com/gabyx/astrovim)                                                                     |
| Normal Font                 | [NotoSans Nerd Font](https://www.nerdfonts.com/)                                                                                                  |
| Editor/Terminal Font        | [JetBrainsMono Nerd Font](https://www.jetbrains.com/lp/mono)                                                                                      |
| Shell                       | [zsh](https://www.zsh.org/)                                                                                                                       |
| Terminal Emulator           | [wezterm](https://wezfurlong.org) [kitty](https://sw.kovidgoyal.net/kitty)                                                                        |

## NixOS Configurations

See the [documentation](nixos/README.md) to learn how to install NixOS on to
your system or in a VM.

## Configuration Files

To install configuration files we use [`chezmoi`](https://www.chezmoi.io):

```shell
chezmoi init https://github.com/gabyx/chezmoi.git
chezmoi diff
```

and to apply use

- For non encrypted files use (which is truly non-interactively, no passphrase
  prompt)

  ```shell
  just apply-configs-exclude-encrypted
  ```

- For encrypted files use (which might prompt for the passphrase):

  ```shell
  just apply-configs
  ```

### Encryption

Chezmoi is configured to use `age` as encryption tool with a secret private-key
file [config/dot_config/chezmoi/key.age](config/dot_config/chezmoi/key.age)
which was generated with:

```shell
age-keygen | age --passphrase --armor > key.age
```

This file `key.age` is passphrase encrypted and contains the secret-key for all
`age` encryption in this repository. The file is encoded in human-readable PEM
format (`--armor`).

The file `key.age` is decrypted (interactive passphrase prompt) when
`chezmoi apply` is run in a
[_before_ hook](config/run_before_decrypt-private-key.sh) such that all
encrypted files can be decrypted in one go. The decrypted key is then again
deleted in a _after_ hook](config/run_after_delete-decrypted-private-key.sh).

The passphrase can be stored into the login keyring to make `just apply-configs`
**pass non-interactively**:

```shell
secret-tool store --label='Chezmoi Key-File Passphrase' chezmoi keyfile-passphrase
```

Inspect the store with `seahorse`.
