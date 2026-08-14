# ~/.zshenv

# ----------------------
#  XDG Base Directories
# ----------------------
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# ----------------------
#  Default Applications
# ----------------------
export BROWSER='zen'
export TERMINAL='foot'
export READER='zathura'
export OPENER='xdg-open'
export EDITOR='nvim'
export VISUAL='nvim'

# ----------------------
#  Cargo / Rust  (sourced first — it prepends to PATH)
# ----------------------
[[ -r "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# ----------------------
#  PATH
# ----------------------
path=(
  "$HOME/.local/bin"
  "$HOME/.local/share/cargo/bin"
  "$HOME/.cargo/bin"
  "$XDG_DATA_HOME/npm/bin"
  "$HOME/go/bin"
  "$path[@]"
)
typeset -gU path
export PATH
