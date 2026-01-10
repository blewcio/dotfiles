# Directory shortcuts
alias h="cd $HOME" # tilde does not work properly in Germany
if [[ "$(uname)" == "Darwin"  ]]; then
  alias dl="cd ~/Downloads"
fi

# Use vim by default
if [ -x "$(command -v vim)" ]; then
  alias vi="vim"
fi

# Replace cat with bat
if [ -x "$(command -v bat)" ]; then
  alias cat="bat -p"
  export MANPAGER="sh -c 'col -bx | bat -l man -p'" # Man pages
  help() { # Colorized help command, e.g. help eza
    "$@" --help 2>&1 | bat --plain --language=help
  }
fi 

# Replace ls with eza (exa is unmaintained)
if [ -x "$(command -v eza)" ]; then
  alias ls="eza --group-directories-first"
fi

# Add more ls commands with lsd (for symbols)
if [ -x "$(command -v lsd)" ]; then
  alias ls-size="lsd -1l -S -a"
  alias ls-mod="lsd -1l -t -a"
  alias ls-git="lsd -1l -Gg -a"
fi
  
# Reverse dust by default, like tree
if [ -x "$(command -v dust)" ]; then
  alias dust="dust -r"
fi

# Default df to human readable
alias df='df -h && echo "Dont forget duf!"' 

# Shotcuts for ls
alias la="ls --long --all --group" # -lAh
if [ -x "$(command -v tree)" ]; then
  # alias lt="ls --tree --level=3"
  alias lt="tree"
fi
alias l='ls -F'
alias l.='ls -d .*'

# Interactive-list with br
if [ -x "$(command -v broot)" ]; then
  alias lo="br -sdp"
fi

# fasd maintenance - remove stale entries (deleted files/dirs)
if [ -x "$(command -v fasd)" ]; then
  alias fasd-cleanup='fasd -l | while read f; do [ ! -e "$f" ] && fasd -D "$f"; done && echo "Cleaned stale fasd entries"'
fi

# Process shortcuts
alias pgrep2="ps aux | grep -v grep | grep -i -e VSZ -e"
# Replace procs with ps
if [ -x "$(command -v procs)" ]; then
  alias pgrep="procs" # with input param
  alias ptree="procs --tree" # with input param
fi

# Additional fzf shortcusts
alias ch="chrome-history"
alias cb="chrome-bookmark-browser"

# Tmux shortcuts
if [ -x "$(command -v tmux)" ]; then
  # alias tmux='tmux -T 256'
  alias ta='tmux attach'
  alias tn='tmux new'
  alias tm-dev='tmux_dev.sh'
fi

# Get easy to digest help
if [ -x "$(command -v tldr)" ] && [ -x "$(command -v fzf)" ]; then
  alias thelp='tldr --list | fzf | xargs tldr'
fi

if [ -x "$(command -v tmux)" ] && [ -x "$(command -v tmux_cht.sh)" ]; then
  alias chelp=tmux_cht.sh
fi


# File system operations
# Ask before overwriting
alias mv="mv -i"
# mkdir incl. parent dirs if necessary
alias mkdir="mkdir -pv"
#Copy files and show progress
alias rcp="rsync -P"
# Don't remove files directly, but move to trash
alias del="/bin/rm" # Keep the ultimate rm option as del
alias rm=copy_to_trash # Call a function instead

# Network related shortcuts
# My external IP
alias myip="curl http://ipecho.net/plain; echo"
#Serve current directory tree at http://$HOSTNAME:8000/
alias lsw="python -m SimpleHTTPServer"

# Keep current location after exiting mc
MC_WRAPPER='/usr/lib/mc/mc-wrapper.sh'
if [ -x $MC_WRAPPER ]; then
     alias mc=". $MC_WRAPPER";
fi

# View pictures in terminal
if [ -x "$(command -v viu)" ]; then
  alias viu="viu -n -h 20"
fi

#Packet management
# List installed packages
if [[ "$OSTYPE" == "darwin"* ]]; then
  alias installed-packages="brew leaves"
else
  alias installed-packages="comm -23 <(apt-mark showmanual | sort -u) <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u)"
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
  # Bulk update action
  alias update='sudo softwareupdate -i -a; brew update; brew upgrade; brew cleanup'
  # Hide/show all desktop icons (useful when presenting) from https://github.com/mathiasbynens/dotfiles
  alias desktop-hide="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
  alias desktop-show="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"
fi

# Print each PATH entry on a separate line
alias path='echo -e ${PATH//:/\\n}'

# Reload the shell (i.e. invoke as a login shell)
alias reload="exec ${SHELL} -l"

