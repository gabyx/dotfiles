if [ "$CHEZMOI_OS" = "darwin" ]; then

test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
test -f /usr/local/bin/brew && eval "$(/usr/local/bin/brew shellenv)"

PATH="/usr/local/opt/grep/libexec/gnubin:$PATH"
PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"
PATH="/usr/local/opt/gnu-which/libexec/gnubin:$PATH"
PATH="/usr/local/opt/findutils/libexec/gnubin:$PATH"
PATH="/usr/local/opt/gnu-time/libexec/gnubin:$PATH"
PATH="/usr/local/opt/gnu-getopt/libexec/gnubin:$PATH"
PATH="/usr/local/opt/corutils/libexec/gnubin:$PATH"
PATH="/usr/local/opt/binutils/libexec/gnubin:$PATH"

PATH="/usr/local/opt/llvm@16/bin:$PATH"
PATH="/usr/local/opt/gcc@13/bin:$PATH"

PATH="/usr/local/opt/llvm@13/bin:$PATH"
PATH="/usr/local/opt/gcc@11/bin:$PATH"
export PATH

else

test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
test -d /home/linuxbrew/.linuxbrew/bin && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

fi
