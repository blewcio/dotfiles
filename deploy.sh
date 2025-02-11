#!/bin/sh

DOTFILES_DIR=~/dotfiles
SHELLRC_FILE=shellrc.sh

# Install zsh plugin manager
if [[ "$SHELL" == *zsh ]]; then

  # Install plugin manager for zsh
  curl -L git.io/antigen > ${DOTFILES_DIR}/antigen.zsh

  # Re-link antigenrc to avoid error messages
  antigenrc=$DOTFILES_DIR/config/antigenrc
  if [[ -r "$antigenrc" ]]; then
    ln -sf $antigenrc $DOTFILES_DIR/.antigenrc
  fi
  unset $antigenrc
fi

# Download item integration script
curl -L https://iterm2.com/misc/install_shell_integration.sh > ~/.install_shell_integration.sh

# Mac specific configuration
if [[ "$(uname)" == "Darwin"  ]]; then

    # Check if packages from Brewfile should be installed
    mac_install=$DOTFILES_DIR/mac/mac-install.sh
    if [[ -r "$mac_install" ]]; then
      read -p "Install brew and packages from Brewfile? (y/n): " choice
      if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        eval $mac_install
      fi
    fi
    unset $mac_install
    unset $choice

  # FZF install, useful key bindings
  if [[ -x "$(command -v fzf)" ]]; then
    $(brew --prefix)/opt/fzf/install
  fi
fi

# Check which shell files exist and add custom scripts
for f in .bashrc .zshrc; do

  rc_file="$HOME/$f"

  if [ ! -f $rc_file ]; then
    continue
  fi

  #Check if already included
  if [ -n "$(grep "$SHELLRC_FILE" ${rc_file})" ]; then
    echo "Auto-load lines already found in $rc_file"
    continue
  fi

  echo "Adding auto-load lines to $rc_file"
  echo "[[ -r \"$DOTFILES_DIR/$SHELLRC_FILE\" ]] && source $DOTFILES_DIR/$SHELLRC_FILE" >> $rc_file
done

# Check if python packages should be installed
read -p "Install python packages? (y/n): " choice
if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
  if [[ -x "$(command -v pip3)" ]]; then
    # Install in $HOME (--user)
    eval $("pip3 install --user xlrd openpyxl") # Read Excel spreadsheets in vd
  else
    echo "Aborted. pip3 not installed."
  fi
fi

# TODO: Switch linking to stow (link farm management)
# Link configuration files
ln -sf $DOTFILES_DIR/config/tmux/tmux.conf ~/.tmux.conf
ln -sf $DOTFILES_DIR/config/ripgrep/ignore ~/.ignore
ln -sf $DOTFILES_DIR/config/visidata/visidatarc ~/.visidatarc
ln -sf $DOTFILES_DIR/config/git/gitconfig ~/.gitconfig

ln -sf $DOTFILES_DIR/config/git/gitignore_global ~/.gitignore_global
git config --global core.excludesfile '~/.gitignore_global'

mkdir -p ~/.config/fd
ln -sf $DOTFILES_DIR/config/fd/ignore ~/.config/fd/ignore 

mkdir -p ~/.config/bat
ln -sf $DOTFILES_DIR/config/bat/config ~/.config/bat/config 

mkdir -p ~/.config/fastfetch
ln -sf $DOTFILES_DIR/config/fastfetch/config ~/.config/fastfetch/config 

# Install vim
git clone https://github.com/blewcio/vim-config.git $HOME/vim-config
ln -sf $HOME/vim-config/.vimrc ~/.vimrc

# Create tmp dirs. vim cannot do it on its own.
mkdir -p mkdir $HOME/.vim/var/view
mkdir -p mkdir $HOME/.vim/var/swp
mkdir -p mkdir $HOME/.vim/var/undo
mkdir -p mkdir $HOME/.vim/var/backtup
# Pull Vundle packet manager and install dependencies
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall
