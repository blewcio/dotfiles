#!/bin/bash
#
# macOS Installation Script
# Installs Homebrew, packages from Brewfile, and optionally configures system preferences

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="$SCRIPT_DIR/Brewfile"
BREWDIR="$HOME/.homebrew"
MACOS_SH="$SCRIPT_DIR/default_macos_settings.sh"

# Install homebrew
# Uses a local prefix ($BREWDIR) so Homebrew lives inside ~/dotfiles-managed space
# and does not require sudo. The official installer honours HOMEBREW_PREFIX.
# Local install takes priority over any system-wide Homebrew.
if [ -d "$BREWDIR/bin" ] && [ -x "$BREWDIR/bin/brew" ]; then
  echo "Homebrew already present at $BREWDIR. Using local installation..."
  eval "$("$BREWDIR/bin/brew" shellenv)"
elif command -v brew >/dev/null 2>&1; then
  echo "Warning: No local Homebrew found at $BREWDIR. Falling back to system Homebrew ($(command -v brew))."
  echo "Packages will be installed to the system prefix. To use a local sudo-free install, remove system Homebrew first."
else
  echo "Installing Homebrew into $BREWDIR (no sudo required)..."
  git clone https://github.com/Homebrew/brew "$BREWDIR"
  if [ $? -ne 0 ]; then
    echo "Homebrew installation failed. Aborting..."
    exit 1
  fi
  eval "$("$BREWDIR/bin/brew" shellenv)"
  brew update --force --quiet
fi

# Install all packages from Brewfile
if [ -f "$BREWFILE" ]; then
  echo "Installing packages from Brewfile..."
  brew bundle --file="$BREWFILE"
else
  echo "Brewfile not found at $BREWFILE. Skipping package installation..."
fi

if [ $? -ne 0 ]; then
  echo "Bundle installation failed. Aborting..."
  exit 1
fi

# Optionally configure macOS system preferences
read -p "Do you want to configure macOS system preferences? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  if [ -f "$MACOS_SH" ]; then
    echo "Configuring macOS system preferences..."
    bash "$MACOS_SH"
  else
    echo "default_macos_settings.sh not found at $MACOS_SH. Skipping..."
  fi
fi

# Configure Powerlevel10k prompt if available
if command -v p10k >/dev/null 2>&1; then
  echo "Configuring Powerlevel10k prompt..."
  p10k configure
else
  echo "Powerlevel10k not found. Skipping prompt configuration..."
  echo "You can run 'p10k configure' later after installing zsh plugins."
fi
