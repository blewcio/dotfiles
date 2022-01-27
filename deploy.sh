#!/bin/sh

# Commented out to directly load from .dotfiles

# ERROR_COLOR='\033[0;31m'
# WARNING_COLOR='\033[0;33m'
# NO_COLOR='\033[0m'

# # STEP 1: Link all files to $HOME and keep the directory structure

# # Use find to easily list all files in sub-directories
# for file in $(find $PWD -type f | grep -v '.sh'); do

  # FILENAME=${file#$PWD}
  # TARGET="${HOME}${FILENAME}"
  # DIR=${TARGET%/*}

  # echo "Creating $TARGET"

  # if [ -e $TARGET ]; then
    # BACKUP="${TARGET}~"
    # echo "** ${WARNING_COLOR}Warning${NO_COLOR}: File exists, backing up to ${BACKUP}"
    # mv $TARGET $BACKUP
    # unset BACKUP
  # fi

  # if [ ! -d $DIR ]; then
    # echo "** ${WARNING_COLOR}Warning${NO_COLOR}: $DIR does not exist. Creating... ${DIR}"
    # mkdir -p $DIR
  # fi

  # ln -s $file $TARGET

# done

# Append lines to .bashrc and .zshrc to autoload custom extension files

CUSTOM_FILES=".aliases.sh .exports.sh .functions.sh"
CUSTOM_PREFIX=~/.dotfiles/

# Install plugin manager for zsh
curl -L git.io/antigen > ~/.dotfiles/antigen.zsh

# TODO: To install useful key bindings and fuzzy completion:
# $(brew --prefix)/opt/fzf/install

# Download item integration script
# TODO: curl -L https://iterm2.com/misc/install_shell_integration.sh > ~/.install_shell_integration.sh

# TODO: Download tmux config

for file in .bashrc .zshrc; do

  SHELL_RC="$HOME/$file"

  if [ ! -f $SHELL_RC ]; then
    continue
  fi

# Add list of prefered plugins to .zshrc

  #Check if already included
  if [ -n "$(grep "for f in $CUSTOM_FILES; do" ${SHELL_RC})" ]; then
    echo "Auto-load lines already found in $SHELL_RC"
    continue
  fi

  echo "Adding custom lines to $SHELL_RC"

  cat << EOT >> $SHELL_RC

# Load Blazej's customizations

# Shell integration with iTerm2
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Load fuzzy finder (Ctrl-T files, Ctrl-R comands, Alt-C cd to DIR)
#[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Initialize fasd 
echo 'eval "$(fasd --init auto)"' >> $SHELL_RC

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# If remote session, start ssh as tmux
if [[ -n "$PS1" ]] && [[ -z "$TMUX" ]] && [[ -n "$SSH_CONNECTION" ]]; then
  tmux attach-session -t ssh_tmux || tmux new-session -s ssh_tmux
fi

# Enablee to jump beetween words with arrows
bindkey -e
bindkey '\e\e[C' forward-word
bindkey '\e\e[D' backward-word

# Autoload custom config files
for f in $CUSTOM_FILES; do
  if [ -r "$CUSTOM_PREFIX\$f" ]; then
    source  "$CUSTOM_PREFIX\$f"
  else
    echo "Can't open $CUSTOM_PREFIX\$f"
  fi

done
# Load zsh plugin manager
source ~/.dotfiles/antigen.zsh

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

# Bundles from the default repo (robbyrussell's oh-my-zsh).
antigen bundle git
antigen bundle command-not-found
antigen bundle copybuffer
antigen bundle iterm2
antigen bundle fasd
antigen bundle brew
antigen bundle colorize
antigen bundle macos
antigen bundle wakeonlan
antigen bundle fzf

antigen bundle zsh-users/zsh-syntax-highlighting #highlighting in CLI, grey/green command
antigen bundle zsh-users/zsh-autosuggestions #suggestinons in greyp based on history and completio
#antigen bundle zsh-users/zsh-apple-touchbar
antigen bundle unixorn/fzf-zsh-plugin
antigen bundle aloxaf/fzf-tab
antigen bundle marzocchi/zsh-notify # send notification to macOS

# Load the theme.
antigen bundle romkatv/powerlevel10k

# Tell Antigen that you're done.
antigen apply
EOT
done
