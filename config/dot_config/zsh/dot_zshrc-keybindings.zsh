# To see the key characters press `CTRL+V` and afterwards the combination in
# a normal shell.
# Del/Home/End
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[3~" delete-char

# Ctrl+ Left/Right, for word back and forward movement.
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
export WORDCHARS='*?_-.[]~&;!#$%^(){}<>'

# Keybindings for substring search plugin.
# Maps up and down arrows and Alt+k, Alt+j
bindkey -M main '^[[A' history-substring-search-up
bindkey -M main '^[[B' history-substring-search-down
bindkey -M main '^[k' history-substring-search-up
bindkey -M main '^[j' history-substring-search-down

zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

# Ctrl+Space and Ctrl+f for accept the autosuggestion.
bindkey '^ ' autosuggest-accept
bindkey '^f' autosuggest-accept

# Map
# - CTRL+R to history,
# - Ctrl+Shift+D to cd widget and
# - Ctrl+Shift+K to the kill witched.
autoload znt-history-widget
# We use `fzf` history search.
# zle -N znt-history-widget
# bindkey "^R" znt-history-widget
zle -N znt-cd-widget
bindkey "^[[86;5u" znt-cd-widget
zle -N znt-kill-widget
bindkey "^[[75;5u"  znt-kill-widget
