#!/bin/bash
#
# Cleanup script for Antigen → Antidote migration
#
# This script removes old Antigen/oh-my-zsh installations after verifying
# the Antidote migration was successful.
#
# IMPORTANT: Only run this after verifying your new zsh configuration works!
#
# Usage: ./cleanup-antigen-migration.sh
#

set -e  # Exit on error

DOTFILES_DIR=~/dotfiles

echo "================================"
echo "Antigen Migration Cleanup"
echo "================================"
echo ""
echo "This script will remove old Antigen/oh-my-zsh installations."
echo ""
echo "IMPORTANT: Only proceed if you've verified the new Antidote setup works!"
echo "          Test by running: exec zsh"
echo ""

# Verify Antidote is working before cleanup
if ! command -v antidote >/dev/null 2>&1; then
  echo "ERROR: Antidote command not found!"
  echo "The new setup may not be working correctly."
  echo "Please verify your zsh configuration before running cleanup."
  exit 1
fi

# Check if Antidote plugins are loaded
if [ ! -f "$HOME/.zsh_plugins.zsh" ]; then
  echo "WARNING: Antidote plugin file not found at ~/.zsh_plugins.zsh"
  echo "This suggests plugins may not be loading correctly."
  read -p "Continue anyway? (y/n): " choice
  if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
    echo "Cleanup cancelled."
    exit 0
  fi
fi

echo "The following items will be removed:"
echo ""
echo "Directories:"
[ -d "$HOME/.oh-my-zsh" ] && echo "  • ~/.oh-my-zsh (oh-my-zsh installation)"
[ -d "$HOME/.antigen" ] && echo "  • ~/.antigen (antigen cache)"
[ -d "$HOME/.powerlevel10k" ] && echo "  • ~/.powerlevel10k (manual P10k installation)"
echo ""
echo "Files:"
[ -f "$DOTFILES_DIR/antigen.zsh" ] && echo "  • ~/dotfiles/antigen.zsh (antigen script)"
[ -f "$HOME/.p10k.zsh" ] && echo "  • ~/.p10k.zsh (old P10k config symlink)"
[ -f "$HOME/.zshrc.backup" ] && echo "  • ~/.zshrc.backup (oh-my-zsh backup)"
echo ""
echo "The following will be archived (renamed to .old):"
[ -d "$DOTFILES_DIR/config/antigen" ] && echo "  • config/antigen → config/antigen.old"
[ -f "$DOTFILES_DIR/config/p10k/p10k-catppuccin.zsh" ] && echo "  • config/p10k/p10k-catppuccin.zsh → p10k-catppuccin.zsh.old"
echo ""
read -p "Proceed with cleanup? (y/n): " confirm

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "Cleanup cancelled."
  exit 0
fi

echo ""
echo "Starting cleanup..."
echo ""

# Track what was removed
removed_count=0

# Remove oh-my-zsh
if [ -d "$HOME/.oh-my-zsh" ]; then
  echo "Removing oh-my-zsh installation..."
  rm -rf "$HOME/.oh-my-zsh"
  echo "  ✓ Removed ~/.oh-my-zsh"
  ((removed_count++))
else
  echo "  • ~/.oh-my-zsh not found - skipping"
fi

# Remove Antigen
if [ -d "$HOME/.antigen" ]; then
  echo "Removing Antigen cache..."
  rm -rf "$HOME/.antigen"
  echo "  ✓ Removed ~/.antigen"
  ((removed_count++))
else
  echo "  • ~/.antigen not found - skipping"
fi

# Remove manual Powerlevel10k installation
if [ -d "$HOME/.powerlevel10k" ]; then
  echo "Removing manual Powerlevel10k installation..."
  rm -rf "$HOME/.powerlevel10k"
  echo "  ✓ Removed ~/.powerlevel10k"
  ((removed_count++))
else
  echo "  • ~/.powerlevel10k not found - skipping"
fi

# Remove Antigen script
if [ -f "$DOTFILES_DIR/antigen.zsh" ]; then
  echo "Removing Antigen script..."
  rm -f "$DOTFILES_DIR/antigen.zsh"
  echo "  ✓ Removed ~/dotfiles/antigen.zsh"
  ((removed_count++))
else
  echo "  • ~/dotfiles/antigen.zsh not found - skipping"
fi

# Remove old P10k config symlink
if [ -f "$HOME/.p10k.zsh" ] || [ -L "$HOME/.p10k.zsh" ]; then
  echo "Removing old P10k config symlink..."
  rm -f "$HOME/.p10k.zsh"
  echo "  ✓ Removed ~/.p10k.zsh"
  ((removed_count++))
else
  echo "  • ~/.p10k.zsh not found - skipping"
fi

# Remove zshrc backup
if [ -f "$HOME/.zshrc.backup" ]; then
  echo "Removing .zshrc backup..."
  rm -f "$HOME/.zshrc.backup"
  echo "  ✓ Removed ~/.zshrc.backup"
  ((removed_count++))
else
  echo "  • ~/.zshrc.backup not found - skipping"
fi

echo ""
echo "Archiving old configs..."
echo ""

# Archive Antigen config directory
if [ -d "$DOTFILES_DIR/config/antigen" ]; then
  if [ -d "$DOTFILES_DIR/config/antigen.old" ]; then
    echo "  • config/antigen.old already exists - removing old backup first"
    rm -rf "$DOTFILES_DIR/config/antigen.old"
  fi
  mv "$DOTFILES_DIR/config/antigen" "$DOTFILES_DIR/config/antigen.old"
  echo "  ✓ Archived config/antigen → config/antigen.old"
  ((removed_count++))
else
  echo "  • config/antigen not found - skipping"
fi

# Archive old P10k config
if [ -f "$DOTFILES_DIR/config/p10k/p10k-catppuccin.zsh" ]; then
  if [ -f "$DOTFILES_DIR/config/p10k/p10k-catppuccin.zsh.old" ]; then
    echo "  • p10k-catppuccin.zsh.old already exists - removing old backup first"
    rm -f "$DOTFILES_DIR/config/p10k/p10k-catppuccin.zsh.old"
  fi
  mv "$DOTFILES_DIR/config/p10k/p10k-catppuccin.zsh" "$DOTFILES_DIR/config/p10k/p10k-catppuccin.zsh.old"
  echo "  ✓ Archived p10k-catppuccin.zsh → p10k-catppuccin.zsh.old"
  ((removed_count++))
else
  echo "  • config/p10k/p10k-catppuccin.zsh not found - skipping"
fi

# Remove .antigenrc symlink if it exists
if [ -L "$DOTFILES_DIR/.antigenrc" ]; then
  rm -f "$DOTFILES_DIR/.antigenrc"
  echo "  ✓ Removed ~/dotfiles/.antigenrc symlink"
  ((removed_count++))
fi

echo ""
echo "================================"
echo "Cleanup Complete!"
echo "================================"
echo ""
echo "Summary:"
echo "  • $removed_count items removed or archived"
echo ""
echo "Your new Antidote setup is now clean and ready to use."
echo ""
echo "Archived configs can be found at:"
echo "  • $DOTFILES_DIR/config/antigen.old"
echo "  • $DOTFILES_DIR/config/p10k/p10k-catppuccin.zsh.old"
echo ""
echo "You can safely delete the .old files later if you don't need them."
echo ""
echo "To verify everything still works, run:"
echo "  exec zsh"
echo ""
