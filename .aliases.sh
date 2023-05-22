# Use vim by default
alias vi="vim"

# Replace cat with bat
if [ -x "$(command -v bat)" ]; then
  alias cat="bat -p"
fi 

# Replace ls with exa
if [ -x "$(command -v exa)" ]; then
  alias ls="exa"
fi

# Shotcuts for ls
alias la="ls --long --all --group"
alias l='ls -F'
alias l.='ls -d .*'

# Directory shortcuts
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"

# fasd shortcuts
if [ -x "$(command -v fasd)" ]; then
  alias v='f -e vim' # Quickly open recent file
fi

# Additional fzf shortcusts
alias ch="chrome-history"
alias cb="chrome-bookmark-browser"
# Check if fzf-zsh-plugin reads  ~/Library/Application\ Support/Google/Chrome/Profile\ 1/History

# Tmux shortcuts
if [ -x "$(command -v tmux)" ]; then
  alias tmux='tmux -T 256'
  alias ta='tmux attach'
  alias tn='tmux new'
fi

# Ask before overwriting
alias mv="mv -i"
# mkdir incl. parent dirs if necessary
alias mkdir="mkdir -pv"
#Copy files and show progress
alias cr="rsync -P"
# Grep for a process
alias psg="ps aux | grep -v grep | grep -i -e VSZ -e"
# My external IP
alias myip="curl http://ipecho.net/plain; echo"
#Serve current directory tree at http://$HOSTNAME:8000/
alias lsw="python -m SimpleHTTPServer"

# Don't remove files directly, but move to trash
alias rm="rmr"

# Keep current location after exiting mc
MC_WRAPPER='/usr/lib/mc/mc-wrapper.sh'
if [ -x $MC_WRAPPER ]; then
     alias mc=". $MC_WRAPPER";
fi

# List installed packages
if [[ "$OSTYPE" == "darwin"* ]]; then
  alias installed-packages="brew leaves"
else
  alias installed-packages="comm -23 <(apt-mark showmanual | sort -u) <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u)"
fi

# Bulk update action
alias update='sudo softwareupdate -i -a; brew update; brew upgrade; brew cleanup'

# Hide/show all desktop icons (useful when presenting) from https://github.com/mathiasbynens/dotfiles
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

# Reload the shell (i.e. invoke as a login shell)
alias reload="exec ${SHELL} -l"

# Print each PATH entry on a separate line
alias path='echo -e ${PATH//:/\\n}'

# Shortcuts
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"
