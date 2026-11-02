# Different bind commands for sh
if [[ "$SHELL" == *"/sh" ]] || [[ "$SHELL" == *"bash" ]]; then

  # Disable bell sound on terminal (must use bind command for readline)
  bind 'set bell-style none'

  #Rebind German keys to something useful
  bind '"ß": "/"'
  bind '"¿": "\\"'
  bind '"ü": "~"'
  bind '"Ü": "^"'
  bind '"ö": "["'
  bind '"ä": "]"'
  bind '"Ö": "{"'
  bind '"Ä": "}"'

  # Custom mappings
  # Filesystem operations
  # bind '"\eh": "cd $HOME\C-j"' # Home Dir
  # bind '"\el": "ls -la\C-j"' # Rebind to la, instead ls
  # bind '"\eh": backward-word' # Home Dir (commented out)
  # bind '"\el": forward-word' # Rebind to la, instead ls (commented out)
  bind '"\e-": "cd -\C-j"' # Alternate dir
  # Note: fzf cd on Alt-c and fzf file on Ctrl-T

  # Command line
  bind '"\ek": kill-line' # Rebind kill-line (as K i used for tmux movement)

# Different bind commands for zsh
else

  # Disable bell sound on terminal
  unsetopt BEEP

  # set completion-ignore-case on
  # set show-all-if-ambiguous 

  # Internal: bind the custom zsh keys; shellrc.sh calls it again
  # whenever C-x C-v switches between the emacs and vi keymaps
  _bind_custom_keys() {
    # Word editing (A-b, A-f, A-d, A-Left/Right)
    bindkey '^[b' backward-word
    bindkey '^[f' forward-word
    bindkey '^[d' kill-word
    bindkey '^[[1;3D' backward-word
    bindkey '^[[1;3C' forward-word
    bindkey "^[k" kill-line # Rebind kill-line (as K i used for tmux movement)

    #Rebind German keys to something useful
    bindkey -s "ß" "/"
    bindkey -s "¿" "\\"
    bindkey -s "ü" "~"
    bindkey -s "Ü" "^"
    bindkey -s "ö" "["
    bindkey -s "ä" "]"
    bindkey -s "Ö" "{"
    bindkey -s "Ä" "}"
    # Note: cd - on Alt-- and fzf cd on Alt-c, fzf file on Ctrl-T are in shellrc.sh
  }
  _bind_custom_keys
fi
