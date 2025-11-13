#!/bin/bash

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
  unset antigenrc
fi

# Mac specific configuration
if [ "$(uname)" = "Darwin" ]; then

    # Check if packages from Brewfile should be installed
    mac_install=$DOTFILES_DIR/mac/mac-install.sh
    if [[ -r "$mac_install" ]]; then
      read -p "Install brew and packages from Brewfile? (y/n): " choice
      if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        eval $mac_install
      fi
    fi
    unset mac_install
    unset choice

    # Download item integration script
    wget -qO- https://iterm2.com/misc/install_shell_integration.sh | bash

  # FZF install, useful key bindings
  if [[ -x "$(command -v fzf)" ]]; then
    $(brew --prefix)/opt/fzf/install
  fi
fi

# Install oh-my-zsh addons
ZSH_CUSTOM=$HOME/.oh-my-zsh/custom
git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git $ZSH_CUSTOM/plugins/zsh-autocomplete
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
echo "TODO: Add to zshrc:\n
plugins=(fasd alias-finder virtualenv direnv git zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting zsh-autocomplete)
"

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
if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
  if [[ -x "$(command -v pip3)" ]]; then
    # Install in $HOME (--user)
    eval $("pip3 install --user xlrd openpyxl") # Read Excel spreadsheets in vd
  else
    echo "Aborted. pip3 not installed."
  fi
fi

# Install tmux plugin manager 
mkdir -p ~/.tmux/plugins/tpm
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Install base Linux packages, if needed
read -p "Install base linux packages? (y/n): " choice
if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
  packages="tmux bat vim fzf fasd eza tldr pixz lbzip2 rsync ripgrep zoxide wget qemu-guest-agent fd-find git btop iperf iperf3 nfs-common"
  # TODO: The next line is Debian specific
  eval sudo apt install -y $packages
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
ln -sf $DOTFILES_DIR/config/fastfetch/config.jsonc ~/.config/fastfetch/

# Install vim and neovim configurations
if [ ! -d "$HOME/vim-config" ]; then
  git clone https://github.com/blewcio/vim-config.git $HOME/vim-config
fi

# Symlink classic Vim configuration
ln -sf $HOME/vim-config/.vimrc ~/.vimrc
ln -sf $HOME/vim-config/.vim ~/.vim

# Create tmp dirs for Vim (vim cannot create them automatically)
mkdir -p $HOME/.vim/var/view
mkdir -p $HOME/.vim/var/swp
mkdir -p $HOME/.vim/var/undo
mkdir -p $HOME/.vim/var/backup

# Pull Vundle package manager and install dependencies for Vim
if [ ! -d "$HOME/.vim/bundle/Vundle.vim" ]; then
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  vim +PluginInstall +qall
fi

# Setup Neovim configuration (modern Lua-based setup)
if [ -x "$(command -v nvim)" ]; then
  echo "Setting up Neovim configuration..."

  # Backup existing nvim config if it exists and is not a symlink
  if [ -d "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
    echo "Backing up existing Neovim config to ~/.config/nvim.backup"
    mv $HOME/.config/nvim $HOME/.config/nvim.backup
  fi

  # Create .config directory if it doesn't exist
  mkdir -p $HOME/.config

  # Symlink Neovim configuration
  ln -sf $HOME/vim-config/nvim $HOME/.config/nvim

  echo "Neovim configuration symlinked. Plugins will auto-install on first launch."
  echo "After launching nvim, run: :Mason to install LSP servers"
else
  echo "Neovim not installed. Skipping Neovim configuration."
  echo "Install with: brew install neovim (macOS) or apt install neovim (Linux)"
fi
