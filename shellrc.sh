# If we are not running interactively do not continue loading this file.
case $- in
    *i*) ;;
      *) return;;
esac

# Define conditional helper for Antidote (used in zsh_plugins.txt)
is-macos() { [[ "$OSTYPE" == darwin* ]] }

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

# Local homebrew configuration
if is-macos; then
  BREWDIR="$HOME/.homebrew"
  if [ -d "$BREWDIR" ]; then 
    # Add homebrew bin to path
    _add_to_path "$BREWDIR/bin"
    # Keep Casks in your user Applications folder
    export HOMEBREW_CASK_OPTS="--appdir=~/Applications"
  fi
fi

# Source all config files from shell config folder
SHELL_CONFIG_DIR=$HOME/dotfiles/shell.d
if [ -d "$SHELL_CONFIG_DIR" ]; then
  for shellfile in ${SHELL_CONFIG_DIR}/*.sh; do
    [ -r "$shellfile" ] && source "$shellfile"
  done
  unset shellfile
fi

# Source private configuration (git submodule)
PRIVATE_SHELL_DIR=$HOME/dotfiles/private/shell
if [ -d "$PRIVATE_SHELL_DIR" ]; then
  for shellfile in ${PRIVATE_SHELL_DIR}/*.sh; do
    [ -r "$shellfile" ] && source "$shellfile"
  done
  unset shellfile
fi
unset PRIVATE_SHELL_DIR

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

  # Initialize direnv before P10k instant prompt to prevent console output warnings
  # Direnv must load early to hook directory changes, but we silence its output
  if command -v direnv >/dev/null 2>&1; then
    export DIRENV_LOG_FORMAT=  # Silence direnv output
    eval "$(direnv hook zsh)"
  fi

  # Suppress instant prompt console output warnings (recommended by P10k)
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

  # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
  # Initialization code that may require console input (password prompts, [y/n]
  # confirmations, etc.) must go above this block; everything else may go below.
  if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  fi
 
  # Configure zsh-autosuggestions styling (before loading plugins)
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'        # Gray color (240 = dark gray)
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)   # Use both history and completion

  # Load Catppuccin FZF theme (must be before fzf initialization)
  catppuccin_fzf="${HOME}/dotfiles/config/zsh/catppuccin-fzf.zsh"
  [[ -r "$catppuccin_fzf" ]] && source "$catppuccin_fzf"
  unset catppuccin_fzf

  # Define zvm_after_init hook for zsh-vi-mode
  # This function runs after zsh-vi-mode initializes to set up other plugin keybindings
  # that would otherwise be overridden by vi-mode
  zvm_after_init() {
    # Bind up/down arrows for zsh-history-substring-search
    bindkey '^[[A' history-substring-search-up      # Up arrow
    bindkey '^[[B' history-substring-search-down    # Down arrow
    bindkey "$terminfo[kcuu1]" history-substring-search-up    # Up arrow (terminfo)
    bindkey "$terminfo[kcud1]" history-substring-search-down  # Down arrow (terminfo)

    # In vi mode, also bind k/j in command mode for history search
    bindkey -M vicmd 'k' history-substring-search-up
    bindkey -M vicmd 'j' history-substring-search-down

    # Restore fzf keybindings (overridden by zsh-vi-mode)
    bindkey '^R' fzf-history-widget      # Ctrl-R: fzf history search
    bindkey '^T' fzf-file-widget         # Ctrl-T: fzf file search
    bindkey '^[c' fzf-cd-widget          # Alt-C: fzf directory search
  }

  # Load Antidote plugin manager
  if [ -f "${HOME}/.antidote/antidote.zsh" ]; then
    source "${HOME}/.antidote/antidote.zsh"

    # Initialize plugins (includes Powerlevel10k and Catppuccin P10k themes)
    zsh_plugins="${HOME}/.zsh_plugins.txt"
    if [ -f "$zsh_plugins" ]; then
      # Load static file if exists (faster), otherwise generate it
      antidote load "$zsh_plugins"
    fi
    unset zsh_plugins

    # Apply Catppuccin Mocha theme to Powerlevel10k
    # Options: lean, classic, rainbow, pure, robbyrussell
    # Flavors: latte, frappe, macchiato, mocha
    if typeset -f apply_catppuccin > /dev/null; then
      apply_catppuccin pure mocha  # Using 'pure' style (single-line) with 'mocha' flavor
    fi

    # Apply Catppuccin Mocha theme to fast-syntax-highlighting
    # First copy theme files to XDG config location if not already there
    if [ -d "${HOME}/.antidote/https-COLON--SLASH--SLASH-github.com-SLASH-catppuccin-SLASH-zsh-fsh/themes" ]; then
      local fsh_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/fsh"
      mkdir -p "$fsh_config_dir"
      # Copy all Catppuccin theme files if not present
      if [ ! -f "$fsh_config_dir/catppuccin-mocha.ini" ]; then
        cp -n "${HOME}/.antidote/https-COLON--SLASH--SLASH-github.com-SLASH-catppuccin-SLASH-zsh-fsh/themes/"*.ini "$fsh_config_dir/" 2>/dev/null || true
      fi
      # Activate Mocha theme (options: catppuccin-latte, catppuccin-frappe, catppuccin-macchiato, catppuccin-mocha)
      fast-theme XDG:catppuccin-mocha 2>/dev/null || true
    fi

    # Configure menuselect keymap (completion menu navigation)
    # Note: These bindings are optional and will be applied once completion menu is used
    # Errors are suppressed as the keymap is created on-demand by the completion system
    {
      bindkey -M menuselect '^I' menu-complete
      bindkey -M menuselect "$terminfo[kcbt]" reverse-menu-complete
      bindkey -M menuselect '^M' .accept-line
    } 2>/dev/null
  fi

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

  # Key bindings for text selection
  bindkey '^[[1;2D'    select-backward-char      # Shift+Left: select left by char
  bindkey '^[[1;2C'    select-forward-char       # Shift+Right: select right by char
  bindkey '^[[1;2A'    select-entire-line        # Shift+Up: select entire line
  bindkey '^[[1;2B'    deselect-region           # Shift+Down: deselect
  bindkey '^[[1;4D'    select-backward-word      # Shift+Alt+Left: select left by word
  bindkey '^[[1;4C'    select-forward-word       # Shift+Alt+Right: select right by word
  bindkey '^[[1;4A'    select-entire-line        # Shift+Alt+Up: select entire line
  bindkey '^[[1;4B'    select-entire-line        # Shift+Alt+Down: select entire line

  # Keybindings for zsh-autocomplete and completion
  bindkey '^I' menu-complete                       # Tab: complete then cycle through menu
  bindkey "$terminfo[kcbt]" reverse-menu-complete  # Shift+Tab: reverse completion
  bindkey '^S' history-incremental-search-forward  # Ctrl+S: forward history search

  # Initialize fasd (which I use bacause of file history and  v command)
  if [[ -x "$(command -v fasd)" ]] && [ -z "$FASD_INITIALIZED" ]; then
    eval "$(fasd --init posix-alias zsh-hook zsh-ccomp zsh-ccomp-install \
      zsh-wcomp zsh-wcomp-install)"
    export FASD_INITIALIZED=1
  fi

  # Initialize zoxide (only once)
  unalias z 2>/dev/null || true  # Remove z alias if it exists
  if [[ -x "$(command -v zoxide)" ]] && [ -z "$ZOXIDE_ZSH_INITIALIZED" ]; then
    eval "$(zoxide init zsh)"
    export ZOXIDE_ZSH_INITIALIZED=1
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

  # open given file or search in recently used files (cross-platform)
  function fzf_fasd_open {
    local file opener
    # Use open on macOS, xdg-open on Linux
    [[ "$(uname)" == "Darwin" ]] && opener="open" || opener="xdg-open"
    # if arg1 is a path to existing file then simply open it
    test -e "$1" && $opener "$@" && return
    # else use fasd and fzf to search for recent files
    file="$(fasd -Rfl "$*" | fzf -1 -0 --no-sort +m)" && $opener "${file}" || $opener "$@"
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

unset -f _add_to_path
