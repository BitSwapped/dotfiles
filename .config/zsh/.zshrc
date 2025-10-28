#!/usr/bin/env zsh

# ---------------------------------------------------------------------------
#  Constants
# ---------------------------------------------------------------------------
typeset -g ZSH_HIST_SIZE=200000
typeset -g ZSH_TIMING_THRESHOLD=0.5
typeset -g ZSH_GIT_CACHE_TTL=${ZSH_GIT_CACHE_TTL:-2}
typeset -g ZC_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"  # completion cache dir

# ---------------------------------------------------------------------------
#  Early Shell Options
# ---------------------------------------------------------------------------
setopt NO_BEEP COMBINING_CHARS RC_EXPAND_PARAM
setopt AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT
setopt EXTENDED_HISTORY HIST_EXPIRE_DUPS_FIRST HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS HIST_SAVE_NO_DUPS
setopt INC_APPEND_HISTORY SHARE_HISTORY

# Completion feel
setopt AUTO_LIST AUTO_MENU COMPLETE_IN_WORD ALWAYS_TO_END
setopt NO_CASE_GLOB

zle_highlight=('paste:none')
skip_global_compinit=1
DISABLE_AUTO_UPDATE=true

# ---------------------------------------------------------------------------
#  Zinit Plugin Manager
# ---------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------
#  Plugins
# ---------------------------------------------------------------------------
# Fast-syntax-highlighting (no automatic compinit; we'll run our own)
zinit ice wait"0a" lucid
zinit light-mode for zdharma-continuum/fast-syntax-highlighting

# Autosuggestions with pre-configured settings
zinit ice wait"0b" lucid atload='!_zsh_autosuggest_start' \
  atinit='ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=25;
          ZSH_AUTOSUGGEST_USE_ASYNC=true;
          ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#666666,underline";
          ZSH_AUTOSUGGEST_STRATEGY=(history completion)'
zinit light-mode for zsh-users/zsh-autosuggestions

# Completions: load synchronously so compinit sees them right away
zinit ice lucid blockf
zinit light-mode for zsh-users/zsh-completions

# OMZ libraries and plugins
zinit ice wait"1" lucid atload="bindkey -M emacs '^I' _zle_tab_accept_or_complete; bindkey -M viins '^I' _zle_tab_accept_or_complete"
zinit light-mode for OMZL::key-bindings.zsh
zinit ice wait"1" lucid
zinit light-mode for OMZL::history.zsh OMZP::sudo

# History tools
zinit ice wait"2a" lucid atload="bindkey '^r' history-search-multi-word"
zinit light-mode for zdharma-continuum/history-search-multi-word

# ---------------------------------------------------------------------------
#  Completion UI/Behavior
# ---------------------------------------------------------------------------
zmodload zsh/complist  # enables colored, interactive selection lists

# Ensure cache dir exists
[[ -d "$ZC_CACHE_DIR" ]] || command mkdir -p "$ZC_CACHE_DIR"

# Use cache
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$ZC_CACHE_DIR/zcompcache"

# Aesthetics and grouping
zstyle ':completion:*' verbose yes
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:messages'     format '%F{242}-- %d --%f'
zstyle ':completion:*:descriptions' format '%F{blue}╭─%f %F{cyan}%d%f %F{blue}─╮%f'
zstyle ':completion:*:corrections'  format '%F{green}╭─%f %F{yellow}%d%f %F{242}(errors: %e)%f %F{green}─╮%f'
zstyle ':completion:*:warnings'     format '%F{red}╭─%f No matches for: %F{yellow}%d%f %F{red}─╮%f'

# Interactive menu behavior
zstyle ':completion:*' menu select=1
zstyle ':completion:*' list-prompt '%S%F{cyan}Scroll with ←/→ or ↑/↓, Tab to move, Enter to accept (%p)%f%s'
zstyle ':completion:*' select-prompt '%S%F{cyan}%l match(es)%f %F{242}(%p)%f%s'

