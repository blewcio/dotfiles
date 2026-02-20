#!/bin/bash
#
# Dotfiles Update Script
# Updates all third-party tools and plugins installed by deploy.sh
#
# Usage: ./update.sh
#

DOTFILES_DIR=~/dotfiles

echo "================================"
echo "Dotfiles Update Starting..."
echo "================================"
echo ""

# Track if any updates were performed
UPDATES_PERFORMED=0

# ============================================
# Git Submodules (Catppuccin Themes)
# ============================================

echo "Updating git submodules (Catppuccin themes and private config)..."
if git -C "$DOTFILES_DIR" submodule update --remote --merge 2>/dev/null; then
  echo "  ✓ Git submodules updated"
  UPDATES_PERFORMED=1

  # Rebuild bat cache after theme update
  if command -v bat >/dev/null 2>&1; then
    bat cache --build >/dev/null 2>&1
    echo "  ✓ Rebuilt bat cache with updated themes"
  fi
else
  echo "  ✗ Failed to update git submodules"
fi

echo ""

# ============================================
# Shell Plugin Managers
# ============================================

# Update Antidote (zsh plugin manager)
if command -v antidote >/dev/null 2>&1; then
  echo "Updating Antidote plugins..."
  if antidote update 2>/dev/null; then
    echo "  ✓ Antidote plugins updated"
    UPDATES_PERFORMED=1
  else
    echo "  ✗ Failed to update Antidote plugins"
  fi
else
  echo "Antidote not installed - skipping"
fi

# Update ble.sh (Bash Line Editor)
if [ -d "$HOME/.local/share/blesh" ]; then
  echo "Updating ble.sh (Bash Line Editor)..."

  # Clone latest version to temp directory
  if git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git /tmp/ble.sh 2>/dev/null; then
    # Backup current installation
    if [ -d "$HOME/.local/share/blesh.backup" ]; then
      rm -rf "$HOME/.local/share/blesh.backup"
    fi
    mv "$HOME/.local/share/blesh" "$HOME/.local/share/blesh.backup"

    # Install new version
    if make -C /tmp/ble.sh install PREFIX=~/.local >/dev/null 2>&1; then
      rm -rf /tmp/ble.sh
      rm -rf "$HOME/.local/share/blesh.backup"
      echo "  ✓ ble.sh updated"
      UPDATES_PERFORMED=1
    else
      echo "  ✗ Failed to install new version, restoring backup"
      rm -rf "$HOME/.local/share/blesh"
      mv "$HOME/.local/share/blesh.backup" "$HOME/.local/share/blesh"
      rm -rf /tmp/ble.sh
    fi
  else
    echo "  ✗ Failed to clone ble.sh repository"
    rm -rf /tmp/ble.sh
  fi
else
  echo "ble.sh not installed - skipping"
fi

# ============================================
# macOS-Specific Updates
# ============================================

if [ "$(uname)" = "Darwin" ]; then

  # Update iTerm2 shell integration
  if [ -f "$HOME/.iterm2_shell_integration.bash" ] || [ -f "$HOME/.iterm2_shell_integration.zsh" ]; then
    echo "Updating iTerm2 shell integration..."
    if wget -qO- https://iterm2.com/misc/install_shell_integration.sh | bash 2>/dev/null; then
      echo "  ✓ iTerm2 shell integration updated"
      UPDATES_PERFORMED=1
    else
      echo "  ✗ Failed to update iTerm2 shell integration"
    fi
  else
    echo "iTerm2 shell integration not installed - skipping"
  fi

  # Update iTerm2 Catppuccin theme
  if [ -f "$DOTFILES_DIR/config/iterm/catppuccin-mocha.itermcolors" ]; then
    echo "Updating Catppuccin Mocha theme for iTerm2..."
    if curl -L https://github.com/catppuccin/iterm2/raw/main/colors/catppuccin-mocha.itermcolors \
        -o $DOTFILES_DIR/config/iterm/catppuccin-mocha.itermcolors.new 2>/dev/null; then
      mv $DOTFILES_DIR/config/iterm/catppuccin-mocha.itermcolors.new \
         $DOTFILES_DIR/config/iterm/catppuccin-mocha.itermcolors
      echo "  ✓ Catppuccin theme updated"
      UPDATES_PERFORMED=1
    else
      echo "  ✗ Failed to update Catppuccin theme"
      rm -f $DOTFILES_DIR/config/iterm/catppuccin-mocha.itermcolors.new
    fi
  else
    echo "Catppuccin theme not installed - skipping"
  fi

