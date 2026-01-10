# Make directories in $HOME accessible from everywhere
export CDPATH=$CDPATH:.:$HOME

# Ensure English is primary terminal language
export LANG=en_US.UTF-8

# Editor variables
VIM=/usr/bin/vim
if [ -e "$VIM" ]; then
 export EDITOR="$VIM"
 export VISUAL="$VIM"
fi

# Add sbin and bin in $HOME `$PATH`
export PATH="$HOME/bin:$HOME/sbin:$PATH"

# Make Python use UTF-8 encoding for output to stdin, stdout, and stderr.
export PYTHONIOENCODING='UTF-8';

# Configure FZF
if [ -v FZF_CTRL_T_COMMAND ]; then

  # Global FZF defaults - styling, layout, and keybindings
  # Catppuccin Mocha theme colors
  export FZF_DEFAULT_OPTS="
    --height=40%
    --layout=reverse
    --border=rounded
    --info=inline
    --margin=1
    --padding=1
    --bind 'ctrl-/:toggle-preview'
    --bind 'ctrl-a:select-all'
    --bind 'ctrl-d:preview-page-down'
    --bind 'ctrl-u:preview-page-up'
    --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
    --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
    --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
    --color=border:#6c7086"

  # Replace filesearch with fd if installed
  # Uses --hidden to find dotfiles, --follow to traverse symlinks
  if command -v fd &> /dev/null; then
    export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
    export FZF_CTRL_T_COMMAND="fd --type f --hidden --follow --exclude .git"
    export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"
  fi

  # Preview file content using bat (https://github.com/sharkdp/bat)
  if command -v bat &> /dev/null; then
    export FZF_CTRL_T_OPTS="
    --preview 'bat -n --color=always {}'"
  fi

  # CTRL-/ to toggle small preview window to see the full command
  # CTRL-Y to copy the command into clipboard using pbcopy
  export FZF_CTRL_R_OPTS="
  --preview 'echo {}' --preview-window up:3:hidden:wrap
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"

  # Print tree structure in the preview window (limited depth for performance)
  export FZF_ALT_C_OPTS="--preview 'tree -C -L 2 {}'"
fi

if [[ "$(uname)" == "Darwin"  ]]; then
  #Add frequently used directories
  export DESKTOP="$HOME/Desktop"
  export DOWNLOADS="$HOME/Downloads"
fi

# nnn config
if [[ -x "$(command -v nnn)" ]]; then
  export NNN_PLUG='f:fzcd;o:fzopen;d:diffs;2:dups;c:cdpath'
  export NNN_BMS="d:$HOME/Download;h:$HOME;v:/Volumes"
fi
