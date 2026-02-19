#!/bin/bash
#
# Dotfiles Deployment Script
# This script is idempotent and can be safely run multiple times
#
# Usage: ./deploy.sh
#

DOTFILES_DIR=~/dotfiles
SHELLRC_FILE=shellrc.sh
CATPPUCCIN_VARIANT=mocha

echo "================================"
echo "Dotfiles Deployment Starting..."
echo "================================"
echo ""

# ============================================
# General: Git Submodules
# ============================================

# Initialize private configuration submodule if it exists and is accessible
if [ -f "$DOTFILES_DIR/.gitmodules" ] && grep -q "path = private" "$DOTFILES_DIR/.gitmodules" 2>/dev/null; then
  # Check if submodule directory is empty or doesn't exist
  if [ ! -d "$DOTFILES_DIR/private" ] || [ -z "$(ls -A "$DOTFILES_DIR/private" 2>/dev/null)" ]; then
    echo "Initializing private configuration submodule..."
    if git -C "$DOTFILES_DIR" submodule update --init private 2>/dev/null; then
      echo "✓ Private submodule initialized successfully"
    else
      echo "⚠ Private submodule not accessible - skipping (this is normal if you don't have access)"
    fi
  else
    echo "Private submodule already initialized - skipping"
  fi
fi

# ============================================
# General: Shell Plugin Managers
# ============================================

# Install zsh plugin manager (Antidote)
if [[ "$SHELL" == *zsh ]]; then
  if [ ! -d "${HOME}/.antidote" ]; then
    echo "Installing Antidote plugin manager..."
    git clone --depth=1 https://github.com/mattmc3/antidote.git ${HOME}/.antidote
  else
    echo "Antidote already installed - skipping"
  fi
fi

# Install ble.sh (Bash Line Editor) for autosuggestions, syntax highlighting, and enhanced completion
# Note: installed regardless of current shell since bash may also be used
if [[ "$SHELL" == *bash ]] || command -v bash >/dev/null 2>&1; then
  if [ ! -d "$HOME/.local/share/blesh" ]; then
    echo "Installing ble.sh (Bash Line Editor)..."
    if git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git /tmp/ble.sh; then
      make -C /tmp/ble.sh install PREFIX=~/.local
      rm -rf /tmp/ble.sh
      echo "ble.sh installed successfully"
    else
      echo "Failed to install ble.sh - skipping"
    fi
  else
    echo "ble.sh already installed - skipping"
  fi
  # Note: ble.sh initialization is handled in shellrc.sh for centralized configuration
  # Note: bash-completion package can also be installed for enhanced tab completions
  #   macOS: brew install bash-completion@2
  #   Linux: apt install bash-completion (usually pre-installed)
fi

# ============================================
# General: Shell RC Files
# ============================================

# Check which shell files exist and add sourcing of shellrc.sh
for f in .bashrc .zshrc; do
  rc_file="$HOME/$f"

  if [ ! -f $rc_file ]; then
    continue
  fi

  # Check if already included
  if [ -n "$(grep "$SHELLRC_FILE" ${rc_file})" ]; then
    echo "Auto-load lines already found in $rc_file"
    continue
  fi

  echo "Adding auto-load lines to $rc_file"
  echo "[[ -r \"$DOTFILES_DIR/$SHELLRC_FILE\" ]] && source $DOTFILES_DIR/$SHELLRC_FILE" >> $rc_file
done

# ============================================
# General: Additional Tools
# ============================================

# Python packages for visidata
if [[ -x "$(command -v pip3)" ]]; then
  # Check if packages are already installed
  if ! pip3 list --user 2>/dev/null | grep -q "xlrd\|openpyxl"; then
    read -p "Install python packages for visidata (xlrd, openpyxl)? (y/n): " choice
    if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
      echo "Installing Python packages..."
      pip3 install --user xlrd openpyxl
    fi
  else
    echo "Python packages (xlrd, openpyxl) already installed - skipping"
  fi
else
  echo "pip3 not installed - skipping Python packages"
fi

# Tmux plugin manager (TPM)
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "Installing tmux plugin manager (TPM)..."
  mkdir -p ~/.tmux/plugins
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
  echo "Tmux plugin manager already installed - skipping"
fi

# ============================================
# Platform: macOS
# ============================================