# Smarter matching: case-insensitive, and treat . _ - similarly; some fuzz
zstyle ':completion:*' matcher-list \
  'm:{a-z}={A-Z}' \
  '+r:|[._-]=* r:|=*' \
  '+l:|=* r:|=*'

# Completers and quality-of-life
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:approximate:*' max-errors 2 numeric
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' accept-exact '*(N)'

# Make cd feel better and source complete files nicely
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# Don’t auto-accept exact matches or add a space for source and .
zstyle ':completion:*:source:*' accept-exact false
zstyle ':completion:*:.:*'      accept-exact false
zstyle ':completion:*:source:*' add-space false
zstyle ':completion:*:.:*'      add-space false

# ---------------------------------------------------------------------------
#  Ensure completion is loaded
# ---------------------------------------------------------------------------
typeset -g _COMPS_INITIALIZED=0
autoload -Uz compinit
.zshrc-compinit() {
  [[ $_COMPS_INITIALIZED -eq 1 ]] && return
  _COMPS_INITIALIZED=1

  local dump_file="$ZC_CACHE_DIR/zcompdump"
  local needs_rebuild=0

  if [[ ! -f "$dump_file" ]]; then
    needs_rebuild=1
  else
    for compdir in $fpath; do
      if [[ "$compdir" -nt "$dump_file" ]]; then
        needs_rebuild=1
        break
      fi
    done
  fi

  if (( needs_rebuild )); then
    compinit -i -d "$dump_file"
  else
    compinit -C -i -d "$dump_file"
  fi
}
.zshrc-compinit

# ---------------------------------------------------------------------------
#  History Configuration
# ---------------------------------------------------------------------------
HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/history"
[[ ! -d "$(dirname "$HISTFILE")" ]] && command mkdir -p "$(dirname "$HISTFILE")"
HISTSIZE=$ZSH_HIST_SIZE
SAVEHIST=$ZSH_HIST_SIZE

# ---------------------------------------------------------------------------
#  Autosuggestion Tuning
# ---------------------------------------------------------------------------
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=25
ZSH_AUTOSUGGEST_USE_ASYNC=true
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#666666,underline"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# ---------------------------------------------------------------------------
#  Git Prompt
# ---------------------------------------------------------------------------
typeset -g __GIT_CACHE=""
typeset -g __GIT_CACHE_TIME=0
typeset -g __GIT_CACHE_PWD=""

.zshrc-git-status() {
  local current_time=$EPOCHSECONDS current_pwd="$PWD"
  if [[ "$current_pwd" == "$__GIT_CACHE_PWD" ]] && (( current_time - __GIT_CACHE_TIME < ZSH_GIT_CACHE_TTL )); then
    echo -r -- "$__GIT_CACHE"
    return
  fi

  command git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    __GIT_CACHE=""
    __GIT_CACHE_TIME=$current_time
    __GIT_CACHE_PWD="$current_pwd"
    return
  }

  local branch status_output
  branch=$(command git symbolic-ref --quiet --short HEAD 2>/dev/null) \
    || branch=$(command git describe --tags --exact-match 2>/dev/null) \
    || branch=$(command git rev-parse --short HEAD 2>/dev/null) \
    || branch="detached"

  status_output="%F{242}on%f %F{cyan} $branch%f"

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
    (( staged_count    > 0 )) && parts+=("%F{green} $staged_count%f")
    (( modified_count  > 0 )) && parts+=("%F{yellow} $modified_count%f")
    (( deleted_count   > 0 )) && parts+=("%F{red} $deleted_count%f")
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
  echo -r -- "$status_output"
}

