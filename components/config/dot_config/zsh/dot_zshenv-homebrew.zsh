if [ "$CHEZMOI_OS" = "darwin" ]; then

    homebrew_path=(~/.linuxbrew /opt/homebrew/ /usr/local)

    for p in "${homebrew_path[@]}"; do
        if [ -f "$p/bin/brew" ]; then
            eval "$("$p/bin/brew" shellenv)"
            homebrew_dir="$p"
        fi
    done

    if [ -z "$HOMEBREW_PREFIX" ]; then
        echo "Homebrew directory is not found." >&2
        exit 0
    fi
    unset homebrew_paths

    PATH="$HOMEBREW_PREFIX/opt/grep/libexec/gnubin:$PATH"
    PATH="$HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin:$PATH"
    PATH="$HOMEBREW_PREFIX/opt/gnu-tar/libexec/gnubin:$PATH"
    PATH="$HOMEBREW_PREFIX/opt/gnu-which/libexec/gnubin:$PATH"
    PATH="$HOMEBREW_PREFIX/opt/findutils/libexec/gnubin:$PATH"
    PATH="$HOMEBREW_PREFIX/opt/gnu-time/libexec/gnubin:$PATH"
    PATH="$HOMEBREW_PREFIX/opt/gnu-getopt/libexec/gnubin:$PATH"
    PATH="$HOMEBREW_PREFIX/opt/corutils/libexec/gnubin:$PATH"
    PATH="$HOMEBREW_PREFIX/opt/binutils/libexec/gnubin:$PATH"

    export PATH

else

    test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
    test -d /home/linuxbrew/.linuxbrew/bin && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

fi
