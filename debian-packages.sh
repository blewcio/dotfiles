#!/bin/bash
#
# Debian/Ubuntu Package Installation Script
# Equivalent to mac/Brewfile for Homebrew
#
# Usage: sudo ./debian-packages.sh [--minimal|--full]
#

set -e

# Color output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Debian Package Installation${NC}"
echo -e "${GREEN}================================${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Please run with sudo${NC}"
  exit 1
fi

# Parse arguments
INSTALL_MODE="full"
if [ "$1" = "--minimal" ]; then
  INSTALL_MODE="minimal"
  echo -e "${YELLOW}Running in MINIMAL mode (CLI tools only)${NC}"
elif [ "$1" = "--full" ]; then
  INSTALL_MODE="full"
  echo -e "${YELLOW}Running in FULL mode (CLI + GUI apps)${NC}"
fi
echo ""

# ===== Basic Terminal Tools =====
BASIC_TOOLS=(
  tmux                 # Improved screen
  git
  git-delta            # Syntax highlighting for git diffs (via cargo/manual install - see below)
  lazygit              # Terminal UI for git (via manual install - see below)
  tldr                 # Improved man pages
  wget
  curl
  thefuck              # Correction of mistyped commands (via pip)
  fastfetch            # System information (faster than neofetch)
  universal-ctags      # ctags parser for tags in Vim
  bash-completion      # Bash completion support
)

# ===== Search & Navigation Tools =====
SEARCH_TOOLS=(
  fzf                  # Fuzzy finder
  fasd                 # Quick access to files and directories
  zoxide               # Smarter cd (Rust-based)
  fd-find              # Easy find (installed as 'fdfind', symlink to 'fd')
  ripgrep              # Improved grep
  broot                # Interactive file manager
)

# ===== Filesystem Tools =====
FILESYSTEM_TOOLS=(
  bat                  # Improved cat with syntax highlighting
  eza                  # Improved ls (exa replacement)
  lsd                  # Another improved ls
  dust                 # File/directory space utilization
  tree                 # Directory tree viewer
  age                  # File encryption
  hdparm               # HDD performance
  nnn                  # File manager
  yazi                 # Fast file manager (via cargo - see below)
  mc                   # Midnight Commander
  rename               # Perl rename utility (mass renamer)
)

# ===== Network & Performance =====
NETWORK_TOOLS=(
  wakeonlan            # Wake on LAN
  bandwhich            # Network utilization by process (via cargo)
  iperf
  iperf3
  nmap                 # Network scanner
  speedtest-cli        # Network speed test
  gping                # Plot ping (via cargo)
  hyperfine            # Process benchmarking (via cargo)
  httpie               # HTTP client
)

# ===== System Monitoring =====
SYSTEM_TOOLS=(
  duf                  # Disk usage (via manual install)
  htop                 # Improved top
  btop                 # Even better top
  bottom               # System monitoring (via cargo)
  glances              # Holistic monitoring
)

# ===== Multimedia Tools =====
MULTIMEDIA_TOOLS=(
  ffmpeg               # Video/audio processing
  libimage-exiftool-perl  # exiftool - metadata manipulation
  exiv2                # EXIF metadata tool
  pandoc               # Document converter
  viu                  # Terminal image viewer (via cargo)
)

# ===== Data Processing =====
DATA_TOOLS=(
  jq                   # JSON processor
  jless                # JSON viewer (via cargo)
  visidata             # Spreadsheet viewer (via pip)
  datamash             # Data analysis
  csvkit               # CSV processing (via pip)
  pdfgrep              # Grep for PDFs
  lnav                 # Log navigator
  miller               # CSV formatter
  peco                 # Interactive filtering
  poppler-utils        # PDF tools (pdftotext, etc.)
  choose               # Human-friendly cut (via cargo)
)

# ===== GUI Applications (Desktop Environment) =====
GUI_APPS=(
  neovim               # Modern Vim
  chromium-browser     # Open-source Chrome
  brave-browser        # Privacy browser (requires manual install)
  gimp                 # Image editor
  vlc                  # Media player
  slack-desktop        # Slack (via snap/manual)
  obsidian             # Notes (via AppImage/manual)
  sublime-text         # Text editor (via manual install)
  digikam              # Photo management
)

# Combine package lists based on mode
if [ "$INSTALL_MODE" = "minimal" ]; then
  ALL_PACKAGES=(
    "${BASIC_TOOLS[@]}"
    "${SEARCH_TOOLS[@]}"
    "${FILESYSTEM_TOOLS[@]}"
    "${NETWORK_TOOLS[@]}"
    "${SYSTEM_TOOLS[@]}"
    "${MULTIMEDIA_TOOLS[@]}"
    "${DATA_TOOLS[@]}"
  )
else
  ALL_PACKAGES=(
    "${BASIC_TOOLS[@]}"
    "${SEARCH_TOOLS[@]}"
    "${FILESYSTEM_TOOLS[@]}"
    "${NETWORK_TOOLS[@]}"
    "${SYSTEM_TOOLS[@]}"
    "${MULTIMEDIA_TOOLS[@]}"
    "${DATA_TOOLS[@]}"
    "${GUI_APPS[@]}"
  )
fi

# ===== APT Installable Packages =====
# Filter to only include packages available via apt
APT_PACKAGES=(
  tmux
  git
  wget
  curl
  universal-ctags
  bash-completion
  fzf
  fasd
  zoxide
  fd-find
  ripgrep
  broot
  bat
  eza
  lsd
  dust
  tree
  age
  hdparm
  nnn
  mc
  rename
  wakeonlan
  iperf
  iperf3
  nmap
  speedtest-cli
  httpie
  htop
  btop
  glances
  ffmpeg
  libimage-exiftool-perl
  exiv2
  pandoc
  jq
  datamash
  pdfgrep
  lnav
  miller
  peco
  poppler-utils
  neovim
  gimp
  vlc
)