# ---------------------------------------------------------------------------
#  Prompt
# ---------------------------------------------------------------------------
.zshrc-prompt() {
  local exit_code=$?
  local -a prompt_elements

  # 1. Exit Code Segment
  if (( exit_code != 0 )); then
    if (( exit_code > 128 )); then
      local sig_code=$((exit_code - 128))
      local sig_name=$(kill -l $sig_code 2>/dev/null || echo "SIG$sig_code")
      if [[ "$sig_name" == "INT" ]] || [[ $sig_code -eq 2 ]]; then
        prompt_elements+=("%F{red}󰂭 $sig_name%f")
      else
        prompt_elements+=("%F{red}󱐋 $sig_name%f")
      fi
    else
      prompt_elements+=("%F{red}󰅚 $exit_code%f")
    fi
  fi

  # 2. User/Host/Directory Segment
  local u_color="%F{cyan}" h_color="%F{green}" d_color="%F{yellow}"
  local u_icon="" h_icon="󰒋" d_icon=""
  [[ "$EUID" -eq 0 ]] && { u_color="%F{red}"; u_icon="󰊼"; }
  [[ -n "$SSH_CONNECTION" ]] && { h_color="%F{magenta}"; h_icon="󰌘"; }

  local dir_display="%3~"
  [[ "$PWD" == "$HOME" ]] && { d_icon="󰋜"; d_color="%F{green}"; }
  [[ "$PWD" == "/" ]] && { d_icon=""; d_color="%F{red}"; }
  [[ ! -w "$PWD" ]] && { d_icon="󰌾"; d_color="%F{red}"; }
  prompt_elements+=("${u_color}${u_icon} %n%f %F{242}@%f ${h_color}${h_icon} %m%f ${d_color}${d_icon} $dir_display%f")

  # 3. Git Segment (use our function with counts)
  local git_info; git_info="$(.zshrc-git-status)"
  [[ -n "$git_info" ]] && prompt_elements+=("$git_info")

  # 4. Prompt Character
  local p_color="%F{cyan}" p_char="❯"
  [[ "$EUID" -eq 0 ]] && { p_color="%F{red}"; p_char="#"; }
  local tmux_icon=${TMUX:+"%F{blue}󰔲 %f"}

  PROMPT="${(j: :)prompt_elements}"$'\n'"${tmux_icon}${p_color}${p_char}%f "
  RPROMPT=""
}

# ---------------------------------------------------------------------------
#  Command Timing
# ---------------------------------------------------------------------------
typeset -g _CMD_START_TIME
.zshrc-timing-preexec() { _CMD_START_TIME=$EPOCHREALTIME; }
.zshrc-timing-precmd() {
  [[ -z $_CMD_START_TIME ]] && return
  local dt=$((EPOCHREALTIME - _CMD_START_TIME))
  (( dt < ZSH_TIMING_THRESHOLD )) && { unset _CMD_START_TIME; return; }

  local str icon color
  if (( dt >= 3600 )); then
    echof -v str '%.0fh %.0fm %.1fs' $((dt/3600)) $((dt%3600/60)) $((dt%60))
    icon="󰥔" color="%F{red}"
  elif (( dt >= 60 )); then
    echof -v str '%.0fm %.1fs' $((dt/60)) $((dt%60))
    icon="󰥐" color="%F{magenta}"
  elif (( dt >= 10 )); then
    echof -v str '%.1fs' $dt
    icon="󰔟" color="%F{yellow}"
  else
    echof -v str '%.2fs' $dt
    icon="⚡" color="%F{cyan}"
  fi
  print -P "${color}${icon} Command completed in ${str}%f"
  unset _CMD_START_TIME
}

# ---------------------------------------------------------------------------
#  External Integrations
# ---------------------------------------------------------------------------
if (( $+commands[zoxide] )); then
  eval "$(zoxide init --cmd cd zsh)"
fi

# ---------------------------------------------------------------------------
#  Hook Registration
# ---------------------------------------------------------------------------
autoload -Uz add-zsh-hook
add-zsh-hook precmd .zshrc-prompt
add-zsh-hook precmd .zshrc-timing-precmd
add-zsh-hook preexec .zshrc-timing-preexec

# ---------------------------------------------------------------------------
#  Personal Aliases & Config
# ---------------------------------------------------------------------------
[[ -f "$HOME/.zalias" ]] && source "$HOME/.zalias"
