#!/usr/bin/env bash

# Restore macOS system defaults from exported files
# This script imports previously exported settings to restore your macOS configuration

EXPORT_DIR="${HOME}/dotfiles/mac/exported-defaults"
BACKUP_DIR="${HOME}/dotfiles/mac/defaults-backup-$(date +%Y%m%d-%H%M%S)"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "================================"
echo "macOS Defaults Restore Script"
echo "================================"
echo ""

# Check if exported defaults exist
if [ ! -d "$EXPORT_DIR" ]; then
  echo -e "${RED}Error: Exported defaults directory not found at $EXPORT_DIR${NC}"
  echo "Run export-defaults.sh first to export your current settings."
  exit 1
fi

# Check if any binary plist files exist
if ! ls "$EXPORT_DIR"/*.binary.plist 1> /dev/null 2>&1; then
  echo -e "${RED}Error: No binary plist files found in $EXPORT_DIR${NC}"
  echo "Run export-defaults.sh first to export your current settings."
  exit 1
fi

echo "Found exported defaults in: $EXPORT_DIR"
echo ""

# Ask user if they want to backup current settings first
read -p "Backup current settings before restoring? (recommended) [Y/n]: " backup_choice
if [[ "$backup_choice" != "n" && "$backup_choice" != "N" ]]; then
  echo ""
  echo -e "${YELLOW}Creating backup of current settings...${NC}"
  mkdir -p "$BACKUP_DIR"

  # Backup current settings
  defaults export com.apple.dock "$BACKUP_DIR/dock.binary.plist" 2>/dev/null
  defaults export com.apple.finder "$BACKUP_DIR/finder.binary.plist" 2>/dev/null
  defaults export NSGlobalDomain "$BACKUP_DIR/global.binary.plist" 2>/dev/null
  defaults export com.apple.AppleMultitouchTrackpad "$BACKUP_DIR/trackpad.binary.plist" 2>/dev/null

  echo -e "${GREEN}Backup created at: $BACKUP_DIR${NC}"
  echo ""
fi

# Function to restore a domain
restore_domain() {
  local domain=$1
  local file=$2
  local name=$3

  if [ -f "$file" ]; then
    echo -e "${YELLOW}Restoring $name settings...${NC}"
    if defaults import "$domain" "$file" 2>/dev/null; then
      echo -e "${GREEN}✓ $name settings restored${NC}"
      return 0
    else
      echo -e "${RED}✗ Failed to restore $name settings${NC}"
      return 1
    fi
  else
    echo -e "${YELLOW}⊘ $name settings file not found, skipping${NC}"
    return 2
  fi
}

# Ask user what to restore
echo "What would you like to restore?"
echo "  1) All settings"
echo "  2) Dock only"
echo "  3) Finder only"
echo "  4) Global/System settings only"
echo "  5) Trackpad only"
echo "  6) Custom selection"
read -p "Enter choice [1-6]: " restore_choice

echo ""
echo "================================"
echo "Restoring Settings..."
echo "================================"
echo ""

case "$restore_choice" in
  1)
    # Restore all
    restore_domain "com.apple.dock" "$EXPORT_DIR/dock.binary.plist" "Dock"
    restore_domain "com.apple.finder" "$EXPORT_DIR/finder.binary.plist" "Finder"
    restore_domain "NSGlobalDomain" "$EXPORT_DIR/global.binary.plist" "Global"
    restore_domain "com.apple.AppleMultitouchTrackpad" "$EXPORT_DIR/trackpad.binary.plist" "Trackpad"
    RESTART_ALL=true
    ;;
  2)
    restore_domain "com.apple.dock" "$EXPORT_DIR/dock.binary.plist" "Dock"
    RESTART_DOCK=true
    ;;
  3)
    restore_domain "com.apple.finder" "$EXPORT_DIR/finder.binary.plist" "Finder"
    RESTART_FINDER=true
    ;;
  4)
    restore_domain "NSGlobalDomain" "$EXPORT_DIR/global.binary.plist" "Global"
    ;;
  5)
    restore_domain "com.apple.AppleMultitouchTrackpad" "$EXPORT_DIR/trackpad.binary.plist" "Trackpad"
    ;;
  6)
    # Custom selection
    echo "Select which settings to restore (y/n for each):"
    read -p "Dock? [y/N]: " choice
    [[ "$choice" =~ ^[Yy]$ ]] && restore_domain "com.apple.dock" "$EXPORT_DIR/dock.binary.plist" "Dock" && RESTART_DOCK=true

    read -p "Finder? [y/N]: " choice
    [[ "$choice" =~ ^[Yy]$ ]] && restore_domain "com.apple.finder" "$EXPORT_DIR/finder.binary.plist" "Finder" && RESTART_FINDER=true

    read -p "Global/System? [y/N]: " choice
    [[ "$choice" =~ ^[Yy]$ ]] && restore_domain "NSGlobalDomain" "$EXPORT_DIR/global.binary.plist" "Global"

    read -p "Trackpad? [y/N]: " choice
    [[ "$choice" =~ ^[Yy]$ ]] && restore_domain "com.apple.AppleMultitouchTrackpad" "$EXPORT_DIR/trackpad.binary.plist" "Trackpad"
    ;;
  *)
    echo -e "${RED}Invalid choice. Exiting.${NC}"
    exit 1
    ;;
esac

echo ""
echo "================================"
echo "Applying Changes..."
echo "================================"
echo ""

# Restart affected services
if [ "$RESTART_ALL" = true ]; then
  echo -e "${YELLOW}Restarting Dock and Finder to apply changes...${NC}"
  killall Dock 2>/dev/null
  killall Finder 2>/dev/null
  echo -e "${GREEN}✓ Services restarted${NC}"
else
  if [ "$RESTART_DOCK" = true ]; then
    echo -e "${YELLOW}Restarting Dock...${NC}"
    killall Dock 2>/dev/null
    echo -e "${GREEN}✓ Dock restarted${NC}"
  fi

  if [ "$RESTART_FINDER" = true ]; then
    echo -e "${YELLOW}Restarting Finder...${NC}"
    killall Finder 2>/dev/null
    echo -e "${GREEN}✓ Finder restarted${NC}"
  fi
fi

echo ""
echo "================================"
echo "Restore Complete!"
echo "================================"
echo ""
echo "Some settings may require logging out and back in to take full effect."

if [[ "$backup_choice" != "n" && "$backup_choice" != "N" ]]; then
  echo ""
  echo "Your previous settings were backed up to:"
  echo "  $BACKUP_DIR"
  echo ""
  echo "To restore the backup if needed:"
  echo "  defaults import com.apple.dock $BACKUP_DIR/dock.binary.plist"
  echo "  killall Dock"
fi

echo ""