# Add GUI packages if full mode
if [ "$INSTALL_MODE" = "full" ]; then
  APT_PACKAGES+=(chromium-browser digikam)
fi

echo -e "${BLUE}Updating apt cache...${NC}"
apt update

echo ""
echo -e "${BLUE}Installing APT packages...${NC}"
echo -e "${YELLOW}This may take several minutes${NC}"
echo ""

# Install packages with error handling
for package in "${APT_PACKAGES[@]}"; do
  if dpkg -l | grep -q "^ii  $package "; then
    echo -e "${GREEN}✓${NC} $package already installed"
  else
    echo -e "${YELLOW}Installing${NC} $package..."
    if apt install -y "$package" 2>/dev/null; then
      echo -e "${GREEN}✓${NC} $package installed"
    else
      echo -e "${RED}✗${NC} $package failed (may not be in apt repository)"
    fi
  fi
done

echo ""
echo -e "${GREEN}APT packages installation complete!${NC}"
echo ""

# ===== Additional Installation Instructions =====
echo -e "${YELLOW}================================${NC}"
echo -e "${YELLOW}Additional Manual Installations${NC}"
echo -e "${YELLOW}================================${NC}"
echo ""

echo -e "${BLUE}Cargo-based tools (install Rust first: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh):${NC}"
echo "  cargo install git-delta        # Syntax highlighting for git"
echo "  cargo install du-dust          # Disk usage"
echo "  cargo install bandwhich        # Network monitor (requires root)"
echo "  cargo install gping            # Ping with graph"
echo "  cargo install hyperfine        # Benchmarking"
echo "  cargo install bottom           # System monitor"
echo "  cargo install jless            # JSON viewer"
echo "  cargo install choose           # Human-friendly cut"
echo "  cargo install viu              # Terminal image viewer"
echo "  cargo install yazi-fm          # File manager"
echo ""

echo -e "${BLUE}Python-based tools (via pip3):${NC}"
echo "  pip3 install --user thefuck    # Command correction"
echo "  pip3 install --user visidata   # Spreadsheet viewer"
echo "  pip3 install --user csvkit     # CSV processing"
echo "  pip3 install --user tldr       # Simplified man pages"
echo ""

echo -e "${BLUE}Manual installations:${NC}"
echo "  lazygit:     https://github.com/jesseduffield/lazygit/releases"
echo "  fastfetch:   https://github.com/fastfetch-cli/fastfetch/releases"
echo "  duf:         https://github.com/muesli/duf/releases"
echo "  brave:       https://brave.com/linux/"
echo "  slack:       snap install slack --classic"
echo "  obsidian:    https://obsidian.md/download (AppImage)"
echo "  sublime:     https://www.sublimetext.com/docs/linux_repositories.html"
echo ""

echo -e "${BLUE}Symlinks needed:${NC}"
echo "  sudo ln -sf \$(which fdfind) /usr/local/bin/fd  # fd-find is installed as fdfind"
echo "  sudo ln -sf \$(which batcat) /usr/local/bin/bat # bat is installed as batcat"
echo ""

# ===== Linux-Specific GUI Alternatives =====
if [ "$INSTALL_MODE" = "full" ]; then
  echo -e "${YELLOW}================================${NC}"
  echo -e "${YELLOW}Linux Alternatives to macOS Apps${NC}"
  echo -e "${YELLOW}================================${NC}"
  echo ""
  echo "macOS App          → Linux Alternative"
  echo "─────────────────────────────────────────"
  echo "Arc Browser        → Brave, Chromium, Firefox"
  echo "Raycast            → Albert, Ulauncher, Rofi"
  echo "Caffeine           → Caffeine (apt install caffeine)"
  echo "iTerm2             → Alacritty, Kitty, Terminator"
  echo "HiddenBar          → (built into most Linux DEs)"
  echo "Alt-Tab            → (native in most window managers)"
  echo "AppCleaner         → apt autoremove / BleachBit"
  echo "LastPass           → Bitwarden, KeePassXC"
  echo "1Password          → Bitwarden, KeePassXC"
  echo "Logseq             → Logseq (AppImage)"
  echo "Notion             → Notion web app / Anytype"
  echo "Spotify            → Spotify (snap install spotify)"
  echo "Synology Drive     → Synology Drive (manual install)"
  echo "MonitorControl     → ddcutil, ddccontrol"
  echo "Stats              → btop, bottom, htop"
  echo "Geotag             → exiftool, DigiKam"
  echo "Amazon Photos      → rclone with Amazon Drive"
  echo "Messenger          → Caprine, Franz"
  echo "Zoom/Webex         → Native Linux clients available"
  echo "Gemini (duplicates)→ fdupes, fclones"
  echo "Cheatsheet         → cheat, tldr"
  echo "Android File Xfer  → Built-in via MTP"
  echo "SweetHome3D        → SweetHome3D (available for Linux)"
  echo ""
fi

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Installation Summary${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo "✓ APT packages installed"
echo "! Review manual installation instructions above"
echo "! Some tools require Rust (cargo) or Python (pip3)"
echo ""
echo "Next steps:"
echo "  1. Install Rust: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
echo "  2. Install cargo-based tools listed above"
echo "  3. Create symlinks for batcat → bat and fdfind → fd"
echo "  4. Run your dotfiles deployment: ~/dotfiles/deploy.sh"
echo ""