if [ "$(uname)" = "Darwin" ]; then

  # Install Homebrew and packages from Brewfile
  mac_install=$DOTFILES_DIR/mac/mac-install.sh
  if [[ -r "$mac_install" ]]; then
    read -p "Install brew and packages from Brewfile? (y/n): " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
      eval $mac_install
    fi
  fi
  unset mac_install choice

  # Download iTerm2 shell integration
  if [ ! -f "$HOME/.iterm2_shell_integration.bash" ] && [ ! -f "$HOME/.iterm2_shell_integration.zsh" ]; then
    echo "Installing iTerm2 shell integration..."
    curl -fsSL https://iterm2.com/misc/install_shell_integration.sh | bash
  else
    echo "iTerm2 shell integration already installed - skipping"
  fi

  # Download iTerm2 Catppuccin theme
  mkdir -p $DOTFILES_DIR/config/iterm
  if [ ! -f "$DOTFILES_DIR/config/iterm/catppuccin-mocha.itermcolors" ]; then
    echo "Downloading Catppuccin Mocha theme for iTerm2..."
    curl -L https://github.com/catppuccin/iterm2/raw/main/colors/catppuccin-mocha.itermcolors \
      -o $DOTFILES_DIR/config/iterm/catppuccin-mocha.itermcolors
    echo "Catppuccin theme downloaded to config/iterm/"
  else
    echo "Catppuccin theme already downloaded - skipping"
  fi

  # FZF key bindings and completion
  if [[ -x "$(command -v fzf)" ]]; then
    if ! grep -q "fzf" "$HOME/.zshrc" 2>/dev/null && ! grep -q "fzf" "$HOME/.bashrc" 2>/dev/null; then
      echo "Installing FZF key bindings..."
      $(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc
    else
      echo "FZF already configured - skipping"
    fi
  fi

fi

# ============================================
# Platform: Linux
# ============================================

if [ "$(uname)" = "Linux" ]; then

  linux_install=$DOTFILES_DIR/linux/linux-install.sh
  if [[ -r "$linux_install" ]]; then
    bash "$linux_install"
  else
    echo "linux-install.sh not found at $linux_install - skipping Linux package installation"
  fi
  unset linux_install

fi

# ============================================
# General: Symlink Configuration Files
# ============================================

# TODO: Switch linking to stow (link farm management)
echo "Creating symlinks for configuration files..."
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
ln -sf $DOTFILES_DIR/config/bat/themes/themes ~/.config/bat/themes

# Rebuild bat cache with new themes
if command -v bat >/dev/null 2>&1; then
  bat cache --build >/dev/null 2>&1
  echo "✓ Rebuilt bat cache"
fi

mkdir -p ~/.config/fastfetch
ln -sf $DOTFILES_DIR/config/fastfetch/config.jsonc ~/.config/fastfetch/config.jsonc

mkdir -p ~/.config/yazi
ln -sf $DOTFILES_DIR/config/yazi/yazi.toml ~/.config/yazi/yazi.toml
ln -sf $DOTFILES_DIR/config/yazi/themes/themes/$CATPPUCCIN_VARIANT/catppuccin-$CATPPUCCIN_VARIANT-blue.toml ~/.config/yazi/theme.toml

mkdir -p ~/.config/lsd
ln -sf $DOTFILES_DIR/config/lsd/themes/themes/catppuccin-$CATPPUCCIN_VARIANT/colors.yaml ~/.config/lsd/colors.yaml
ln -sf $DOTFILES_DIR/config/lsd/config.yaml ~/.config/lsd/config.yaml

mkdir -p ~/.config/mc
ln -sf $DOTFILES_DIR/config/mc/mc.keymap ~/.config/mc/mc.keymap

mkdir -p ~/.config/pet
ln -sf $DOTFILES_DIR/config/pet/snippet.toml ~/.config/pet/snippet.toml

mkdir -p ~/.config/delta/themes
ln -sf $DOTFILES_DIR/config/delta/themes/catppuccin.gitconfig ~/.config/delta/themes/catppuccin.gitconfig

mkdir -p ~/.config/btop/themes
ln -sf $DOTFILES_DIR/config/btop/btop.conf ~/.config/btop/btop.conf
ln -sf $DOTFILES_DIR/config/btop/themes/themes/catppuccin_${CATPPUCCIN_VARIANT}.theme ~/.config/btop/themes/catppuccin_${CATPPUCCIN_VARIANT}.theme

# lazygit: macOS stores config in a buried Application Support directory;
# create a stable ~/.config/lazygit path that works on both platforms
mkdir -p ~/.config/lazygit
if [ "$(uname)" = "Darwin" ]; then
  APPSUPPORT="$HOME/Library/Application Support"
  ln -sf $APPSUPPORT/lazygit ~/.config/lazygit/AppSupport
  ln -sf $DOTFILES_DIR/config/lazygit/config.yml ~/.config/lazygit/AppSupport/config.yml
else
  ln -sf $DOTFILES_DIR/config/lazygit/config.yml ~/.config/lazygit/config.yml
fi

# Antidote plugin configuration
ln -sf $DOTFILES_DIR/config/zsh/zsh_plugins.txt ~/.zsh_plugins.txt
# Note: catppuccin-fzf.zsh is sourced directly from config/zsh/, no symlink needed

# Claude Code and Desktop use different config directories
mkdir -p ~/.claude
ln -sf $DOTFILES_DIR/agents/CLAUDE.md ~/.claude/CLAUDE.md
ln -sf $DOTFILES_DIR/agents/skills ~/.claude/skills
ln -sf $DOTFILES_DIR/agents/agents ~/.claude/agents

mkdir -p ~/.config/claude
ln -sf $DOTFILES_DIR/config/claude_desktop/claude_desktop_config.json ~/.config/claude/claude_desktop_config.json

mkdir -p ~/.config/opencode
ln -sf $DOTFILES_DIR/config/opencode/opencode.json ~/.config/opencode/opencode.json
ln -sf $DOTFILES_DIR/agents/CLAUDE.md ~/.config/opencode/AGENTS.md
ln -sf $DOTFILES_DIR/agents/skills ~/.config/opencode/skills

echo "Symlinks created successfully"

# ============================================
# General: Vim and Neovim Configuration
# ============================================

echo "Setting up Vim configuration..."
if [ ! -d "$HOME/vim-config" ]; then
  echo "  Cloning vim-config repository..."
  git clone https://github.com/blewcio/vim-config.git $HOME/vim-config
else
  echo "  vim-config already exists - skipping clone"
fi

# Symlink classic Vim configuration
ln -sf $HOME/vim-config/.vimrc ~/.vimrc
ln -sf $HOME/vim-config/.vim ~/.vim

# Create tmp dirs for Vim (vim cannot create them automatically)
mkdir -p $HOME/.vim/var/view
mkdir -p $HOME/.vim/var/swp
mkdir -p $HOME/.vim/var/undo
mkdir -p $HOME/.vim/var/backup

# Vundle plugin manager
if [ ! -d "$HOME/.vim/bundle/Vundle.vim" ]; then
  echo "  Installing Vundle plugin manager..."
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  if command -v vim >/dev/null 2>&1; then
    vim +PluginInstall +qall
  else
    echo "  vim not found - skipping plugin installation (run :PluginInstall manually)"
  fi
else
  echo "  Vundle already installed - skipping"
fi

# Neovim configuration (modern Lua-based setup)
if [ -x "$(command -v nvim)" ]; then
  echo "Setting up Neovim configuration..."

  # Backup existing nvim config if it exists and is not a symlink
  if [ -d "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
    echo "Backing up existing Neovim config to ~/.config/nvim.backup"
    mv $HOME/.config/nvim $HOME/.config/nvim.backup
  fi

  mkdir -p $HOME/.config
  ln -sf $HOME/vim-config/nvim $HOME/.config/nvim
  echo "  Neovim configuration symlinked. Plugins will auto-install on first launch."
  echo "  After launching nvim, run: :Mason to install LSP servers"
else
  echo "Neovim not installed - skipping Neovim configuration."
  echo "  Install with: brew install neovim (macOS) or apt install neovim (Linux)"
fi

# ============================================
# Done
# ============================================

echo ""
echo "================================"
echo "Deployment Complete!"
echo "================================"
echo ""
echo "Next steps:"
echo "  1. Restart your shell or run: source ~/.zshrc (or ~/.bashrc)"
echo "  2. If using tmux, press prefix+I to install tmux plugins"
echo "  3. If using Neovim, run :Mason to install LSP servers"

if [ "$(uname)" = "Darwin" ]; then
  if [ -f "$DOTFILES_DIR/config/iterm/catppuccin-mocha.itermcolors" ]; then
    echo ""
    echo "To apply Catppuccin theme to iTerm2:"
    echo "  1. Open iTerm2 → Preferences (Cmd+,)"
    echo "  2. Go to Profiles → Colors"
    echo "  3. Click 'Color Presets' dropdown → Import"
    echo "  4. Select: ~/dotfiles/config/iterm/catppuccin-mocha.itermcolors"
    echo "  5. Choose 'Catppuccin Mocha' from the Color Presets dropdown"
    echo ""
    echo "Catppuccin theme is now applied to:"
    echo "  ✓ Powerlevel10k prompt (automatic)"
    echo "  ✓ bat syntax highlighting (automatic)"
    echo "  ✓ fzf fuzzy finder (automatic)"
    echo "  ✓ tmux status line (automatic)"
  fi
fi

echo ""
echo "The script is idempotent - you can safely run it again to update."
echo ""
