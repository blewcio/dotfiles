# If we are not running interactively do not continue loading this file.
case $- in
    *i*) ;;
      *) return;;
esac

# Add sbin and bin in $HOME to $PATH (only if not already present)
_add_to_path() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) export PATH="$1:$PATH" ;;
  esac
}

_add_to_path "$HOME/bin"
_add_to_path "$HOME/sbin"
_add_to_path "$HOME/.cargo/bin"
_add_to_path "$HOME/dotfiles/bin"
unset -f _add_to_path

# Source all config files from shell config folder
SHELL_CONFIG_DIR=$HOME/dotfiles/shell.d
if [ -d "$SHELL_CONFIG_DIR" ]; then
  for shellfile in ${SHELL_CONFIG_DIR}/*.sh; do
    [ -r "$shellfile" ] && source "$shellfile"
  done
  unset shellfile
fi

# If a new remote session, start ssh as tmux, if tmux available
if [ -n "$SSH_TTY" ] && [ -z "$TMUX" ]; then
  if [ -x "$(command -v $(type -P tmux))" ]; then
    tmux attach-session -t ssh_tmux || tmux new-session -s ssh_tmux
  fi
fi

# Display cool system info (only on initial shell startup, not on re-source)
if [ -x "$(command -v fastfetch)" ] && [ -z "$SHELLRC_LOADED" ]; then
  eval fastfetch
fi

# ZSH specific config
if [[ "$SHELL" == *"zsh" ]]; then

  # If not remote, check shell integration with iTerm2
  test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

  # Load P10 for prompt customization
  # To customize prompt, run  or edit ~/.p10k.zsh.
  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
  # Surpress P10 warning before printing system info
  # typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

  # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
  # Initialization code that may require console input (password prompts, [y/n]
  # confirmations, etc.) must go above this block; everything else may go below.
  if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  fi

  # Load zsh plugin manager
  source ~/dotfiles/antigen.zsh

  # Clean up stale Antigen lock file (older than 1 hour)
  ANTIGEN_LOCK="$HOME/.antigen/.lock"
  if [ -f "$ANTIGEN_LOCK" ]; then
    # Check if lock file is older than 1 hour (3600 seconds)
    if [ $(($(date +%s) - $(stat -f %m "$ANTIGEN_LOCK" 2>/dev/null || stat -c %Y "$ANTIGEN_LOCK" 2>/dev/null))) -gt 3600 ]; then
      rm -f "$ANTIGEN_LOCK"
    fi
  fi

  # Load antigen configuration
  antigen init ~/dotfiles/.antigenrc

  # Initialize fasd (which I use bacause of file history and  v command)
  if [[ -x "$(command -v fasd)" ]] && [ -z "$FASD_INITIALIZED" ]; then
    eval "$(fasd --init posix-alias zsh-hook zsh-ccomp zsh-ccomp-install \
      zsh-wcomp zsh-wcomp-install)"
    export FASD_INITIALIZED=1
  fi

  # Start fzf (only once)
  if [ -f ~/.fzf.zsh ] && [ -z "$FZF_ZSH_INITIALIZED" ]; then
    source ~/.fzf.zsh
    if [ $? -eq 0 ]; then
      bindkey -r '^T'
      bindkey -r '^[I'
      # bindkey '^[i' fzf-file-widget
      bindkey '^[t' fzf-file-widget
      # bindkey '^T' transpose-chars # Hack: Rebind the key to default after fzf loaded
      export FZF_ZSH_INITIALIZED=1
    fi
  fi

  # Initialize zoxide (only once)
  alias z >/dev/null 2>&1 && unalias z # Vim recent file
  if [[ -x "$(command -v zoxide)" ]] && [ -z "$ZOXIDE_ZSH_INITIALIZED" ]; then
    eval "$(zoxide init zsh)"
    export ZOXIDE_ZSH_INITIALIZED=1
  fi
fi

# Bash specific config
if [[ "$SHELL" == *"bash" ]] || [[ "$SHELL" == *"/sh" ]]; then

  # FZF initialization (only once)
  if [ -z "$FZF_BASH_INITIALIZED" ]; then
    [ -f ~/.fzf.bash ] && source ~/.fzf.bash || eval "$(fzf --bash)"
    export FZF_BASH_INITIALIZED=1
  fi

  # Initialize fasd (only once)
  if [[ -x "$(command -v fasd)" ]] && [ -z "$FASD_INITIALIZED" ]; then
    eval "$(fasd --init auto)"
    alias j='fasd_cd -d'
    alias v='f -e vim'
    _fasd_bash_hook_cmd_complete
    export FASD_INITIALIZED=1
  fi

  # Initialize zoxide (only once)
  if [[ -x "$(command -v zoxide)" ]] && [ -z "$ZOXIDE_BASH_INITIALIZED" ]; then
    eval "$(zoxide init bash)"
    export ZOXIDE_BASH_INITIALIZED=1
  fi
fi

# Replace standard fasd with fzf search
if [[ -x "$(command -v fasd)" ]]; then

 # if there is fzf available use it to search fasd results
 if [[ -x "$(command -v fzf)" ]]; then

   alias v >/dev/null 2>&1 && unalias v # Vim recent file
   alias f >/dev/null 2>&1 && unalias f # Jump to directory of recent file
   alias j >/dev/null 2>&1 && unalias j # Jump to directory
   alias o >/dev/null 2>&1 && unalias o # Jump to directory

  # edit given file or search in recently used files
  function fzf_fasd_edit {
    local file
    # if arg1 is a path to existing file then simply open it in the editor
    test -e "$1" && $EDITOR "$@" && return
    # else use fasd and fzf to search for recent files
    file="$(fasd -Rfl "$*" | fzf -1 -0 --no-sort +m)" && $EDITOR "${file}" || $EDITOR "$@"
  }
  alias v=fzf_fasd_edit

  # edit given file or search in recently used files
  function fzf_fasd_open {
    local file
    # if arg1 is a path to existing file then simply open it in the editor
    test -e "$1" && open "$@" && return
    # else use fasd and fzf to search for recent files
    file="$(fasd -Rfl "$*" | fzf -1 -0 --no-sort +m)" && open "${file}" || open "$@"
  }
  alias o=fzf_fasd_open

  # cd into the directory containing a recently used file
  function fzf_fasd_last_file_dir {
    local dir
    local file
    file="$(fasd -Rfl "$*" | fzf -1 -0 --no-sort +m)" && dir=$(dirname "$file") && cd "$dir"
  }
  alias jf=fzf_fasd_last_file_dir

  # cd into given dir or search in recently used dirs
  function fzf_fasd_recent_dir {
    [ $# -eq 1 ] && test -d "$1" && cd "$1" && return
    local dir
    dir="$(fasd -Rdl "$*" | fzf -1 -0 --no-sort +m)" && cd "${dir}" || return 1
  }
  alias j=fzf_fasd_recent_dir
 fi
fi

# Initiate broot (only once)
if [ -x "$(command -v broot)" ] && [ -f ~/.config/broot/launcher/bash/br ] && [ -z "$BROOT_INITIALIZED" ]; then
    source ~/.config/broot/launcher/bash/br
    export BROOT_INITIALIZED=1
fi

# Initiate the fuck (only once)
if [ -x "$(command -v thefuck)" ] && [ -z "$THEFUCK_INITIALIZED" ]; then
    eval $(thefuck --alias)
    export THEFUCK_INITIALIZED=1
fi

# Mark shellrc as loaded
export SHELLRC_LOADED=1
