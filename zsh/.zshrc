#!/usr/bin/env zsh

# ----------------------
#  Constants
# ----------------------
typeset -g ZSH_HIST_SIZE=200000
typeset -g ZSH_TIMING_THRESHOLD=0.5
typeset -g ZSH_GIT_CACHE_TTL=${ZSH_GIT_CACHE_TTL:-2}
typeset -g ZC_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"

# --------------------------------
#  Path & Environment Sanitization
# --------------------------------
path=("${path[@]:#}") fpath=("${fpath[@]:#}")
typeset +x FPATH fpath cdpath CDPATH


# ----------------------
#  Early Shell Options
# ----------------------
setopt NO_BEEP COMBINING_CHARS RC_EXPAND_PARAM
setopt AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT
setopt EXTENDED_HISTORY HIST_EXPIRE_DUPS_FIRST HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS HIST_SAVE_NO_DUPS
setopt INC_APPEND_HISTORY SHARE_HISTORY

setopt AUTO_LIST AUTO_MENU COMPLETE_IN_WORD ALWAYS_TO_END
setopt NO_CASE_GLOB
setopt LIST_PACKED

zle_highlight=('paste:none')
skip_global_compinit=1
DISABLE_AUTO_UPDATE=true

# --------------------------
#  Deja Suggestion Bindings
# --------------------------
export DEJA_CYCLE_KEY='^K'
export DEJA_ACCEPT_KEY='^H'
export DEJA_WORD_ACCEPT_KEY='^[[1;5C'
export DEJA_DISMISS_KEY='^J'

# ----------------------
#  Zinit Plugin Manager
# ----------------------
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
  print -P "%F{blue}󰑓 Installing Zinit...%f"
  command mkdir -p "$(dirname "$ZINIT_HOME")"
  if command git clone --depth=1 --quiet https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME" 2>/dev/null; then
    print -P "%F{green}󰗢 Zinit installed successfully.%f"
  else
    print -P "%F{red}󰗴 Failed to install Zinit.%f"
    return 1
  fi
fi
source "${ZINIT_HOME}/zinit.zsh"

# --------------------------
#  Plugin Loads
# --------------------------
zinit ice as"program" from"gh-r" pick"zsh-patina-*/zsh-patina" wait"1" lucid atload'eval "$(zsh-patina activate)"'
zinit light michel-kraemer/zsh-patina

zinit ice wait"0" lucid depth=1
zinit light Giammarco-Ferranti/deja

zinit ice lucid blockf
zinit light-mode for zsh-users/zsh-completions

zinit ice wait"1" lucid
zinit light-mode for OMZL::history.zsh OMZP::sudo

# -------------------------------
#  External Integrations (zoxide)
# -------------------------------
if (( $+commands[zoxide] )); then
  eval "$(zoxide init --cmd cd zsh)"
fi

# ----------------------
#  Completion UI Setup
# ----------------------
zmodload zsh/complist
[[ -d "$ZC_CACHE_DIR" ]] || command mkdir -p "$ZC_CACHE_DIR"

zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$ZC_CACHE_DIR/zcompcache"
zstyle ':completion:*' verbose yes
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:messages'     format '%F{242}-- %d --%f'
zstyle ':completion:*:descriptions' format '%F{blue}╭─%f %F{cyan}%d%f %F{blue}─╮%f'
zstyle ':completion:*:corrections'  format '%F{green}╭─%f %F{yellow}%d%f %F{242}(errors: %e)%f %F{green}─╮%f'
zstyle ':completion:*:warnings'     format '%F{red}╭─%f No matches for: %F{yellow}%d%f %F{red}─╮%f'
zstyle ':completion:*' menu yes=long-list select=1
zstyle ':completion:*' list-prompt '%S%F{cyan}Scroll with ←/→ or ↑/↓, Tab to move, Enter to accept (%p)%f%s'
zstyle ':completion:*' select-prompt '%S%F{cyan}%l match(es)%f %F{242}(%p)%f%s'
zstyle ':completion:*' matcher-list \
  'm:{a-z}={A-Z}' \
  '+r:|[._-]=* r:|=*' \
  '+l:|=* r:|=*'
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:approximate:*' max-errors 2 numeric
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' accept-exact '(N)'
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:source:*' accept-exact false
zstyle ':completion:*:.:*'      accept-exact false
zstyle ':completion:*:source:*' add-space false
zstyle ':completion:*:.:*'      add-space false

