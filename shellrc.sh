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

# Track SSH nesting depth to prevent tmux auto-attach in nested SSH sessions
export SSH_DEPTH=${SSH_DEPTH:-0}
export SSH_DEPTH=$((SSH_DEPTH + 1))

# If a new remote session, start ssh as tmux (only on first SSH hop)
if [ -n "$SSH_TTY" ] && [ -z "$TMUX" ] && [ -z "$TMUX_PANE" ] && [ "$SSH_DEPTH" -eq 1 ]; then
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

  # Configure zsh-autosuggestions styling (before loading plugins)
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'        # Gray color (240 = dark gray)
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)   # Use both history and completion

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

  # Custom widgets for visual selection with Shift+arrows

  # Shift+Left: select backward by character
  select-backward-char() {
    ((REGION_ACTIVE)) || zle set-mark-command
    zle backward-char
  }
  zle -N select-backward-char

  # Shift+Right: select forward by character
  select-forward-char() {
    ((REGION_ACTIVE)) || zle set-mark-command
    zle forward-char
  }
  zle -N select-forward-char

  # Shift+Up: select entire line
  select-entire-line() {
    zle beginning-of-line
    zle set-mark-command
    zle end-of-line
  }
  zle -N select-entire-line

  # Shift+Down: deselect and move to end of line
  deselect-region() {
    # Exit visual mode by toggling mark off
    if ((REGION_ACTIVE)); then
      zle set-mark-command
    fi
    # Move cursor to end of line
    zle end-of-line
  }
  zle -N deselect-region

  # Shift+Alt+Left: select backward by word
  select-backward-word() {
    ((REGION_ACTIVE)) || zle set-mark-command
    zle backward-word
  }
  zle -N select-backward-word

  # Shift+Alt+Right: select forward by word
  select-forward-word() {
    ((REGION_ACTIVE)) || zle set-mark-command
    zle forward-word
  }
  zle -N select-forward-word

  # Configure autocomplete
  zstyle ':autocomplete:*' min-delay 0.5  # seconds (float)
  zstyle ':autocomplete:*' min-input 2     # characters
  zstyle ':autocomplete:*' insert-unambiguous yes # Insert common prefix automatically
  zstyle ':autocomplete:*' widget-style menu-select
  bindkey '^I' menu-complete


  # Configure keybindings after zsh-autocomplete loads
  # This function runs after zle is initialized to ensure bindings persist
  _fix_autocomplete_bindings() {
    if (( $+functions[.autocomplete:async:start] )); then
      # Tab: Use menu-complete for cycling through completions
      # bindkey              '^I'         menu-complete
      # bindkey              '^I'         fzf_completion
      
      # Shift+Tab: Reverse menu-complete
      bindkey "$terminfo[kcbt]" reverse-menu-complete

      # Ctrl+S: Different behavior based on context
      bindkey              '^S'         history-incremental-search-forward  # Command line: history search
      bindkey -M menuselect '^S'        history-incremental-search-forward  # In menu: search menu items

      # Ctrl+R: FZF history widget (overrides autocomplete's Ctrl+R)
      bindkey              '^R'         fzf-history-widget

      # Restore default Up/Down arrow behavior (undo zsh-autocomplete bindings)
      bindkey              '^[[A'       up-line-or-history      # Up arrow
      bindkey              '^[OA'       up-line-or-history      # Up arrow (alternative)
      bindkey              '^[[B'       down-line-or-history    # Down arrow
      bindkey              '^[OB'       down-line-or-history    # Down arrow (alternative)


    fi
  }

  # Run after zle initialization to override plugin defaults
  autoload -Uz add-zle-hook-widget
  add-zle-hook-widget zle-line-init _fix_autocomplete_bindings

  # Override zsh-autocomplete's recent directories with fasd/zoxide
  +autocomplete:recent-directories() {
    if (( $+commands[zoxide] )); then
      # Use zoxide for recent directories (sorted by frecency)
      typeset -ga reply=( ${(f)"$(zoxide query --list 2>/dev/null)"} )
    elif (( $+commands[fasd] )); then
      # Fallback to fasd for recent directories
      typeset -ga reply=( ${(f)"$(fasd -dl 2>/dev/null)"} )
    else
      # Fallback to empty array if neither is available
      typeset -ga reply=()
    fi
  }

  # Key bindings for text selection
  bindkey '^[[1;2D'    select-backward-char      # Shift+Left: select left by char
  bindkey '^[[1;2C'    select-forward-char       # Shift+Right: select right by char
  bindkey '^[[1;2A'    select-entire-line        # Shift+Up: select entire line
  bindkey '^[[1;2B'    deselect-region           # Shift+Down: deselect
  bindkey '^[[1;4D'    select-backward-word      # Shift+Alt+Left: select left by word
  bindkey '^[[1;4C'    select-forward-word       # Shift+Alt+Right: select right by word
  bindkey '^[[1;4A'    select-entire-line        # Shift+Alt+Up: select entire line
  bindkey '^[[1;4B'    select-entire-line        # Shift+Alt+Down: select entire line

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
      bindkey -r '^[I'
      # bindkey '^[i' fzf-file-widget
      bindkey '^T' fzf-file-widget
      export FZF_ZSH_INITIALIZED=1
    fi
  fi

  # Initialize zoxide (only once)
  unalias z 2>/dev/null || true  # Remove z alias if it exists
  if [[ -x "$(command -v zoxide)" ]] && [ -z "$ZOXIDE_ZSH_INITIALIZED" ]; then
    eval "$(zoxide init zsh)"
    export ZOXIDE_ZSH_INITIALIZED=1
  fi
