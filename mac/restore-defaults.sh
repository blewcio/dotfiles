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

  # Backup current settings (all binary plists)
  for file in "$EXPORT_DIR"/*.binary.plist; do
    if [ -f "$file" ]; then
      filename=$(basename "$file")
      domain=$(echo "$filename" | sed 's/.binary.plist$//' | sed 's/-/./g')
      # Extract domain from filename mapping
      case "$filename" in
        "dock.binary.plist") domain="com.apple.dock" ;;
        "finder.binary.plist") domain="com.apple.finder" ;;
        "global.binary.plist") domain="NSGlobalDomain" ;;
        "trackpad.binary.plist") domain="com.apple.AppleMultitouchTrackpad" ;;
        "trackpad-bluetooth.binary.plist") domain="com.apple.driver.AppleBluetoothMultitouch.trackpad" ;;
        "mouse.binary.plist") domain="com.apple.driver.AppleBluetoothMultitouch.mouse" ;;
        "keyboard-shortcuts.binary.plist") domain="com.apple.symbolichotkeys" ;;
        "screencapture.binary.plist") domain="com.apple.screencapture" ;;
        "desktopservices.binary.plist") domain="com.apple.desktopservices" ;;
        "spacelauncher.binary.plist") domain="name.guoc.SpaceLauncher" ;;
        "spacelauncher-disabled-apps.binary.plist") domain="name.guoc.SpaceLauncher.disabled_apps" ;;
        "iterm2.binary.plist") domain="com.googlecode.iterm2" ;;
        "raycast.binary.plist") domain="com.raycast.macos" ;;
        "arc-browser.binary.plist") domain="company.thebrowser.Browser" ;;
        "stats.binary.plist") domain="eu.exelban.Stats" ;;
        "synology-drive.binary.plist") domain="com.synology.CloudStationUI" ;;
        *) continue ;;
      esac
      defaults export "$domain" "$BACKUP_DIR/$filename" 2>/dev/null
    fi
  done

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
echo ""
echo "  1) Everything (all settings)"
echo "  2) System settings only (Dock, Finder, Global, Desktop)"
echo "  3) Input devices only (Trackpad, Mouse, Keyboard)"
echo "  4) Applications only (iTerm2, Raycast, Arc, etc.)"
echo "  5) Custom selection (choose specific items)"
echo ""
read -p "Enter choice [1-5]: " restore_choice

echo ""
echo "================================"
echo "Restoring Settings..."
echo "================================"
echo ""

case "$restore_choice" in
  1)
    # Restore everything
    echo -e "${YELLOW}Restoring all settings...${NC}\n"

    # System
    restore_domain "NSGlobalDomain" "$EXPORT_DIR/global.binary.plist" "Global Domain"
    restore_domain "com.apple.dock" "$EXPORT_DIR/dock.binary.plist" "Dock"
    restore_domain "com.apple.finder" "$EXPORT_DIR/finder.binary.plist" "Finder"
    restore_domain "com.apple.screencapture" "$EXPORT_DIR/screencapture.binary.plist" "Screenshot"
    restore_domain "com.apple.desktopservices" "$EXPORT_DIR/desktopservices.binary.plist" "Desktop Services"

    # Input Devices
    restore_domain "com.apple.AppleMultitouchTrackpad" "$EXPORT_DIR/trackpad.binary.plist" "Trackpad"
    restore_domain "com.apple.driver.AppleBluetoothMultitouch.trackpad" "$EXPORT_DIR/trackpad-bluetooth.binary.plist" "Trackpad (Bluetooth)"
    restore_domain "com.apple.driver.AppleBluetoothMultitouch.mouse" "$EXPORT_DIR/mouse.binary.plist" "Mouse"
    restore_domain "com.apple.symbolichotkeys" "$EXPORT_DIR/keyboard-shortcuts.binary.plist" "Keyboard Shortcuts"

    # Applications
    restore_domain "name.guoc.SpaceLauncher" "$EXPORT_DIR/spacelauncher.binary.plist" "SpaceLauncher"
    restore_domain "name.guoc.SpaceLauncher.disabled_apps" "$EXPORT_DIR/spacelauncher-disabled-apps.binary.plist" "SpaceLauncher Disabled Apps"
    restore_domain "com.googlecode.iterm2" "$EXPORT_DIR/iterm2.binary.plist" "iTerm2"
    restore_domain "com.raycast.macos" "$EXPORT_DIR/raycast.binary.plist" "Raycast"
    restore_domain "company.thebrowser.Browser" "$EXPORT_DIR/arc-browser.binary.plist" "Arc Browser"
    restore_domain "eu.exelban.Stats" "$EXPORT_DIR/stats.binary.plist" "Stats"
    restore_domain "com.synology.CloudStationUI" "$EXPORT_DIR/synology-drive.binary.plist" "Synology Drive"

    RESTART_ALL=true
    ;;

  2)
    # System settings only
    echo -e "${YELLOW}Restoring system settings...${NC}\n"
    restore_domain "NSGlobalDomain" "$EXPORT_DIR/global.binary.plist" "Global Domain"
    restore_domain "com.apple.dock" "$EXPORT_DIR/dock.binary.plist" "Dock"
    restore_domain "com.apple.finder" "$EXPORT_DIR/finder.binary.plist" "Finder"
    restore_domain "com.apple.screencapture" "$EXPORT_DIR/screencapture.binary.plist" "Screenshot"
    restore_domain "com.apple.desktopservices" "$EXPORT_DIR/desktopservices.binary.plist" "Desktop Services"
    RESTART_SYSTEM=true
    ;;

  3)
    # Input devices only
    echo -e "${YELLOW}Restoring input device settings...${NC}\n"
    restore_domain "com.apple.AppleMultitouchTrackpad" "$EXPORT_DIR/trackpad.binary.plist" "Trackpad"
    restore_domain "com.apple.driver.AppleBluetoothMultitouch.trackpad" "$EXPORT_DIR/trackpad-bluetooth.binary.plist" "Trackpad (Bluetooth)"
    restore_domain "com.apple.driver.AppleBluetoothMultitouch.mouse" "$EXPORT_DIR/mouse.binary.plist" "Mouse"
    restore_domain "com.apple.symbolichotkeys" "$EXPORT_DIR/keyboard-shortcuts.binary.plist" "Keyboard Shortcuts"
    ;;

  4)
    # Applications only
    echo -e "${YELLOW}Restoring application settings...${NC}\n"
    restore_domain "name.guoc.SpaceLauncher" "$EXPORT_DIR/spacelauncher.binary.plist" "SpaceLauncher"
    restore_domain "name.guoc.SpaceLauncher.disabled_apps" "$EXPORT_DIR/spacelauncher-disabled-apps.binary.plist" "SpaceLauncher Disabled Apps"
    restore_domain "com.googlecode.iterm2" "$EXPORT_DIR/iterm2.binary.plist" "iTerm2"
    restore_domain "com.raycast.macos" "$EXPORT_DIR/raycast.binary.plist" "Raycast"
    restore_domain "company.thebrowser.Browser" "$EXPORT_DIR/arc-browser.binary.plist" "Arc Browser"
    restore_domain "eu.exelban.Stats" "$EXPORT_DIR/stats.binary.plist" "Stats"
    restore_domain "com.synology.CloudStationUI" "$EXPORT_DIR/synology-drive.binary.plist" "Synology Drive"
    RESTART_APPS=true
    ;;

  5)
    # Custom selection
    echo ""
    echo "Select which settings to restore (y/n for each):"
    echo ""
    echo -e "${YELLOW}=== System Settings ===${NC}"

    read -p "Global Domain (UI, keyboard, etc.)? [y/N]: " choice
    [[ "$choice" =~ ^[Yy]$ ]] && restore_domain "NSGlobalDomain" "$EXPORT_DIR/global.binary.plist" "Global Domain"

    read -p "Dock? [y/N]: " choice
    [[ "$choice" =~ ^[Yy]$ ]] && restore_domain "com.apple.dock" "$EXPORT_DIR/dock.binary.plist" "Dock" && RESTART_DOCK=true

    read -p "Finder? [y/N]: " choice
    [[ "$choice" =~ ^[Yy]$ ]] && restore_domain "com.apple.finder" "$EXPORT_DIR/finder.binary.plist" "Finder" && RESTART_FINDER=true

    read -p "Screenshot settings? [y/N]: " choice
    [[ "$choice" =~ ^[Yy]$ ]] && restore_domain "com.apple.screencapture" "$EXPORT_DIR/screencapture.binary.plist" "Screenshot"

    read -p "Desktop Services? [y/N]: " choice
    [[ "$choice" =~ ^[Yy]$ ]] && restore_domain "com.apple.desktopservices" "$EXPORT_DIR/desktopservices.binary.plist" "Desktop Services"

    echo ""
    echo -e "${YELLOW}=== Input Devices ===${NC}"

    read -p "Trackpad? [y/N]: " choice
    [[ "$choice" =~ ^[Yy]$ ]] && restore_domain "com.apple.AppleMultitouchTrackpad" "$EXPORT_DIR/trackpad.binary.plist" "Trackpad"

    read -p "Trackpad (Bluetooth)? [y/N]: " choice
    [[ "$choice" =~ ^[Yy]$ ]] && restore_domain "com.apple.driver.AppleBluetoothMultitouch.trackpad" "$EXPORT_DIR/trackpad-bluetooth.binary.plist" "Trackpad (Bluetooth)"

    read -p "Mouse? [y/N]: " choice
    [[ "$choice" =~ ^[Yy]$ ]] && restore_domain "com.apple.driver.AppleBluetoothMultitouch.mouse" "$EXPORT_DIR/mouse.binary.plist" "Mouse"

    read -p "Keyboard Shortcuts? [y/N]: " choice
    [[ "$choice" =~ ^[Yy]$ ]] && restore_domain "com.apple.symbolichotkeys" "$EXPORT_DIR/keyboard-shortcuts.binary.plist" "Keyboard Shortcuts"

    echo ""
    echo -e "${YELLOW}=== Applications ===${NC}"

    read -p "SpaceLauncher? [y/N]: " choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
      restore_domain "name.guoc.SpaceLauncher" "$EXPORT_DIR/spacelauncher.binary.plist" "SpaceLauncher"
      restore_domain "name.guoc.SpaceLauncher.disabled_apps" "$EXPORT_DIR/spacelauncher-disabled-apps.binary.plist" "SpaceLauncher Disabled Apps"
      RESTART_SPACELAUNCHER=true
    fi

    read -p "iTerm2? [y/N]: " choice
    [[ "$choice" =~ ^[Yy]$ ]] && restore_domain "com.googlecode.iterm2" "$EXPORT_DIR/iterm2.binary.plist" "iTerm2" && RESTART_ITERM=true

    read -p "Raycast? [y/N]: " choice
    [[ "$choice" =~ ^[Yy]$ ]] && restore_domain "com.raycast.macos" "$EXPORT_DIR/raycast.binary.plist" "Raycast" && RESTART_RAYCAST=true

    read -p "Arc Browser? [y/N]: " choice
    [[ "$choice" =~ ^[Yy]$ ]] && restore_domain "company.thebrowser.Browser" "$EXPORT_DIR/arc-browser.binary.plist" "Arc Browser" && RESTART_ARC=true

    read -p "Stats? [y/N]: " choice
    [[ "$choice" =~ ^[Yy]$ ]] && restore_domain "eu.exelban.Stats" "$EXPORT_DIR/stats.binary.plist" "Stats" && RESTART_STATS=true

    read -p "Synology Drive? [y/N]: " choice
    [[ "$choice" =~ ^[Yy]$ ]] && restore_domain "com.synology.CloudStationUI" "$EXPORT_DIR/synology-drive.binary.plist" "Synology Drive" && RESTART_SYNOLOGY=true
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

# Restart affected services and applications
if [ "$RESTART_ALL" = true ]; then
  echo -e "${YELLOW}Restarting system services and applications...${NC}"
  killall Dock 2>/dev/null && echo -e "${GREEN}✓ Dock restarted${NC}"
  killall Finder 2>/dev/null && echo -e "${GREEN}✓ Finder restarted${NC}"
  killall SystemUIServer 2>/dev/null && echo -e "${GREEN}✓ SystemUIServer restarted${NC}"
  killall cfprefsd 2>/dev/null && echo -e "${GREEN}✓ cfprefsd restarted${NC}"

  # Restart applications if running
  pgrep -x "SpaceLauncher" > /dev/null && killall "SpaceLauncher" 2>/dev/null && echo -e "${GREEN}✓ SpaceLauncher restarted${NC}"
  pgrep -x "iTerm2" > /dev/null && killall "iTerm2" 2>/dev/null && echo -e "${GREEN}✓ iTerm2 restarted (reopen manually)${NC}"
  pgrep -x "Raycast" > /dev/null && killall "Raycast" 2>/dev/null && open -a "Raycast" && echo -e "${GREEN}✓ Raycast restarted${NC}"
  pgrep -x "Arc" > /dev/null && killall "Arc" 2>/dev/null && echo -e "${GREEN}✓ Arc restarted (reopen manually)${NC}"
  pgrep -x "Stats" > /dev/null && killall "Stats" 2>/dev/null && open -a "Stats" && echo -e "${GREEN}✓ Stats restarted${NC}"
  pgrep -x "Synology Drive Client" > /dev/null && killall "Synology Drive Client" 2>/dev/null && echo -e "${GREEN}✓ Synology Drive restarted (reopen manually)${NC}"

elif [ "$RESTART_SYSTEM" = true ]; then
  echo -e "${YELLOW}Restarting system services...${NC}"
  killall Dock 2>/dev/null && echo -e "${GREEN}✓ Dock restarted${NC}"
  killall Finder 2>/dev/null && echo -e "${GREEN}✓ Finder restarted${NC}"
  killall SystemUIServer 2>/dev/null && echo -e "${GREEN}✓ SystemUIServer restarted${NC}"

elif [ "$RESTART_APPS" = true ]; then
  echo -e "${YELLOW}Restarting applications...${NC}"
  pgrep -x "SpaceLauncher" > /dev/null && killall "SpaceLauncher" 2>/dev/null && echo -e "${GREEN}✓ SpaceLauncher will restart${NC}"
  pgrep -x "iTerm2" > /dev/null && echo -e "${YELLOW}⚠ iTerm2: Restart manually to apply settings${NC}"
  pgrep -x "Raycast" > /dev/null && killall "Raycast" 2>/dev/null && open -a "Raycast" && echo -e "${GREEN}✓ Raycast restarted${NC}"
  pgrep -x "Arc" > /dev/null && echo -e "${YELLOW}⚠ Arc: Restart manually to apply settings${NC}"
  pgrep -x "Stats" > /dev/null && killall "Stats" 2>/dev/null && open -a "Stats" && echo -e "${GREEN}✓ Stats restarted${NC}"
  pgrep -x "Synology Drive Client" > /dev/null && echo -e "${YELLOW}⚠ Synology Drive: Restart manually to apply settings${NC}"

else
  # Individual restarts from custom selection
  [ "$RESTART_DOCK" = true ] && killall Dock 2>/dev/null && echo -e "${GREEN}✓ Dock restarted${NC}"
  [ "$RESTART_FINDER" = true ] && killall Finder 2>/dev/null && echo -e "${GREEN}✓ Finder restarted${NC}"
  [ "$RESTART_SPACELAUNCHER" = true ] && pgrep -x "SpaceLauncher" > /dev/null && killall "SpaceLauncher" 2>/dev/null && echo -e "${GREEN}✓ SpaceLauncher will restart${NC}"
  [ "$RESTART_ITERM" = true ] && echo -e "${YELLOW}⚠ iTerm2: Restart manually to apply settings${NC}"
  [ "$RESTART_RAYCAST" = true ] && pgrep -x "Raycast" > /dev/null && killall "Raycast" 2>/dev/null && open -a "Raycast" && echo -e "${GREEN}✓ Raycast restarted${NC}"
  [ "$RESTART_ARC" = true ] && echo -e "${YELLOW}⚠ Arc: Restart manually to apply settings${NC}"
  [ "$RESTART_STATS" = true ] && pgrep -x "Stats" > /dev/null && killall "Stats" 2>/dev/null && open -a "Stats" && echo -e "${GREEN}✓ Stats restarted${NC}"
  [ "$RESTART_SYNOLOGY" = true ] && echo -e "${YELLOW}⚠ Synology Drive: Restart manually to apply settings${NC}"
fi

echo ""
echo "================================"
echo "Restore Complete!"
echo "================================"
echo ""
echo "Some settings may require logging out and back in to take full effect."
echo ""
echo "Notes:"
echo "  • System settings (Dock, Finder) are active immediately"
echo "  • Input device settings may require re-pairing Bluetooth devices"
echo "  • Application settings take effect on next app launch"
echo "  • Keyboard shortcuts may require logout to fully activate"

if [[ "$backup_choice" != "n" && "$backup_choice" != "N" ]]; then
  echo ""
  echo "Your previous settings were backed up to:"
  echo "  $BACKUP_DIR"
  echo ""
  echo "To restore the backup if needed, use commands like:"
  echo "  defaults import com.apple.dock $BACKUP_DIR/dock.binary.plist"
  echo "  defaults import com.googlecode.iterm2 $BACKUP_DIR/iterm2.binary.plist"
  echo "  killall Dock"
fi

echo ""
