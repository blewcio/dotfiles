# Install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

if [ ! $? -eq 0 ]; then
  echo "Homebrew not installed. Aborting..."
  return -1
fi

# Install all packages from Brewfile
brew bundle install

# Configure powerline
p10k configure