# -----------------------------
#  Completion System Init (cached)
# -----------------------------
typeset -g _COMPS_INITIALIZED=0
autoload -Uz compinit
.zshrc-compinit() {
  [[ $_COMPS_INITIALIZED -eq 1 ]] && return
  _COMPS_INITIALIZED=1
  local dump_file="$ZC_CACHE_DIR/zcompdump"
  compinit -C -i -d "$dump_file"
}
.zshrc-compinit

# ----------------------
#  History Settings
# ----------------------
HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/history"
[[ ! -d "$(dirname "$HISTFILE")" ]] && command mkdir -p "$(dirname "$HISTFILE")"
HISTSIZE=$ZSH_HIST_SIZE
SAVEHIST=$ZSH_HIST_SIZE

# -------------------------------
#  Git Prompt (with caching)
# -------------------------------
typeset -g __GIT_CACHE=""
typeset -g __GIT_CACHE_TIME=0
typeset -g __GIT_CACHE_PWD=""

.zshrc-git-status() {
  local current_time=$EPOCHSECONDS current_pwd="$PWD"
  if [[ "$current_pwd" == "$__GIT_CACHE_PWD" ]] && (( current_time - __GIT_CACHE_TIME < ZSH_GIT_CACHE_TTL )); then
    echo  "$__GIT_CACHE"
    return
  fi

  command git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    __GIT_CACHE=""
    __GIT_CACHE_TIME=$current_time
    __GIT_CACHE_PWD="$current_pwd"
    return
  }

  local branch
  branch=$(command git symbolic-ref --quiet --short HEAD 2>/dev/null) \
    || branch=$(command git describe --tags --exact-match 2>/dev/null) \
    || branch=$(command git rev-parse --short HEAD 2>/dev/null) \
    || branch="detached"

  # Core: just branch icon + name
  local status_output="%F{cyan} $branch%f"

  local git_status
  git_status=$(command git status --porcelain=v1 2>/dev/null)

  local ahead_val=0 behind_val=0
  local rr
  rr=$(command git rev-list --count --left-right '@{upstream}...HEAD' 2>/dev/null) || rr=""
  if [[ -n $rr ]]; then
    behind_val=${rr%%$'\t'*}
    ahead_val=${rr##*$'\t'}
  fi

  if [[ -n "$git_status" ]]; then
    local staged_count=0 modified_count=0 untracked_count=0 deleted_count=0
    local line
    while IFS= read -r line; do
      case "${line:0:2}" in
        M*|A*|D*|R*|C*) ((staged_count++));;
      esac
      case "${line:1:1}" in
        M) ((modified_count++));;
        D) ((deleted_count++));;
      esac
      [[ "${line:0:2}" == '??' ]] && ((untracked_count++))
    done <<< "$git_status"

    local -a parts
    (( staged_count    > 0 )) && parts+=("%F{green} $staged_count%f")
    (( modified_count  > 0 )) && parts+=("%F{yellow} $modified_count%f")
    (( deleted_count   > 0 )) && parts+=("%F{red} $deleted_count%f")
    (( untracked_count > 0 )) && parts+=("%F{magenta} $untracked_count%f")
    [[ ${#parts[@]} -gt 0 ]] && status_output+=" ${(j: :)parts}"
  else
    status_output+=" %F{green}󰗢%f"
  fi

  (( ahead_val  > 0 )) && status_output+=" %F{cyan}$ahead_val%f"
  (( behind_val > 0 )) && status_output+=" %F{magenta}$behind_val%f"

  __GIT_CACHE="$status_output"
  __GIT_CACHE_TIME=$current_time
  __GIT_CACHE_PWD="$current_pwd"
  echo "$status_output"
}
# ----------------------
#  Prompt
# ----------------------
.zshrc-prompt() {
  local exit_code=$?
  local -a top_parts

  # Exit code (if failure)
  if (( exit_code != 0 )); then
    if (( exit_code > 128 )); then
      local sig_code=$((exit_code - 128))
      local sig_name=$(kill -l $sig_code 2>/dev/null || echo "SIG$sig_code")
      if [[ "$sig_name" == "INT" ]] || [[ $sig_code -eq 2 ]]; then
        top_parts+=("%F{red}󰂭 $sig_name%f")
      else
        top_parts+=("%F{red}󱐋 $sig_name%f")
      fi
    else
      top_parts+=("%F{red}󰅚 $exit_code%f")
    fi
  fi

  # User & host
  local u_color="%F{cyan}" h_color="%F{green}" h_icon="󰒋"
  [[ "$EUID" -eq 0 ]] && { u_color="%F{red}"; u_icon="󰊼"; }
  [[ -n "$SSH_CONNECTION" ]] && { h_color="%F{magenta}"; h_icon="󰌘"; }
  top_parts+=("${u_color} %n%f %F{242}@%f ${h_color}${h_icon} %m%f")

  # Directory
  local d_color="%F{yellow}" d_icon="" dir_display="%3~"
  [[ "$PWD" == "$HOME" ]] && { d_icon="󰋜"; d_color="%F{green}"; }
  [[ "$PWD" == "/" ]] && { d_icon=""; d_color="%F{red}"; }
  [[ ! -w "$PWD" ]] && { d_icon="󰌾"; d_color="%F{red}"; }
  top_parts+=("${d_color}${d_icon} $dir_display%f")

  # Git segment (from the cleaned-up function)
  local git_info; git_info="$(.zshrc-git-status)"
  [[ -n "$git_info" ]] && top_parts+=("$git_info")

  # Build lines
  local top_line="╭─ ${(j: · :)top_parts}"
  local p_color="%F{cyan}" p_char="❯"
  [[ "$EUID" -eq 0 ]] && { p_color="%F{red}"; p_char="#"; }
  local tmux_icon=${TMUX:+"%F{blue}󰔲 %f"}

  PROMPT="${top_line}"$'\n'"╰─ ${tmux_icon}${p_color}${p_char}%f "
  RPROMPT=""   # you can later add timing or other info here
}
# ------------------------
#  Command Timing (preexec/precmd)
# ------------------------
typeset -g _CMD_START_TIME
.zshrc-timing-preexec() { _CMD_START_TIME=$EPOCHREALTIME; }
.zshrc-timing-precmd() {
  [[ -z $_CMD_START_TIME ]] && return
  local dt=$((EPOCHREALTIME - _CMD_START_TIME))
  (( dt < ZSH_TIMING_THRESHOLD )) && { unset _CMD_START_TIME; return; }

  local str icon color
  if (( dt >= 3600 )); then
    printf -v str '%.0fh %.0fm %.1fs' $((dt/3600)) $((dt%3600/60)) $((dt%60))
    icon="󰥔" color="%F{red}"
  elif (( dt >= 60 )); then
    printf -v str '%.0fm %.1fs' $((dt/60)) $((dt%60))
    icon="󱫌" color="%F{magenta}"
  elif (( dt >= 10 )); then
    printf -v str '%.1fs' $dt
    icon="󰔟" color="%F{yellow}"
  else
    printf -v str '%.2fs' $dt
    icon="󱐋" color="%F{cyan}"
  fi
  print -P "${color}${icon} Command completed in ${str}%f"
  unset _CMD_START_TIME
}

# ----------------------
#  Hooks Registration
# ----------------------
autoload -Uz add-zsh-hook
add-zsh-hook precmd .zshrc-prompt
add-zsh-hook precmd .zshrc-timing-precmd
add-zsh-hook preexec .zshrc-timing-preexec

# ----------------------
#  Personal Aliases & Extras
# ----------------------
[[ -f "$HOME/.zalias" ]] && source "$HOME/.zalias"
