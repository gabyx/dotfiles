{ antidote }:
let
  plugins = ./.zplugins;
  pluginsSnapshot = ./.zplugins-snapshot;
in
# zsh
''
  # Installing plugins ===========================================================
  # Setup antidote if not yet setup.
  ANTIDOTE_HOME=$ZDOTDIR/.antidote/.plugins
  zstyle ':antidote:bundle' use-friendly-names 'yes'
  zstyle ':antidote:bundle' file "${plugins}"
  zstyle ':antidote:snapshot' dir "$ZDOTDIR/.antidote-snapshots"
  zstyle ':antidote:snapshot:automatic' enabled yes
  zstyle ':antidote:snapshot' max 2

  source "${antidote}/share/antidote/antidote.zsh"

  function install_plugins() {
      zstyle -s ':antidote:bundle' file zsh_plugins_src
      local zsh_plugins="$ZDOTDIR/.zsh_plugins.zsh"
      local force_bundle="false"

      # Destination not existing -> force.
      if [ ! -f "$zsh_plugins" ]; then
          echo "Zsh plugin bundle file '$zsh_plugins' not existing."
          force_bundle="true"
      fi

      if [ "$force_bundle" = "true" ]; then
          echo "Restore plugins from snapshot."
          antidote snapshot restore "${pluginsSnapshot}"

          echo "Generate static plugins file '$zsh_plugins' from '$zsh_plugins_src'..."
          antidote bundle <"$zsh_plugins_src" >"$zsh_plugins"
      fi
  }

  # Install antidote and bundle plugins.
  install_plugins
  # Loading plugins
  source "$ZDOTDIR/.zsh_plugins.zsh"
  # ==============================================================================
''
