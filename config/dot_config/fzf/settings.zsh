export FZF_DEFAULT_OPTS="
  --layout=reverse --border --inline-info
  --color=fg:#dedbdb,bg:#1A1D23,hl:#5f87af
  --color=fg+:#ededed,bg+:#595959,hl+:#5fd7ff
  --color=info:#b3b312,prompt:#f23000,pointer:#af5fff
  --color=marker:#87ff00,spinner:#af5fff,header:#87afaf"

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# To make the keypresses in `fzf-git` work.
KEYTIMEOUT=300

# Preview file content using bat (https://github.com/sharkdp/bat)
export FZF_CTRL_T_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"

# Shift+/ to toggle small preview window to see the full command
export FZF_CTRL_R_OPTS="
  --preview 'echo {}' --preview-window up:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --color header:italic"

# Print tree structure in the preview window
export FZF_ALT_C_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'tree -C {}'"

function _fzf_compgen_path() {
    fd --hidden --exclude .git . "$1"
}

function _fzf_compgen_dir() {
    fd --type=d --hidden --exclude .git . "$1"
}
