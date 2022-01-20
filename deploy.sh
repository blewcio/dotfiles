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

for file in .bashrc .zshrc; do

  SHELL_RC="$HOME/$file"

  if [ ! -f $SHELL_RC ]; then
    continue
  fi

  #Check if already included
  if [ -n "$(grep "for f in $CUSTOM_FILES; do" ${SHELL_RC})" ]; then
    echo "Auto-load lines already found in $SHELL_RC"
    continue
  fi

  echo "Adding auto-load lines to $SHELL_RC"

  cat << EOT >> $SHELL_RC

# Load Blazej's customizations

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
EOT
done
