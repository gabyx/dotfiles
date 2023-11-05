# ![chezmoi logo](docs/logo.svg) My Dotfiles

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
