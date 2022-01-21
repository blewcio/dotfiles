# Install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install productivity helpers
brew install --cask \
 rectangle \     # Move windows around with keys
 alt-tab   \     # Windows like tab
 alfred    \     # Additional search and much more
 pock            # Touchbar config

# Install basic tools
brew install --cask \
  iterm2 \
  mysides \ # Simple CLI based sidebar configuration
  chrome-browser \
  brave-browser  \
  miro \
  gimp \
  gnumeric

# Install additional tools
brew install --cask \
  juststream \
  # NX Studio
  # Brother P touch editor

# Install basic tools for improved terminal
brew install \
  bat \  # Improved cat
  exa \  # Improved ls
  tree\
  jq\
  htop\
  fzf\
  fasd\
  jdupes\
  ripgrep\
  tmux\
  wakeonlan\
  nmap \ # Network scanner
  ranger\
  ffmpeg\
  mas \  #install from Appstore via Terrminal)
  speedtesst-cli\
  terminal-notifier

# TODO: Config fzf & fasd
# TODO: Config zsh
# Plugins
# Powerline


pock
