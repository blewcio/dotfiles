#!/usr/bin/env bash

# Export current macOS system defaults to files
# Run this on your current Mac to capture settings before updating macos.sh

EXPORT_DIR="${HOME}/dotfiles/mac/exported-defaults"
mkdir -p "$EXPORT_DIR"

echo "Exporting macOS defaults to $EXPORT_DIR..."

# Core system domains
echo "Exporting Dock settings..."
defaults read com.apple.dock > "$EXPORT_DIR/dock.plist" 2>/dev/null

echo "Exporting Finder settings..."
defaults read com.apple.finder > "$EXPORT_DIR/finder.plist" 2>/dev/null

echo "Exporting Global Domain settings..."
defaults read NSGlobalDomain > "$EXPORT_DIR/global.plist" 2>/dev/null

echo "Exporting Trackpad settings..."
defaults read com.apple.AppleMultitouchTrackpad > "$EXPORT_DIR/trackpad.plist" 2>/dev/null

echo "Exporting Mouse settings..."
defaults read com.apple.driver.AppleBluetoothMultitouch.mouse > "$EXPORT_DIR/mouse.plist" 2>/dev/null

echo "Exporting Screenshot settings..."
defaults read com.apple.screencapture > "$EXPORT_DIR/screencapture.plist" 2>/dev/null

echo "Exporting Menu Bar Clock settings..."
defaults read com.apple.menuextra.clock > "$EXPORT_DIR/menubar-clock.plist" 2>/dev/null

echo "Exporting Keyboard Shortcuts..."
defaults read com.apple.symbolichotkeys > "$EXPORT_DIR/keyboard-shortcuts.plist" 2>/dev/null

echo "Exporting Activity Monitor settings..."
defaults read com.apple.ActivityMonitor > "$EXPORT_DIR/activity-monitor.plist" 2>/dev/null

# Export as binary plist for exact restoration
echo ""
echo "Exporting binary plists for exact restoration..."
defaults export com.apple.dock "$EXPORT_DIR/dock.binary.plist" 2>/dev/null
defaults export com.apple.finder "$EXPORT_DIR/finder.binary.plist" 2>/dev/null
defaults export NSGlobalDomain "$EXPORT_DIR/global.binary.plist" 2>/dev/null
defaults export com.apple.AppleMultitouchTrackpad "$EXPORT_DIR/trackpad.binary.plist" 2>/dev/null

echo ""
echo "Export complete! Files saved to: $EXPORT_DIR"
echo ""
echo "To restore these exact settings later, you can use:"
echo "  defaults import com.apple.dock $EXPORT_DIR/dock.binary.plist"
echo ""
echo "NOTE: Review exported files and update macos.sh with any settings you want to preserve."
