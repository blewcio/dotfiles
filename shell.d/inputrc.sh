# Disable bell sound on terminal
set bell-style none

# Different bind commands for sh
if [[ "$SHELL" == *"/sh" ]] || [[ "$SHELL" == *"bash" ]]; then

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
  bind '"\eh": backward-word' # Home Dir
  bind '"\el": forward-word' # Rebind to la, instead ls
  bind '"\e*": "ls\C-j"' # Rebind to la, instead ls
  bind '"\e-": "cd -\C-j"' # Alternate dir
  bind '"\e.": "cd ..\C-j"' # Alternate dir
  # Note: fzf cd on Alt-c and fzf file on Alt-i

  # Command line
  bind '"\ek": kill-line' # Rebind kill-line (as K i used for tmux movement)

# Different bind commands for zsh
else 

  # set completion-ignore-case on
  # set show-all-if-ambiguous 

  # Enablee to jump beetween words with arrows
  bindkey -e
  # bindkey '\e\e[C' forward-word
  # bindkey '\e\e[D' backward-word

  #Rebind German keys to something useful
  bindkey -s "ß" "/"
  bindkey -s "¿" "\\"
  bindkey -s "ü" "~"
  bindkey -s "Ü" "^"
  bindkey -s "ö" "["
  bindkey -s "ä" "]"
  bindkey -s "Ö" "{"
  bindkey -s "Ä" "}"

  # Custom mappings
  # Filesystem operations
  echo "Loading critical keys"
  bindkey -s "^[*" "ls^J" # Rebind to la, instead ls
  bindkey -s "^[-" "cd -^J" # Alternate dir
  bindkey -s "^[." "cd ..^J" # Alternate dir

  bindkey -r "^[h"
  bindkey -r "^[l"
  bindkey "^[h" backward-word
  bindkey "^[l" forward-word
  # Note: fzf cd on Alt-c and fzf file on Alt-i

  # Command line
  bindkey "^[k" kill-line # Rebind kill-line (as K i used for tmux movement)
fi
