#!/bin/sh
#
# Install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

if [ ! $? -eq 0 ]; then
  echo "Homebrew not installed. Aborting..."
  return -1
fi

# Install all packages from Brewfile
if [ -f "Brewfile" ]; then
  brew bundle install
fi

if [ ! $? -eq 0 ]; then
  echo "Budnle installation failed. Aborting..."
  return -1
fi

# Configure powerline
p10k configure
