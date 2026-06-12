# XDG Directories
export XDG_DATA_HOME="$HOME/.local/share"

# Default Applications
export BROWSER='zen-browser'
export TERMINAL='contour'
export READER='zathura'
export OPENER='xdg-open'
export EDITOR='nvim'
export SHELL=/usr/bin/zsh

# Shell Behavior
export IGNOREEOF=42
export HISTSIZE=9999
export DIRSTACKSIZE=25

# PATH Additions
path+=(
  "$HOME/.local/bin"
  "$HOME/.local/share/cargo/bin"
  "$HOME/.cargo/bin"
  "$XDG_DATA_HOME/npm/bin"
  "$HOME/go/bin"
  "$path[@]"
)
export PATH

# Cargo environment
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
