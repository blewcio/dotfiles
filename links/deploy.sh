#!/bin/sh

ERROR_COLOR='\033[0;31m'
WARNING_COLOR='\033[0;33m'
NO_COLOR='\033[0m'

# STEP 1: Link all files to $HOME and keep the directory structure

# Use find to easily list all files in sub-directories
for file in $(find $PWD -type f -name ".*"); do

  FILENAME=${file#$PWD}
  TARGET="${HOME}${FILENAME}"
  DIR=${TARGET%/*}

  echo "Creating $TARGET"

  if [ -e $TARGET ]; then
    BACKUP="${TARGET}~"
    echo "** ${WARNING_COLOR}Warning${NO_COLOR}: File exists, backing up to ${BACKUP}"
    mv $TARGET $BACKUP
    unset BACKUP
  fi

  if [ ! -d $DIR ]; then
    echo "** ${WARNING_COLOR}Warning${NO_COLOR}: $DIR does not exist. Creating... ${DIR}"
    mkdir -p $DIR
  fi

  ln -s $file $TARGET

done

# STEP 2: Append lines to .bashrc and .zshrc to autoload custom extension files

for file in .bashrc .zshrc; do

  SHELL_RC="$HOME/$file"

  if [ ! -f $SHELL_RC ]; then
    continue
  fi

  if [ -n "$(grep "for f in .aliases .exports .functions .localrc; do" ${SHELL_RC})" ]; then
    continue
  fi
  echo "Adding auto-load lines to $SHELL_RC"

cat << EOT >> $SHELL_RC

# Load Blazej's customizations

for f in .aliases .exports .functions .localrc; do
  if [ -f ~/\$f ]; then
    . ~/\$f
  fi
done
EOT

done
