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
CUSTOM_PREFIX=~/dotfiles/

# Install plugin manager for zsh
curl -L git.io/antigen > ~/antigen.zsh

# Download item integration script
curl -L https://iterm2.com/misc/install_shell_integration.sh > ~/.install_shell_integration.sh

# TODO: To install useful key bindings and fuzzy completion:
$(brew --prefix)/opt/fzf/install

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

# Enforce English for Terminal
LANG=en_US

# Shell integration with iTerm2
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

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
source ~/antigen.zsh

# Load antigen configuration
antigen init ~/dotfiles/.antigenrc
EOT
done
