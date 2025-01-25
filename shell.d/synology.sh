# Load on synology only
[[ "$(uname -a)" == *"synology"*  ]] || return 0

# Change prompt color to orange, for visual distinction
PS1="\[\033[38;5;225m\]\u@\h\[\033[0m\]:\[\033[38;5;081m\]\w\[\033[0m\]\$ "

# Add path to basic but hidden Synology tools
PATH=$PATH:/var/packages/DiagnosisTool/target/tool
# But alias tmux to the newer version
alias tmux='$HOME/bin/tmux'

alias gs="cd /volume1/storage"
alias gp="cd /volume1/photos"