fi

# Bash specific config
if [[ "$SHELL" == *"bash" ]] || [[ "$SHELL" == *"/sh" ]]; then

  # Initialize ble.sh (Bash Line Editor) for autosuggestions and syntax highlighting
  # Must be loaded early to properly intercept shell input
  if [ -f ~/.local/share/blesh/ble.sh ] && [ -z "$BLESH_INITIALIZED" ]; then
    # Load bash-completion if available (only once)
    source ~/.local/share/blesh/ble.sh
    export BLESH_INITIALIZED=1
    
    # Transient prompt appearance  after prompt
    bleopt prompt_ps1_transient=always
    bleopt prompt_ps1_final='\e[33m[\t] \w \$ \e[m'
    # History-based autosuggestions (very popular feature)
    bleopt history_share=1
    # Use grey for completion of lines
    ble-face auto_complete='fg=gray'
    # For autocompletion dropdown use system colors
    bleopt filename_ls_colors="$LS_COLORS"
    # Run commands in multiline mode with Enter
    ble-bind -m emacs -f 'C-m' 'accept-line'
    ble-bind -m emacs -f 'RET' 'accept-line'
    # Bind "C-x C-v" for Emacs mode
    ble-bind -m emacs -f 'C-x C-v' 'edit-and-execute-command'
    # Turn off the exit status mark [ble: exit ???]
    bleopt exec_errexit_mark=
    # Slow down auto complete while typing
    bleopt complete_auto_delay=200

    # Disable menu completions (keep auto-suggestions)
    bleopt complete_ambiguous=
    bleopt complete_menu_complete=
    bleopt complete_menu_filter=

    # Common color customizations
    ble-face -s command_builtin fg=cyan
    ble-face -s command_alias fg=green
    ble-face region='bg=60,fg=white'
    ble-face region_target='bg=153,fg=black'
    ble-face syntax_command='fg=brown'
    ble-face syntax_quoted='fg=green'
    ble-face syntax_error='bg=203,fg=231'
    ble-face command_function='fg=92'
    ble-face argument_option='fg=teal'

    #Vim mode
    set -o vi
    # Vim-surround functionality
    blehook keymap_vi_load='ble-import vim-surround'
  fi

  if [ -z "$BASH_COMPLETION_INITIALIZED" ]; then
    # macOS (Homebrew)
    if command -v brew >/dev/null 2>&1; then
      local brew_prefix=$(brew --prefix)
      if [ -f "$brew_prefix/etc/profile.d/bash_completion.sh" ]; then
        source "$brew_prefix/etc/profile.d/bash_completion.sh"
        export BASH_COMPLETION_INITIALIZED=1
      fi
    # Linux
    elif [ -f /usr/share/bash-completion/bash_completion ]; then
      source /usr/share/bash-completion/bash_completion
      export BASH_COMPLETION_INITIALIZED=1
    elif [ -f /etc/bash_completion ]; then
      source /etc/bash_completion
      export BASH_COMPLETION_INITIALIZED=1
    fi
  fi

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

   # Remove any existing aliases (suppress errors if they don't exist)
   unalias v 2>/dev/null || true
   unalias f 2>/dev/null || true
   unalias j 2>/dev/null || true
   unalias o 2>/dev/null || true

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