fi

# ============================================
# Tmux Plugin Manager
# ============================================

if [ -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "Updating tmux plugin manager (TPM)..."
  if git -C "$HOME/.tmux/plugins/tpm" pull --quiet 2>/dev/null; then
    echo "  ✓ TPM updated"
    echo "  Note: Run prefix+U in tmux to update tmux plugins"
    UPDATES_PERFORMED=1
  else
    echo "  ✗ Failed to update TPM"
  fi
else
  echo "TPM not installed - skipping"
fi

# ============================================
# Vim Configuration
# ============================================

if [ -d "$HOME/vim-config/.git" ]; then
  echo "Updating vim-config repository..."
  if git -C "$HOME/vim-config" pull --quiet 2>/dev/null; then
    echo "  ✓ vim-config updated"
    UPDATES_PERFORMED=1
  else
    echo "  ✗ Failed to update vim-config"
  fi
else
  echo "vim-config not installed or not a git repository - skipping"
fi

# Update Vundle
if [ -d "$HOME/.vim/bundle/Vundle.vim/.git" ]; then
  echo "Updating Vundle plugin manager..."
  if git -C "$HOME/.vim/bundle/Vundle.vim" pull --quiet 2>/dev/null; then
    echo "  ✓ Vundle updated"
    echo "  Note: Run :PluginUpdate in vim to update vim plugins"
    UPDATES_PERFORMED=1
  else
    echo "  ✗ Failed to update Vundle"
  fi
else
  echo "Vundle not installed - skipping"
fi

# ============================================
# Neovim Plugins
# ============================================

if command -v nvim >/dev/null 2>&1 && [ -d "$HOME/.config/nvim" ]; then
  echo "Updating Neovim plugins..."
  # Use Lazy.nvim's sync command (updates and cleans plugins)
  if nvim --headless "+Lazy! sync" +qa 2>/dev/null; then
    echo "  ✓ Neovim plugins updated"
    UPDATES_PERFORMED=1
  else
    echo "  ✗ Failed to update Neovim plugins (you can manually run :Lazy update)"
  fi
else
  echo "Neovim not installed or not configured - skipping"
fi

# ============================================
# Python Packages
# ============================================

if command -v pip3 >/dev/null 2>&1; then
  # Check if visidata packages are installed
  if pip3 list --user 2>/dev/null | grep -q "xlrd\|openpyxl"; then
    echo "Updating Python packages for visidata..."
    if pip3 install --user --upgrade xlrd openpyxl 2>/dev/null; then
      echo "  ✓ Python packages updated"
      UPDATES_PERFORMED=1
    else
      echo "  ✗ Failed to update Python packages"
    fi
  else
    echo "Python packages (xlrd, openpyxl) not installed - skipping"
  fi
else
  echo "pip3 not installed - skipping Python packages"
fi

# ============================================
# Package Manager Updates
# ============================================

echo ""
echo "Checking package managers..."

# Homebrew (macOS)
if [ "$(uname)" = "Darwin" ] && command -v brew >/dev/null 2>&1; then
  read -p "Update Homebrew packages? (y/n): " choice
  if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
    echo "Updating Homebrew..."
    brew update
    brew upgrade
    brew cleanup
    UPDATES_PERFORMED=1
  fi
fi

# APT (Linux)
if [ "$(uname)" = "Linux" ] && command -v apt-get >/dev/null 2>&1; then
  read -p "Update APT packages? (y/n): " choice
  if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
    echo "Updating APT packages..."
    sudo apt update
    sudo apt upgrade -y
    sudo apt autoremove -y
    UPDATES_PERFORMED=1
  fi
fi

# ============================================
# Summary
# ============================================

echo ""
echo "================================"
echo "Update Complete!"
echo "================================"
echo ""

if [ $UPDATES_PERFORMED -eq 1 ]; then
  echo "Updates were performed. Consider:"
  echo "  1. Restart your shell or run: source ~/.zshrc (or ~/.bashrc)"
  echo "  2. If using tmux, press prefix+U to update tmux plugins"
  echo "  3. If using vim, run :PluginUpdate to update vim plugins"
else
  echo "No updates were performed or all components were already up to date."
fi

echo ""
