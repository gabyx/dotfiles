# shellcheck disable=SC1091
# echo "Sourcing ~/.bash_profile ..."

# Set locale.
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

source "$HOME/.config/zsh/.zshenv_go"
source "$HOME/.config/zsh/.zshenv_homebrew"
source "$HOME/.config/zsh/.zshenv_rust"

source "$HOME/.config/shell/aliases.bash"
source "$HOME/.config/shell/functions.bash"

source "$HOME/python-envs/default/bin/activate"

if [ -n "$WEZTERM_EXECUTABLE" ]; then
    # Shell integration for Wezterm.
    source "$HOME/.config/shell/wezterm.sh"
fi
