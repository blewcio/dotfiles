#!/bin/bash
#
# Dotfiles Deployment Script
# This script is idempotent and can be safely run multiple times
#
# Usage: ./deploy.sh
#

DOTFILES_DIR=~/dotfiles
SHELLRC_FILE=shellrc.sh

echo "================================"
echo "Dotfiles Deployment Starting..."
echo "================================"
echo ""

# ============================================
# Shell Plugin Managers
# ============================================

# Install zsh plugin manager
if [[ "$SHELL" == *zsh ]]; then

  # Install plugin manager for zsh
  if [ ! -f "${DOTFILES_DIR}/antigen.zsh" ]; then
    echo "Installing Antigen plugin manager..."
    curl -L git.io/antigen > ${DOTFILES_DIR}/antigen.zsh
  else
    echo "Antigen already installed - skipping"
  fi

  # Re-link antigenrc to avoid error messages
  antigenrc=$DOTFILES_DIR/config/antigenrc
  if [[ -r "$antigenrc" ]]; then
    ln -sf $antigenrc $DOTFILES_DIR/.antigenrc
  fi
  unset antigenrc
fi

# Install bash plugin manager and enhancements
if [[ "$SHELL" == *bash ]] || command -v bash >/dev/null 2>&1; then

  # Install ble.sh (Bash Line Editor) for autosuggestions, syntax highlighting, and enhanced completion
  if [ ! -d "$HOME/.local/share/blesh" ]; then
    echo "Installing ble.sh (Bash Line Editor)..."

    # Clone and install ble.sh
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
  # macOS: brew install bash-completion@2
  # Linux: apt install bash-completion (usually pre-installed)

fi

