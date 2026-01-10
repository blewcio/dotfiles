## CSV Editing
# Display CSV file with proper columns (tabulated)
csv_cat() {
  if [ -z "$1" ] || [ ! -f "$1" ]; then
    echo "Incorrect filename. Usage: function FILENAME"
    return -1
  fi
  cat "$1" | sed -e 's/,,/, ,/g' | column -s, -t # | less -#5 -N -S
}

# Display CSV with csvlook (as a table)
csv_cat2() {
  if ! [ -x "$(command -v csvlook)" ]; then "csvkit not installed"; return -1; fi
  if [ -z "$1" ] || [ ! -f "$1" ]; then
    echo "Incorrect filename. Usage: function FILENAME"
    return -1
  fi
  csvlook --max-column-width=21 "$1" | bat -p -l rs
}

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
    mv "$i" "$TRASH"
  done
}

# Create a folder and move into it in one command
mkcd() {
  mkdir -p "$@" && cd "$_"
}

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
if [[ -x "$(command -v fzf)" ]] && [[ -x "$(command -v rg)" ]]; then
  find_in_files() {
   rg --column --line-number --no-heading --color=always --smart-case "${*:-}" |
   fzf --ansi -d ':' --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' --preview-window='50%' --preview-window '~3:+{2}+3/2' \
       --header=$'Press ? to preview\n      Enter/CTRL-E to edit\n      CTRL-Y to yank filename\n\n' --header-lines=0 \
       --bind 'ctrl-y:execute-silent(echo {1} | pbcopy)' --bind 'enter:become(vim {1} +{2})' --bind 'ctrl-e:execute(vim {1} +{2})'
  }
  alias fif=find_in_files
fi

# Interactive git branch checkout with fzf
if [[ -x "$(command -v fzf)" ]] && [[ -x "$(command -v git)" ]]; then
  fzf_git_checkout() {
    local branch
    branch=$(git branch -a --color=always | grep -v '/HEAD\s' | \
      fzf --ansi --height=40% --reverse --tac \
          --preview 'git log --oneline --graph --color=always $(echo {} | sed "s/.* //" | sed "s#remotes/[^/]*/##")' \
          --preview-window=right:50% | \
      sed 's/.* //' | sed 's#remotes/[^/]*/##')
    [ -n "$branch" ] && git checkout "$branch"
  }
  alias gco=fzf_git_checkout

  # Interactive git log browser with fzf
  fzf_git_log() {
    git log --oneline --color=always --decorate | \
      fzf --ansi --no-sort --reverse --height=80% \
          --preview 'git show --color=always {1}' \
          --preview-window=right:60% \
          --bind 'enter:execute(git show --color=always {1} | less -R)'
  }
  alias glog=fzf_git_log
fi

# Interactive process killer with fzf
if [[ -x "$(command -v fzf)" ]]; then
  fzf_kill_process() {
    local pid
    if [[ "$(uname)" == "Darwin" ]]; then
      pid=$(ps -ef | sed 1d | fzf -m --height=40% --reverse \
            --header='Select process(es) to kill' | awk '{print $2}')
    else
      pid=$(ps -ef | sed 1d | fzf -m --height=40% --reverse \
            --header='Select process(es) to kill' | awk '{print $2}')
    fi
    if [ -n "$pid" ]; then
      echo "$pid" | xargs kill -${1:-9}
      echo "Killed process(es): $pid"
    fi
  }
  alias fkill=fzf_kill_process
fi

# `tree2` is a shorthand for `tree` with hidden files and color enabled, ignoring
# the `.git` directory, listing directories first. The output gets piped into
# `less` with options to preserve color and line numbers, unless the output is
# small enough for one screen.
if [[ -x "$(command -v tree)" ]]; then
 tree2() {
   tree -aC -I '.git|node_modules|bower_components' --dirsfirst "$@" | less -FRNX;
 }
fi

# Change working directory to the top-most Finder window location
if [[ "$(uname)" == "Darwin"  ]]; then
  open_finder_directory() {
    cd "$(osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)')";
  }
  alias cdf=open_finder_directory  # Shorter alias
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
fi

if [ -x "$(command -v yazi)" ]; then
  y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    cwd=$(cat -- "$tmp")
    if [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
      cd "$cwd"
    fi
    rm -f "$tmp"
  }
fi

## Function Discovery Helpers

# List all custom functions organized by category
list_functions() {
  echo "Scripts (from ~/dotfiles/bin/):"
  if [ -d ~/dotfiles/bin ]; then
    ls -1 ~/dotfiles/bin/ | sed 's/^/  /' | sort
  fi
  echo ""
  echo "General Functions:"
  grep -E "^ *[a-z0-9_]+ ?\(\)" ~/dotfiles/shell.d/func.sh | sed 's/^ *//' | sed 's/ *().*//' | grep -v '^_' | sed 's/^/  /' | sort
  echo ""
  echo "Picture Functions:"
  grep -E "^ *[a-z0-9_]+ ?\(\)" ~/dotfiles/shell.d/func_pictures.sh | sed 's/^ *//' | sed 's/ *().*//' | grep -v '^_' | sed 's/^/  /' | sort
  echo ""
  echo "Video Functions:"
  grep -E "^ *[a-z0-9_]+ ?\(\)" ~/dotfiles/shell.d/func_video.sh | sed 's/^ *//' | sed 's/ *().*//' | grep -v '^_' | sed 's/^/  /' | sort
  echo ""
  echo "Synology Functions:"
  if [ -f ~/dotfiles/shell.d/synology.sh ]; then
    grep -E "^ *[a-z0-9_]+ ?\(\)" ~/dotfiles/shell.d/synology.sh | sed 's/^ *//' | sed 's/ *().*//' | grep -v '^_' | sed 's/^/  /' | sort
  fi
}
alias funcs=list_functions

# Show function usage and description
describe_function() {
  if [ $# -eq 0 ]; then
    echo "Usage: describe_function FUNCTION_OR_SCRIPT_NAME"
    echo "Example: describe_function csv_cat"
    echo "Example: describe_function pic_info"
    return 1
  fi

  # First check if it's a script in bin/
  if [ -f ~/dotfiles/bin/$1 ]; then
    echo "Script: $1"
    echo "Location: ~/dotfiles/bin/$1"
    echo ""
    # Extract header comments (lines starting with # after shebang, stop at first non-comment)
    local header=$(awk '/^#!/{next} /^#/{print} /^[^#]/{if(NR>1)exit}' ~/dotfiles/bin/$1)
    if [ -n "$header" ]; then
      echo "$header"
    else
      echo "No description available. View the script with: cat ~/dotfiles/bin/$1"
    fi
    return 0
  fi

  # Otherwise check if it's a function
  local result=$(grep -B 3 "^ *$1 *()" ~/dotfiles/shell.d/*.sh 2>/dev/null)
  if [ -z "$result" ]; then
    echo "Function or script '$1' not found"
    echo ""
    echo "Try 'funcs' to see all available functions and scripts"
    return 1
  fi
  echo "Function: $1"
  echo ""
  echo "$result" | sed 's/.*shell.d\///' | grep -v '^--$'
}
alias fhelp=describe_function
