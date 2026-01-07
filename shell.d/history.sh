# History configuration for bash and zsh
# Ensures history is preserved even on connection drops

# Common settings
HISTSIZE=100000          # Number of commands to keep in memory
SAVEHIST=100000          # Number of commands to save to file

if [[ "$SHELL" == *"zsh" ]] || [[ -n "$ZSH_VERSION" ]]; then
  # ZSH History Configuration
  HISTFILE="$HOME/.zsh_history"

  # History options
  setopt EXTENDED_HISTORY          # Write timestamp to history
  setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first
  setopt HIST_IGNORE_DUPS          # Don't record duplicates
  setopt HIST_IGNORE_ALL_DUPS      # Delete old duplicate when new added
  setopt HIST_IGNORE_SPACE         # Don't record commands starting with space
  setopt HIST_FIND_NO_DUPS         # Don't display duplicates in search
  setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks
  setopt HIST_VERIFY               # Show command before executing from history
  # setopt SHARE_HISTORY             # Share history between sessions
  setopt INC_APPEND_HISTORY        # Write immediately, not on exit
  setopt APPEND_HISTORY            # Append to history file

elif [[ "$SHELL" == *"bash" ]] || [[ "$SHELL" == *"/sh" ]] || [[ -n "$BASH_VERSION" ]]; then
  # BASH History Configuration
  HISTFILE="$HOME/.bash_history"
  HISTFILESIZE=100000     # Max size of history file

  # Don't store duplicates and ignore commands starting with space
  HISTCONTROL=ignoreboth:erasedups

  # Append to history file instead of overwriting
  shopt -s histappend

  # Save multi-line commands as one command
  shopt -s cmdhist

  # Immediately write to history file after each command
  # This is crucial for surviving connection drops
  PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"

  # Enable extended globbing (useful for history expansion)
  shopt -s extglob 2>/dev/null

  # Save timestamp with history
  HISTTIMEFORMAT="%F %T "
fi

export HISTSIZE SAVEHIST HISTFILE