# ============================================
# Platform-Specific Configuration
# ============================================

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

    # Download iTerm2 integration script
    if [ ! -f "$HOME/.iterm2_shell_integration.bash" ] && [ ! -f "$HOME/.iterm2_shell_integration.zsh" ]; then
      echo "Installing iTerm2 shell integration..."
      wget -qO- https://iterm2.com/misc/install_shell_integration.sh | bash
    else
      echo "iTerm2 shell integration already installed - skipping"
    fi

    # Download iTerm2 Catppuccin theme
    mkdir -p $DOTFILES_DIR/config/iTerm2
    if [ ! -f "$DOTFILES_DIR/config/iTerm2/catppuccin-mocha.itermcolors" ]; then
      echo "Downloading Catppuccin Mocha theme for iTerm2..."
      curl -L https://github.com/catppuccin/iterm2/raw/main/colors/catppuccin-mocha.itermcolors \
        -o $DOTFILES_DIR/config/iTerm2/catppuccin-mocha.itermcolors
      echo "Catppuccin theme downloaded to config/iTerm2/"
    else
      echo "Catppuccin theme already downloaded - skipping"
    fi

  # FZF install, useful key bindings
  if [[ -x "$(command -v fzf)" ]]; then
    # Check if FZF is already configured in shell files
    if ! grep -q "fzf" "$HOME/.zshrc" 2>/dev/null && ! grep -q "fzf" "$HOME/.bashrc" 2>/dev/null; then
      echo "Installing FZF key bindings..."
      $(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc
    else
      echo "FZF already configured - skipping"
    fi
  fi
fi

# ============================================
# Oh-My-Zsh Plugins
# ============================================

# Install oh-my-zsh addons
if [ -d "$HOME/.oh-my-zsh" ]; then
  ZSH_CUSTOM=$HOME/.oh-my-zsh/custom

  # Clone plugins if they don't already exist
  echo "Installing oh-my-zsh plugins..."

  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autocomplete" ]; then
    git clone --depth 1 https://github.com/marlonrichert/zsh-autocomplete.git $ZSH_CUSTOM/plugins/zsh-autocomplete 2>/dev/null || echo "  - zsh-autocomplete already exists or clone failed"
  fi

  if [ ! -d "$ZSH_CUSTOM/plugins/fast-syntax-highlighting" ]; then
    git clone --depth 1 https://github.com/zdharma-continuum/fast-syntax-highlighting.git $ZSH_CUSTOM/plugins/fast-syntax-highlighting 2>/dev/null || echo "  - fast-syntax-highlighting already exists or clone failed"
  fi

  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting 2>/dev/null || echo "  - zsh-syntax-highlighting already exists or clone failed"
  fi

  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions 2>/dev/null || echo "  - zsh-autosuggestions already exists or clone failed"
  fi

  echo "  oh-my-zsh plugins installation complete"

  # Automatically add plugins line to .zshrc
  ZSHRC="$HOME/.zshrc"
  PLUGINS_LINE="plugins=(fasd alias-finder virtualenv direnv git zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting zsh-autocomplete)"

  if [ -f "$ZSHRC" ]; then
    # Check if plugins line already exists
    if grep -q "^plugins=(" "$ZSHRC"; then
      echo "Plugins line already exists in .zshrc - skipping"
    else
      # Find the line with "source \$ZSH/oh-my-zsh.sh" and insert before it
      if grep -q "source.*oh-my-zsh.sh" "$ZSHRC"; then
        # Create a backup
        cp "$ZSHRC" "$ZSHRC.backup"

        # Insert plugins line before the source line
        sed -i.tmp "/source.*oh-my-zsh.sh/i\\
$PLUGINS_LINE\\
" "$ZSHRC"
        rm -f "$ZSHRC.tmp"

        echo "Added plugins line to .zshrc"
      else
        echo "Warning: oh-my-zsh source line not found in .zshrc - please add plugins line manually"
      fi
    fi
  else
    echo "Warning: .zshrc not found - skipping plugins line addition"
  fi
else
  echo "oh-my-zsh not installed - skipping plugin installation"
fi

# ============================================
# Shell RC Files Configuration
# ============================================

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

# ============================================
# Additional Packages and Tools
# ============================================

# Check if python packages should be installed
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

# Install tmux plugin manager
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "Installing tmux plugin manager (TPM)..."
  mkdir -p ~/.tmux/plugins
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
  echo "Tmux plugin manager already installed - skipping"
fi

# Install base Linux packages, if needed
if [ "$(uname)" = "Linux" ]; then
  # Check if running Debian/Ubuntu
  if command -v apt-get >/dev/null 2>&1; then
    # Check if at least some key packages are missing
    missing_packages=0
    for pkg in tmux bat fzf ripgrep; do
      if ! dpkg -l | grep -q "^ii  $pkg "; then
        missing_packages=1
        break
      fi
    done

    if [ $missing_packages -eq 1 ]; then
      echo ""
      echo "Linux packages can be installed via:"
      echo "  1. Quick install (basic tools only)"
      echo "  2. Full install using debian-packages.sh (recommended)"
      read -p "Choose installation method (1/2) or skip (n): " choice

      if [ "$choice" = "1" ]; then
        echo "Installing basic Linux packages..."
        packages="tmux bat glow vim fzf fasd eza pixz lbzip2 rsync ripgrep zoxide wget qemu-guest-agent fd-find git btop iperf iperf3 nfs-common bash-completion"
        sudo apt install -y $packages
      elif [ "$choice" = "2" ]; then
        echo "Running comprehensive package installation..."
        if [ -f "$DOTFILES_DIR/debian-packages.sh" ]; then
          sudo bash "$DOTFILES_DIR/debian-packages.sh" --minimal
        else
          echo "debian-packages.sh not found. Using basic installation..."
          packages="tmux bat glow vim fzf fasd eza pixz lbzip2 rsync ripgrep zoxide wget qemu-guest-agent fd-find git btop iperf iperf3 nfs-common bash-completion"
          sudo apt install -y $packages
        fi
      else
        echo "Skipping Linux package installation"
      fi
    else
      echo "Key Linux packages already installed - skipping"
    fi
  else
    echo "Non-Debian system detected - skipping apt package installation"
  fi

  # Install tldr (tealdeer) - apt version often unavailable on Debian
  if ! command -v tldr >/dev/null 2>&1; then
    read -p "Install tldr (simplified man pages) via pip3 or cargo? (y/n): " choice
    if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
      # Try pip3 first (most reliable cross-platform method)
      if command -v pip3 >/dev/null 2>&1; then
        echo "Installing tldr via pip3..."
        pip3 install --user tldr
      # Try cargo (Rust) for tealdeer (faster implementation)
      elif command -v cargo >/dev/null 2>&1; then
        echo "Installing tealdeer (Rust tldr client) via cargo..."
        cargo install tealdeer
        # Create tldr symlink if tealdeer was installed
        if command -v tealdeer >/dev/null 2>&1; then
          mkdir -p ~/.local/bin
          ln -sf $(which tealdeer) ~/.local/bin/tldr
        fi
      else
        echo "Neither pip3 nor cargo available - skipping tldr installation"
        echo "  Install with: pip3 install tldr  OR  cargo install tealdeer"
      fi
    fi
  else
    echo "tldr already installed - skipping"
  fi
fi

# ============================================
# Symlink Configuration Files
# ============================================

# TODO: Switch linking to stow (link farm management)
# Link configuration files
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
bat cache --build

# Rebuild bat cache with new themes
if command -v bat >/dev/null 2>&1; then
  bat cache --build >/dev/null 2>&1
  echo "✓ Rebuilt bat cache"
fi

mkdir -p ~/.config/fastfetch
ln -sf $DOTFILES_DIR/config/fastfetch/config.jsonc ~/.config/fastfetch/config.jsonc

mkdir -p ~/.config/yazi
ln -sf $DOTFILES_DIR/config/yazi/yazi.toml ~/.config/yazi/yazi.toml
ln -sf $DOTFILES_DIR/config/yazi/themes/themes/mocha/catppuccin-mocha-blue.toml ~/.config/yazi/theme.toml

mkdir -p ~/.config/lsd
ln -sf $DOTFILES_DIR/config/lsd/themes/themes/catppuccin-mocha/colors.yaml ~/.config/lsd/colors.yaml
ln -sf $DOTFILES_DIR/config/lsd/config.yaml ~/.config/lsd/config.yaml

mkdir -p ~/.config/delta/themes
ln -sf $DOTFILES_DIR/config/delta/themes/catppuccin.gitconfig ~/.config/delta/themes/catppuccin.gitconfig

mkdir -p ~/.config/btop/themes
ln -sf $DOTFILES_DIR/config/btop/btop.conf ~/.config/btop/btop.conf
ln -sf $DOTFILES_DIR/config/btop/themes/themes/catppuccin_mocha.theme ~/.config/btop/themes/catppuccin_mocha.theme

# lazygit
mkdir -p ~/.config/lazygit
if [ "$(uname)" = "Darwin" ]; then
  APPSUPPORT="$HOME/Library/Application Support"
  #Map burried config directory to .config
  ln -sf $APPSUPPORT/lazygit ~/.config/lazygit/AppSupport # Symlink directory
  ln -sf $DOTFILES_DIR/config/lazygit/config.yml ~/.config/lazygit/AppSupport/config.yml
else
  ln -sf $DOTFILES_DIR/config/lazygit/config.yml ~/.config/lazygit/config.yml
fi

# Link Powerlevel10k config with Catppuccin theme
ln -sf $DOTFILES_DIR/config/p10k/p10k-catppuccin.zsh ~/.p10k.zsh

# Claude code and desktop goes into two differnt dirs
mkdir -p ~/.claude # Code
ln -sf $DOTFILES_DIR/agents/CLAUDE.md ~/.claude/CLAUDE.md
ln -sf $DOTFILES_DIR/agents/skills ~/.claude/skills # Symlink directory
ln -sf $DOTFILES_DIR/agents/agents ~/.claude/agents # Symlink directory

mkdir -p ~/.config/claude # Desktop
ln -sf $DOTFILES_DIR/config/claude_desktop/claude_desktop_config.json ~/.config/claude/claude_desktop_config.json

mkdir -p ~/.config/opencode # Desktop
ln -sf $DOTFILES_DIR/config/opencode/opencode.json ~/.config/opencode/opencode.json
ln -sf $DOTFILES_DIR/agents/CLAUDE.md ~/.config/opencode/AGENTS.md

echo "Symlinks created successfully"

# ============================================
# Vim and Neovim Configuration
# ============================================

# Install vim and neovim configurations
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

# Pull Vundle package manager and install dependencies for Vim
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

  echo "  Neovim configuration symlinked. Plugins will auto-install on first launch."
  echo "  After launching nvim, run: :Mason to install LSP servers"
else
  echo "Neovim not installed. Skipping Neovim configuration."
  echo "  Install with: brew install neovim (macOS) or apt install neovim (Linux)"
fi

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
  if [ -f "$DOTFILES_DIR/config/iTerm2/catppuccin-mocha.itermcolors" ]; then
    echo ""
    echo "To apply Catppuccin theme to iTerm2:"
    echo "  1. Open iTerm2 → Preferences (Cmd+,)"
    echo "  2. Go to Profiles → Colors"
    echo "  3. Click 'Color Presets' dropdown → Import"
    echo "  4. Select: ~/dotfiles/config/iTerm2/catppuccin-mocha.itermcolors"
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

# ============================================
# Vim and Neovim Configuration
# ============================================

# Install vim and neovim configurations
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

# Pull Vundle package manager and install dependencies for Vim
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

  echo "  Neovim configuration symlinked. Plugins will auto-install on first launch."
  echo "  After launching nvim, run: :Mason to install LSP servers"
else
  echo "Neovim not installed. Skipping Neovim configuration."
  echo "  Install with: brew install neovim (macOS) or apt install neovim (Linux)"
fi

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
  if [ -f "$DOTFILES_DIR/config/iTerm2/catppuccin-mocha.itermcolors" ]; then
    echo ""
    echo "To apply Catppuccin theme to iTerm2:"
    echo "  1. Open iTerm2 → Preferences (Cmd+,)"
    echo "  2. Go to Profiles → Colors"
    echo "  3. Click 'Color Presets' dropdown → Import"
    echo "  4. Select: ~/dotfiles/config/iTerm2/catppuccin-mocha.itermcolors"
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
