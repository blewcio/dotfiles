# Install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

if [ ! $? -eq 0 ]; then
  echo "Homebrew not installed. Aborting..."
  return -1
fi

# Install productivity helpers
brew install --cask \
 rectangle \     # Move windows around with keys
 alt-tab   \     # Windows like tab
 alfred    \     # Additional search and much more
 pock      \     # Touchbar config
 cheatsheet      # Show shotcuts on screen
# customssshortcut # Define own shortcuts in Apps

if [ $? -eq 0 ]; then
  echo "Productivity helpers installed successfully"
fi

# Install basic tools
brew install --cask \
  iterm2 \
  macvim \
  google-chrome \
  amazon-photos  \
  messenger \
  miro \
  zoom \
  gimp 

# Install basic tools for improved terminal
brew install \
  git        \
  bat        \  # Improved cat
  exa        \  # Improved ls
  tree       \
  tldr       \  # Improved man
  jq         \    # Commandline JSON processor
  htop       \  # Improved top
  jdupes     \ # Duplicate file finder
  fzf        \   # Fuzzy finder
  fasd       \  # Quick access to (recent) files and directories
  ripgrep    \ # Improved grep
  tmux       \ # Improvee screen
  wakeonlan  \
  nmap       \ # Network scanner
  ranger     \ # Vi like file browser
  mas        \  #install from Appstore via Terrminal)
  speedtesst-cli \ Network speed test
  terminal-notifier \ # Notify via notification center
  ffmpeg

# TODO: Config fzf & fasd

# TODO: Config zsh
# Plugins
# Powerline

# Install quick look plugins
brew install --cask \
    qlcolorcode \
    qlstephen \
    qlmarkdown \
    qlvideo \
    quicklook-json \
    qlprettypatch \
    quicklook-csv \
    suspicious-package \
    betterzip \
    webpquicklook

mas install 1437630108  # HomeAtmo Lite
mas install 416581096   # QuickCal for widget in notification center
mas install 1453365242  # Brothere P Touch
mas install 1534707384  # Hue App or we love lights TODO
mas install 1474804779  # Juststream for file to Chromecast streaming

# Install additional tools
brew install --cask \
  appcleaner \
  mysides \ # Simple CLI based sidebar configuration
  brave-browser  \
  caffeine \ # Dont let mac sleep
  android-file-transfer \
  anydo 

brew install \
  gnumeric

