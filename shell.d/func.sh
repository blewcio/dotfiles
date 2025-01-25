## CSV Editing
# Display CSV file with proper columns (tabulated)
csvcat() {
  cat $1 | sed -e 's/,,/, ,/g' | column -s, -t | less -#5 -N -S 
}

# Display CSV with csvlook (as a table)
csvcat2() {
  if ! [ -x "$(command -v csvlook)" ]; then "csvkit not installed"; return -1; fi
  csvlook --max-column-width=21 $1 | bat -p -l rs
}

## System functions or commands
# Safe remove
copy-to-trash() {
  local TRASH
  TRASH=~/.Trash/
  len=$#
  if [ $len -eq 0 ]; then
    echo "No files to remove."
    return -1
  fi
  for i in "$@"; do
    if [ ! -e "$i" ]; then
      echo "$i does not exist."
      continue
    fi
    echo "Moving $i to $TRASH" 
    mv $i $TRASH
  done
}

# Create a folder and move into it in one command
mkcd() {
  mkdir -p "$@" && cd "$_"
}

# Interactive list of most recent directories (param to prefilter)
# then cd
t() {
  local fasdlist
  fasdlist=$(fasd -d -l -r $1 | \
    fzf --query="$1 " --select-1 --exit-0 --height=25% --reverse --tac --no-sort --cycle) &&
    cd "$fasdlist"
}

# Use ripgrep and fzf to search file content
# Find in files
fif() {
   rg --column --line-number --no-heading --color=always --smart-case "${*:-}" |
   fzf --ansi -d ':' --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' --preview-window='50%' --preview-window '~3:+{2}+3/2' \
       --header=$'Press ? to preview\n      Enter/CTRL-E to edit\n      CTRL-Y to yank filename\n\n' --header-lines=0 \
       --bind 'ctrl-y:execute-silent(echo {1} | pbcopy)' --bind 'enter:become(vim {1} +{2})' --bind 'ctrl-e:execute(vim {1} +{2})' 
  # [ -n "$selected" ] && $EDITOR "$selected" # not needed
}

# `tree2` is a shorthand for `tree` with hidden files and color enabled, ignoring
# the `.git` directory, listing directories first. The output gets piped into
# `less` with options to preserve color and line numbers, unless the output is
# small enough for one screen.
tree2() {
  tree -aC -I '.git|node_modules|bower_components' --dirsfirst "$@" | less -FRNX;
}

# Change working directory to the top-most Finder window location
cd-finder() { 
  cd "$(osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)')";
}

# Time now
now() {
  echo -n "Now is "
  date +"%X, %A, %B %-d, %Y"
}

# Status of the computer
status() {
  echo -e "\nUptime:"
  uptime -p | sed 's/^/\t/'
  echo -e "Active users:"
  users | sed 's/^/\t/'
  echo -e "Open ports:"
  lsof -Pni4 | grep LISTEN | sed 's/^/\t/'
  # echo -e "Memory:"
  # free -hm | sed 's/^/\t/'
  # echo -e "Disk space:"
  # df -h 2> /dev/null | sed 's/^/\t/'
  # echo -e "Disk inodes:"
  # df -i 2> /dev/null | sed 's/^/\t/'
  # echo -e "Block devices:"
  # lsblk | sed 's/^/\t/'
  # if [[ -r /var/log/syslog ]]; then
  # echo -e "Syslog:"
  # tail /var/log/syslog | sed 's/^/\t/'
  # fi
  # if [[ -r /var/log/messages ]]; then
  # echo -e "Messages:"
  # tail /var/log/messages | sed 's/^/\t/'
  # fi
}

# Remove all installed brew packages
brew-uninstall-all() {
  echo "Purging all installed brew packages"
  read -p "Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
  while [[ `brew list | wc -l` -ne 0 ]]; do
    for EACH in `brew list`; do
      brew uninstall --force --ignore-dependencies $EACH
    done
  done
  echo << EOT
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
EOT
}

# nnn wrapper to stay in directory after exit
if [ -x "$(command -v nnn)" ]; then
n () {
    # Block nesting of nnn in subshells
    [ "${NNNLVL:-0}" -eq 0 ] || {
        echo "nnn is already running"
        return
    }

    # The behaviour is set to cd on quit (nnn checks if NNN_TMPFILE is set)
    # If NNN_TMPFILE is set to a custom path, it must be exported for nnn to
    # see. To cd on quit only on ^G, remove the "export" and make sure not to
    # use a custom path, i.e. set NNN_TMPFILE *exactly* as follows:
    #      NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
    export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"

    # Unmask ^Q (, ^V etc.) (if required, see `stty -a`) to Quit nnn
    # stty start undef
    # stty stop undef
    # stty lwrap undef
    # stty lnext undef

    # The command builtin allows one to alias nnn to n, if desired, without
    # making an infinitely recursive alias
    command nnn "$@"

    [ ! -f "$NNN_TMPFILE" ] || {
        . "$NNN_TMPFILE"
        rm -f -- "$NNN_TMPFILE" > /dev/null
    }
}

fi

if [ -x "$(command -v yazi)" ]; then
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -dedicatedn "$cwd"  ] && [ "$cwd" != "$PWD"  ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}
fi
