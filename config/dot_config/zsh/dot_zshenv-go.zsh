export GOPATH="$HOME/.cache/go"
test -d "$GOPATH" || mkdir -p "$GOPATH"

if [ "$CHEZMOI_OS" = "darwin" ] &&
    brew --prefix golang &>/dev/null; then
    export GOROOT="$(brew --prefix golang)/libexec"
    export PATH="$GOROOT/bin:$PATH"
fi

export PATH="$GOPATH/bin:$PATH"
