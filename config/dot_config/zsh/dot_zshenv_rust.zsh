# Cargo Setup
if [ -f ~/.cargo/env ]; then
    . ~/.cargo/env
elif [ -d ~/.cargo/bin ]; then
    export PATH="~/.cargo/bin:$PATH"
fi

