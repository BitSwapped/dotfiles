#!/usr/bin/env zsh

# ---------------------------------------------------------------------------
#  Constants
# ---------------------------------------------------------------------------
typeset -g ZSH_HIST_SIZE=200000
typeset -g ZSH_GIT_CACHE_TTL=3
typeset -g ZSH_TIMING_THRESHOLD=0.5

# ---------------------------------------------------------------------------
#  Early Shell Options 
# ---------------------------------------------------------------------------
setopt NO_BEEP COMBINING_CHARS RC_EXPAND_PARAM
setopt AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT
setopt EXTENDED_HISTORY HIST_EXPIRE_DUPS_FIRST HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS HIST_SAVE_NO_DUPS
setopt INC_APPEND_HISTORY SHARE_HISTORY
zle_highlight=('paste:none')
skip_global_compinit=1
DISABLE_AUTO_UPDATE=true

# ---------------------------------------------------------------------------
#  Zinit Plugin Manager 
# ---------------------------------------------------------------------------
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
  command print -P "%F{blue}󰑓 Installing Zinit...%f"
  command mkdir -p "$(dirname "$ZINIT_HOME")"
  if command git clone --depth=1 --quiet https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME" 2>/dev/null; then
    command print -P "%F{green}󰗢 Zinit installed successfully.%f"
  else
    command print -P "%F{red}󰗴 Failed to install Zinit.%f"
    return 1
  fi
fi
source "${ZINIT_HOME}/zinit.zsh"

# ---------------------------------------------------------------------------
#  Plugins
# ---------------------------------------------------------------------------
zinit ice wait"0" lucid atload='.zshrc-compinit'
zinit light-mode for zdharma-continuum/fast-syntax-highlighting

zinit ice wait"1" lucid atload='!_zsh_autosuggest_start'
zinit light-mode for zsh-users/zsh-autosuggestions

zinit ice wait"1" lucid
zinit light-mode for zsh-users/zsh-completions

# OMZ libraries are loaded directly; light-mode is not applicable here.
zinit ice wait"1" lucid for \
    OMZL::key-bindings.zsh \
    OMZL::history.zsh \
    OMZP::git \
    OMZP::sudo

zinit ice wait"2" lucid atload="bindkey '^r' history-search-multi-word"
zinit light-mode for zdharma-continuum/history-search-multi-word

zinit ice wait"2" lucid
zinit light-mode for zsh-users/zsh-history-substring-search

# ---------------------------------------------------------------------------
#  Completions 
# ---------------------------------------------------------------------------
typeset -g _COMPS_INITIALIZED=0
.zshrc-compinit() {
    [[ $_COMPS_INITIALIZED -eq 1 ]] && return
    _COMPS_INITIALIZED=1

    autoload -Uz compinit
    local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
    local dump_file="$cache_dir/zcompdump"
    [[ ! -d "$cache_dir" ]] && command mkdir -p "$cache_dir"

    # Smarter rebuild: Check if the dump file is older than any fpath dir.
    # This triggers a rebuild only when new completions are actually installed.
    local needs_rebuild=0
    if [[ ! -f "$dump_file" ]]; then
        needs_rebuild=1
    else
        # Loop through completion directories
        for compdir in $fpath; do
            # If a directory is newer than the dump file, we need to rebuild
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

    zstyle ':completion:*' use-cache yes
    zstyle ':completion:*' cache-path "$cache_dir/zcompcache"
    zstyle ':completion:*' menu select=2
    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
    zstyle ':completion:*' group-name ''
    zstyle ':completion:*' verbose yes
    zstyle ':completion:*:descriptions' format '%F{blue}╭─%f %F{cyan}%d%f %F{blue}─╮%f'
    zstyle ':completion:*:corrections' format '%F{green}╭─%f %F{yellow}%d%f %F{242}(errors: %e)%f %F{green}─╮%f'
    zstyle ':completion:*:warnings' format '%F{red}╭─%f No matches for: %F{yellow}%d%f %F{red}─╮%f'
    zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
    zstyle ':completion:*' completer _complete _match _approximate
    zstyle ':completion:*:approximate:*' max-errors 2 numeric
}

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
        print -r -- "$__GIT_CACHE"
        return
    fi

    # Exit early if not in a git repo
    command git rev-parse --git-dir >/dev/null 2>&1 || {
        __GIT_CACHE=""
        __GIT_CACHE_TIME=$current_time
        __GIT_CACHE_PWD="$current_pwd"
        return
    }

    local branch status_output
    branch=$(command git symbolic-ref --short HEAD 2>/dev/null) || \
    branch=$(command git describe --tags --exact-match 2>/dev/null) || \
    branch=$(command git rev-parse --short HEAD 2>/dev/null) || \
    branch="detached"

    if [[ -n "$branch" ]]; then
        status_output="%F{242}on%f %F{cyan} $branch%f"
        local git_status=$(command git status --porcelain=v1 2>/dev/null)
        local ahead_behind=$(command git rev-list --count --left-right '@{upstream}...HEAD' 2>/dev/null)
        local behind_val=${ahead_behind%%$'\t'*}
        local ahead_val=${ahead_behind##*$'\t'}

        if [[ -n "$git_status" ]]; then
            local staged_count=0 modified_count=0 untracked_count=0 deleted_count=0
            while IFS= read -r line; do
                case "${line:0:2}" in
                    M*) ((staged_count++));;
                    A*) ((staged_count++));;
                    D*) ((staged_count++));;
                    R*) ((staged_count++));;
                    C*) ((staged_count++));;
                 esac
                 case "${line:1:1}" in
                    M) ((modified_count++));;
                    D) ((deleted_count++));;
                 esac
                 case "${line:0:2}" in
                    '??') ((untracked_count++));;
                 esac
            done <<< "$git_status"

            local -a parts
            (( staged_count > 0 ))    && parts+=("%F{green} $staged_count%f")
            (( modified_count > 0 )) && parts+=("%F{yellow} $modified_count%f")
            (( deleted_count > 0 ))  && parts+=("%F{red} $deleted_count%f")
            (( untracked_count > 0 ))&& parts+=("%F{magenta} $untracked_count%f")
            [[ ${#parts[@]} -gt 0 ]] && status_output+=" ${(j: :)parts}"
        else
            status_output+=" %F{green}󰗢%f" # Clean
        fi

        (( ahead_val > 0 )) && status_output+=" %F{cyan}$ahead_val%f"
        (( behind_val > 0 )) && status_output+=" %F{magenta}$behind_val%f"
    fi

    __GIT_CACHE="$status_output"
    __GIT_CACHE_TIME=$current_time
    __GIT_CACHE_PWD="$current_pwd"
    print -r -- "$status_output"
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
            # Ctrl+C is special
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

    # 3. Git Segment
    local git_info="$(.zshrc-git-status)"
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
        printf -v str '%.0fh %.0fm %.1fs' $((dt/3600)) $((dt%3600/60)) $((dt%60))
        icon="󰥔" color="%F{red}"
    elif (( dt >= 60 )); then
        printf -v str '%.0fm %.1fs' $((dt/60)) $((dt%60))
        icon="󰥐" color="%F{magenta}"
    elif (( dt >= 10 )); then
        printf -v str '%.1fs' $dt
        icon="󰔟" color="%F{yellow}"
    else
        printf -v str '%.2fs' $dt
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

# Source optional personal files silently
for file in "$HOME/.zalias" "$HOME/.zprofile" "$HOME/.zshenv"; do
    [[ -f "$file" ]] && source "$file"
done

