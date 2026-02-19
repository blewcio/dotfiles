#!/bin/bash
#
# Linux Installation Script
# Installs packages via apt (Debian/Ubuntu) and optional tools like tldr

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# ============================================
# apt Packages (Debian/Ubuntu)
# ============================================

if command -v apt-get >/dev/null 2>&1; then
  # Check if at least some key packages are missing
  missing_packages=0
  for pkg in tmux bat fzf ripgrep; do
    if ! dpkg -l 2>/dev/null | grep -q "^ii  $pkg "; then
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

# ============================================
# tldr (Simplified Man Pages)
# ============================================

# Note: apt version is often unavailable on Debian, so we use pip3 or cargo
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
