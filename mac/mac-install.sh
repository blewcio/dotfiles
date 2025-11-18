#!/bin/bash
#
# macOS Installation Script
# Installs Homebrew, packages from Brewfile, and optionally configures system preferences

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="$SCRIPT_DIR/Brewfile"
MACOS_SH="$SCRIPT_DIR/macos.sh"

# Install homebrew
echo "Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

if [ $? -ne 0 ]; then
  echo "Homebrew installation failed. Aborting..."
  exit 1
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
    echo "macos.sh not found at $MACOS_SH. Skipping..."
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
