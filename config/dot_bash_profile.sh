# shellcheck disable=SC1091
# echo "Sourcing ~/.bash_profile ..."

# Source wezterm shell integration script
if [ -f "$HOME/.config/shell/integration-wezterm.sh" ]; then
    source "$HOME/.config/shell/integration-wezterm.sh"
fi

# Set locale.
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

source "$HOME/.config/zsh/.zshenv_go"
source "$HOME/.config/zsh/.zshenv_homebrew"
source "$HOME/.config/zsh/.zshenv_rust"

source "$HOME/.config/shell/aliases.bash"
source "$HOME/.config/shell/functions.bash"

source "$HOME/python-envs/default/bin/activate"


