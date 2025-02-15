## CSV Editing
# Display CSV file with proper columns (tabulated)
csv_cat() {
  if [ -z $1 ] || [ ! -f $1 ]; then
    echo "Incorrect filename. Usage: function FILENAME"
    return -1
  fi
  cat $1 | sed -e 's/,,/, ,/g' | column -s, -t # | less -#5 -N -S 
}
alias cat-csv=csv_cat

# Display CSV with csvlook (as a table)
csv_cat2() {
  if ! [ -x "$(command -v csvlook)" ]; then "csvkit not installed"; return -1; fi
  if [ -z $1 ] || [ ! -f $1 ]; then
    echo "Incorrect filename. Usage: function FILENAME"
    return -1
  fi
  csvlook --max-column-width=21 $1 | bat -p -l rs
}
alias cat-csv2=csv_cat2

## System functions or commands
# Safe remove
copy_to_trash() {
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
alias mkcd=mkcd

# Interactive list of most recent directories (param to prefilter)
# then cd
if [[ -x "$(command -v fzf)" ]] && [[ -x "$(command -v fasd)" ]]; then
  find_recent_dir() {
    local fasdlist
    fasdlist=$(fasd -d -l -r $1 | \
      fzf --query="$1 " --select-1 --exit-0 --height=25% --reverse --tac --no-sort --cycle) &&
      cd "$fasdlist"
  }
  alias t=find_recent_dir
fi

# Use ripgrep and fzf to search file content
# Find in files
if [[ -x "$(command -v fzf)" ]] && [[ -x "$(command -v fasd)" ]]; then
  find_in_files() {
   rg --column --line-number --no-heading --color=always --smart-case "${*:-}" |
   fzf --ansi -d ':' --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' --preview-window='50%' --preview-window '~3:+{2}+3/2' \
       --header=$'Press ? to preview\n      Enter/CTRL-E to edit\n      CTRL-Y to yank filename\n\n' --header-lines=0 \
       --bind 'ctrl-y:execute-silent(echo {1} | pbcopy)' --bind 'enter:become(vim {1} +{2})' --bind 'ctrl-e:execute(vim {1} +{2})' 
  # [ -n "$selected" ] && $EDITOR "$selected" # not needed
  }
  alias fif=find_in_files
fi

# `tree2` is a shorthand for `tree` with hidden files and color enabled, ignoring
# the `.git` directory, listing directories first. The output gets piped into
# `less` with options to preserve color and line numbers, unless the output is
# small enough for one screen.
if [[ -x "$(command -v tree)" ]]; then
 tree2() {
   tree -aC -I '.git|node_modules|bower_components' --dirsfirst "$@" | less -FRNX;
 }
 alias tree2=tree2
fi

# Change working directory to the top-most Finder window location
if [[ "$(uname)" == "Darwin"  ]]; then
  open_finder_directory() { 
    cd "$(osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)')";
  }
  alias cd-finder=open_finder_directory
fi

# Time now
time_now() {
  echo -n "Now is "
  date +"%X, %A, %B %-d, %Y"
}
alias now=time_now

# Status of the computer
net_status() {
  echo -e "\nUptime:"
  uptime | sed 's/^/\t/'
  echo -e "Active users:"
  users | sed 's/^/\t/'
  echo -e "Open ports:"
  lsof -Pni4 | grep LISTEN | sed 's/^/\t/'
}
alias net-status=net_status

# Remove all installed brew packages
if [[ "$(uname)" == "Darwin"  ]]; then
  brew_uninstall_all() {
    echo "Purging all installed brew packages"
    printf "Continue? (Y/N): "
    read confirm 

    # Stop here if not confirmed
    [[ ! $confirm == [yY] ]] && return 1

    while [[ `brew list | wc -l` -ne 0 ]]; do
      for EACH in `brew list`; do
        brew uninstall --force --ignore-dependencies $EACH
      done
    done
    echo << EOT
    # /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
EOT
  }
  alias brew-uninstall-all=brew_uninstall_all
fi

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
  alias n=n
fi

if [ -x "$(command -v yazi)" ]; then
  y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    cwd=$(cat -- "$tmp") 
    if [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
      cd "$cwd"
    fi
    rm $tmp
  }
  alias y=y
fi
