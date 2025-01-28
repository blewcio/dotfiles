# If we are not running interactively do not continue loading this file.
case $- in
    *i*) ;;
      *) return;;
esac

# Add sbin and bin in $HOME `$PATH`
export PATH="$HOME/bin:$HOME/sbin:$PATH"
export PATH="$HOME/.cargo/bin":$PATH

# Source all config files from shell config folder
SHELL_CONFIG_DIR=$HOME/dotfiles/shell.d
if [ -x $SHELL_CONFIG_DIR ]; then
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

# Display cool system info
if [ -x "$(command -v fastfetch)" ]; then
  eval fastfetch
fi

# ZSH specific config
if [[ "$SHELL" == *"zsh" ]]; then

  # If not remote, check shell integration with iTerm2
  test -e "~/.iterm2_shell_integration.zsh" && source "/Users/blazej.lewcio/.iterm2_shell_integration.zsh"

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

  # Load antigen configuration
  antigen init ~/dotfiles/.antigenrc

  # Initialize fasd (which I use bacause of file history and  v command)
  eval "$(fasd --init posix-alias zsh-hook zsh-ccomp zsh-ccomp-install \
    zsh-wcomp zsh-wcomp-install)"

  # Start fzf
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
  if [ $? -eq 0 ]; then
    bindkey -r '^T'
    bindkey -r '^[I'
    bindkey '^[i' fzf-file-widget
    bindkey '^T' transpose-chars # Hack: Rebind the key to default after fzf loaded
  fi

  # Initialize zoxide. To use it in yazi.
  alias z >/dev/null && unalias z # Vim recent file
  if [[ -x "$(command -v zoxide)" ]]; then
    eval "$(zoxide init zsh)"
  fi
fi

# Bash specific config
if [[ "$SHELL" == *"bash" ]] || [[ "$SHELL" == *"/sh" ]]; then

  [ -f ~/.fzf.bash ] && source ~/.fzf.bash

  if [[ -x "$(command -v fasd)" ]]; then
    eval "$(fasd --init auto)"
    alias j='fasd_cd -d'
    alias v='f -e vim'
    _fasd_bash_hook_cmd_complete
  fi

  # Initialize zoxide. To use it in yazi.
  if [[ -x "$(command -v zoxide)" ]]; then
    eval "$(zoxide init bash)"
  fi
fi

# Replace standard fasd with fzf search
if [[ -x "$(command -v fasd)" ]]; then

 # if there is fzf available use it to search fasd results
 if [[ -x "$(command -v fzf)" ]]; then

   alias v >/dev/null && unalias v # Vim recent file
   alias f >/dev/null && unalias f # Jump to directory of recent file
   alias j >/dev/null && unalias j # Jump to directory

  # edit given file or search in recently used files
  function v {
    local file
    # if arg1 is a path to existing file then simply open it in the editor
    test -e "$1" && $EDITOR "$@" && return
    # else use fasd and fzf to search for recent files
    file="$(fasd -Rfl "$*" | fzf -1 -0 --no-sort +m)" && $EDITOR "${file}" || $EDITOR "$@"
  }

  # cd into the directory containing a recently used file
  function f {
    local dir
    local file
    file="$(fasd -Rfl "$*" | fzf -1 -0 --no-sort +m)" && dir=$(dirname "$file") && cd "$dir"
  }

  # cd into given dir or search in recently used dirs
  function j {
    [ $# -eq 1 ] && test -d "$1" && cd "$1" && return
    local dir
    dir="$(fasd -Rdl "$*" | fzf -1 -0 --no-sort +m)" && cd "${dir}" || return 1
  }
 fi
fi

# Initiate broot
if [ -x "$(command -v broot)" ]; then
    source ~/.config/broot/launcher/bash/br
fi

# Initiate the fuck
if [ -x "$(command -v thefuck)" ]; then
    eval $(thefuck --alias)
fi
