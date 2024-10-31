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

### Minimal Requirements

To deploy the configs you need the minimal stuff installed:

- `findutils`
- `delta`
- `git`
- `git-lfs`
- `age`
- `just`

### Encryption

Chezmoi is configured to use `age` as encryption tool with a secret private-key
file [config/dot_config/chezmoi/key.age](config/dot_config/chezmoi/key.age)
which was generated with:

```shell
age-keygen > key
age-keygen | tee | age -e --armor > key.age && rm key
```

where the printed private key `P` acts as the passphrase to decrypt `key.age`.

This file `key.age` is encrypted and contains the private key for all `age`
encryption in this repository. The file is encoded in human-readable PEM format
(`--armor`).

The file `key.age` is decrypted when `chezmoi apply` is run in a
[_before_ hook](config/run_before_decrypt-private-key.sh) such that all
encrypted files can be decrypted in one go. The decrypted key is then again
deleted in a _after_ hook](config/run_after_delete-decrypted-private-key.sh).

The "passphrase" `P` can be stored into the login keyring to make
`just apply-configs` **pass non-interactively**:

```shell
secret-tool store --label='Chezmoi Key-File Passphrase' chezmoi keyfile-private-key
```

Inspect the store with `seahorse`.

### Mail & Calendar

I am using `gnome-online-accounts` because they work flawlessly for a various of
different providers (`google`, `Exchange`). The mail/calendar client `evolution`
is really good and has a very nice user-experience also with PGP etc. It is
honestly better than `thunderbird` and integrates better into the system and
also from a security perspective (does not contain a browser etc.).

Automated setup of these online accounts apparently works but is still a bit
brittle. It is crucial to follow the below steps.

#### Automated Setup

Setting up the accounts happens with the two folders:

- `~/.config/goa-1.0`
- `~/.config/evolution/sources`

Skip to step 3 on a fresh system.

1. Check that there are no online accounts already setup:

   ```shell
   XDG_CURRENT_DESKTOP=GNOME gnome-control-center
   ```

   **Check tab `Online Accounts`.**

1. Make sure you do not have anything in your login keyring with a name starting
   with `GOA`. Check `seahorse`. Should be automatically true if no _online
   accounts_ are setup.

1. Kill all `evolution` processes: `evolution --force-shutdown`.

1. Delete all evolution settings and state:

   Stop also the services for `evolution`:

   ```shell
   systemctl --user stop evolution-addressbook-factory.service
   systemctl --user stop evolution-calendar-factory.service
   systemctl --user stop evolution-source-registry.service
   systemctl --user daemon-reload
   ```

   ```shell
   rm -rf ~/.config/evolution
   rm -rf ~/.local/share/evolution
   ```

1. Apply the two folders `~/.config/goa-1.0` and `~/.config/evolution/sources`
   with (**uncomment the ignore in `.chezmoiignore`**).

   ```shell
   just cm apply

   find ~/.config/evolution/sources -type f -name "*.source" | \
      xargs -I {} sed -i -E "s@NeedsInitialSetup=false@NeedsInitialSetup=true@" {}
   ```

1. Restart the `dbus` service, as it controls the
   [`goa-daemon`](https://manpages.ubuntu.com/manpages/bionic/man8/goa-daemon.8.html).
   Since we are using `dbus-broker` which exposes all `dbus` services as
   `systemd` services we can restart it together with the `evolution` services
   which might still be running.

   ```shell
   systemctl --user restart dbus-broker
   ```

   **This should log you out and then login again.**

   Only resetting with
   `systemctl --user restart dbus-:1.1-org.gnome.OnlineAccounts@0.service` or
   just login out did not work.

1. Stop any evolution already running after login.

   ```shell
   evolution --force-shutdown
   systemctl --user stop evolution-addressbook-factory.service
   systemctl --user stop evolution-calendar-factory.service
   systemctl --user stop evolution-source-registry.service
   ```

1. Now provide credentials to the online accounts in `gnome-control-center`:

   ```shell
   XDG_CURRENT_DESKTOP=GNOME gnome-control-center
   ```

1. Check `mail.nix` for adjustments in the `dconf` settings GUID strings.

1. Start `evolution` and you should see now all accounts be connected and
   working. If `evolution` starts up without having picked up the accounts, you
   probably need another `dbus` restart above or logout or complete `restart`.

#### Troubleshooting

- When I log out and in again, evolution gets sometimes really stuck in
  authentication and what helps is to do

  ```shell
     systemctl --user restart dbus-broker
  ```

- When `vdirsyncer sync` fails you can get the offending calendar entries by
  doing:

  ```shell
     curl -u "$user:$password" http://localhost:1080/users/gabriel.nuetzi@sdsc.ethz.ch/calendar/<file-path>
  ```

  or delete it with

  ```shell
     curl -u "$user:$password" -X DELETE http://localhost:1080/users/gabriel.nuetzi@sdsc.ethz.ch/calendar/<file-path>
  ```

  which resolves duplicate items issues.
