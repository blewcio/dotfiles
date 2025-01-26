# Make directories in $HOME accessible from everywhere
export CDPATH=$CDPATH:.:$HOME

# Ensure English is primary terminal language
export LANG=en_US.UTF-8

# Editor variables
VIM=/usr/bin/vim
if [ -e $VIM ]; then
 export EDITOR=$VIM
 export VISUAL=$VIM
fi

# Add sbin and bin in $HOME `$PATH`
export PATH="$HOME/bin:$HOME/sbin:$PATH"

# Make Python use UTF-8 encoding for output to stdin, stdout, and stderr.
export PYTHONIOENCODING='UTF-8';

# Configure FZF 
if [ -v FZF_CTRL_T_COMMAND ]; then
  #
  # Overwrite FZF command to surpress find errors
  # export FZF_CTRL_T_COMMAND='rg --files --hidden --glob "!.git/*" 2> /dev/null'

  # Replace filesearch with fd if installed
  if command -v fd &> /dev/null; then
    export FZF_DEFAULT_COMMAND="fd . $HOME"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND="fd -t d . $HOME"
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

  # Print tree structure in the preview window
  export FZF_ALT_C_OPTS="--preview 'tree -C {}'"
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
