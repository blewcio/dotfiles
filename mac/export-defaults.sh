#!/usr/bin/env bash

# Export current macOS system defaults to files
# Run this on your current Mac to capture settings before updating macos.sh

EXPORT_DIR="${HOME}/dotfiles/mac/exported-defaults"
mkdir -p "$EXPORT_DIR"

echo "Exporting macOS defaults to $EXPORT_DIR..."

###############################################################################
# Core System Domains
###############################################################################

echo "Exporting Global Domain settings..."
defaults read NSGlobalDomain > "$EXPORT_DIR/global.plist" 2>/dev/null

echo "Exporting Dock settings..."
defaults read com.apple.dock > "$EXPORT_DIR/dock.plist" 2>/dev/null

echo "Exporting Finder settings..."
defaults read com.apple.finder > "$EXPORT_DIR/finder.plist" 2>/dev/null

###############################################################################
# Input Devices
###############################################################################

echo "Exporting Trackpad settings (AppleMultitouchTrackpad)..."
defaults read com.apple.AppleMultitouchTrackpad > "$EXPORT_DIR/trackpad.plist" 2>/dev/null

echo "Exporting Trackpad settings (Bluetooth)..."
defaults read com.apple.driver.AppleBluetoothMultitouch.trackpad > "$EXPORT_DIR/trackpad-bluetooth.plist" 2>/dev/null

echo "Exporting Mouse settings..."
defaults read com.apple.driver.AppleBluetoothMultitouch.mouse > "$EXPORT_DIR/mouse.plist" 2>/dev/null

echo "Exporting Keyboard Shortcuts..."
defaults read com.apple.symbolichotkeys > "$EXPORT_DIR/keyboard-shortcuts.plist" 2>/dev/null

###############################################################################
# Screen & Desktop
###############################################################################

echo "Exporting Screenshot settings..."
defaults read com.apple.screencapture > "$EXPORT_DIR/screencapture.plist" 2>/dev/null

echo "Exporting Screen Saver settings..."
defaults read com.apple.screensaver > "$EXPORT_DIR/screensaver.plist" 2>/dev/null

echo "Exporting Desktop Services settings..."
defaults read com.apple.desktopservices > "$EXPORT_DIR/desktopservices.plist" 2>/dev/null

###############################################################################
# Menu Bar & System UI
###############################################################################

echo "Exporting Menu Bar Clock settings..."
defaults read com.apple.menuextra.clock > "$EXPORT_DIR/menubar-clock.plist" 2>/dev/null

echo "Exporting Notification Center settings..."
defaults read com.apple.notificationcenterui > "$EXPORT_DIR/notificationcenter.plist" 2>/dev/null

###############################################################################
# System Preferences & Services
###############################################################################

echo "Exporting Dashboard settings..."
defaults read com.apple.dashboard > "$EXPORT_DIR/dashboard.plist" 2>/dev/null

echo "Exporting Software Update settings..."
defaults read com.apple.SoftwareUpdate > "$EXPORT_DIR/software-update.plist" 2>/dev/null

echo "Exporting App Store settings..."
defaults read com.apple.commerce > "$EXPORT_DIR/app-store.plist" 2>/dev/null

echo "Exporting Disk Images settings..."
defaults read com.apple.frameworks.diskimages > "$EXPORT_DIR/disk-images.plist" 2>/dev/null

echo "Exporting Printer settings..."
defaults read com.apple.print.PrintingPrefs > "$EXPORT_DIR/printer.plist" 2>/dev/null

echo "Exporting Sound settings..."
defaults read com.apple.sound.beep.feedback > "$EXPORT_DIR/sound-feedback.plist" 2>/dev/null

###############################################################################
# Applications
###############################################################################

echo "Exporting Activity Monitor settings..."
defaults read com.apple.ActivityMonitor > "$EXPORT_DIR/activity-monitor.plist" 2>/dev/null

echo "Exporting ImageCapture (Photos) settings..."
defaults read com.apple.ImageCapture > "$EXPORT_DIR/imagecapture.plist" 2>/dev/null

echo "Exporting Terminal settings..."
defaults read com.apple.terminal > "$EXPORT_DIR/terminal.plist" 2>/dev/null

echo "Exporting TextEdit settings..."
defaults read com.apple.TextEdit > "$EXPORT_DIR/textedit.plist" 2>/dev/null

echo "Exporting Google Chrome settings..."
defaults read com.google.Chrome > "$EXPORT_DIR/chrome.plist" 2>/dev/null

echo "Exporting SpaceLauncher settings..."
defaults read name.guoc.SpaceLauncher > "$EXPORT_DIR/spacelauncher.plist" 2>/dev/null

echo "Exporting SpaceLauncher disabled apps..."
defaults read name.guoc.SpaceLauncher.disabled_apps > "$EXPORT_DIR/spacelauncher-disabled-apps.plist" 2>/dev/null

echo "Exporting iTerm2 settings..."
defaults read com.googlecode.iterm2 > "$EXPORT_DIR/iterm2.plist" 2>/dev/null

echo "Exporting Raycast settings..."
defaults read com.raycast.macos > "$EXPORT_DIR/raycast.plist" 2>/dev/null

echo "Exporting Arc Browser settings..."
defaults read company.thebrowser.Browser > "$EXPORT_DIR/arc-browser.plist" 2>/dev/null

echo "Exporting Arc Browser data files (key bindings, boosts, extensions)..."
ARC_DIR="$HOME/Library/Application Support/Arc"
ARC_DATA_BACKUP="$EXPORT_DIR/arc"
mkdir -p "$ARC_DATA_BACKUP"

[ -f "$ARC_DIR/StorableKeyBindings.json" ] && \
  cp "$ARC_DIR/StorableKeyBindings.json" "$ARC_DATA_BACKUP/" && \
  echo "  ✓ Key bindings exported"

if [ -d "$ARC_DIR/boosts" ] && [ -n "$(ls -A "$ARC_DIR/boosts" 2>/dev/null)" ]; then
  mkdir -p "$ARC_DATA_BACKUP/boosts"
  cp -r "$ARC_DIR/boosts/." "$ARC_DATA_BACKUP/boosts/" && echo "  ✓ Boosts exported"
fi

python3 - "$ARC_DIR/User Data/Default/Extensions" "$ARC_DATA_BACKUP/extensions-list.json" << 'PYEOF'
import json, os, glob, re, sys

ext_dir, out_path = sys.argv[1], sys.argv[2]
results = []
if os.path.isdir(ext_dir):
    for ext_id in os.listdir(ext_dir):
        for m in glob.glob(os.path.join(ext_dir, ext_id, '*', 'manifest.json')):
            try:
                with open(m) as f:
                    data = json.load(f)
                name = data.get('name', '?')
                if name.startswith('__MSG_'):
                    key = re.match(r'__MSG_(.+)__', name)
                    if key:
                        for locale in ['en', 'en_US', 'en_GB']:
                            msgs = os.path.join(os.path.dirname(m), '_locales', locale, 'messages.json')
                            if os.path.exists(msgs):
                                with open(msgs) as mf:
                                    resolved = json.load(mf).get(key.group(1), {}).get('message')
                                if resolved:
                                    name = resolved
                                    break
                results.append({'id': ext_id, 'name': name})
            except Exception:
                pass
results.sort(key=lambda x: x['name'])
with open(out_path, 'w') as f:
    json.dump(results, f, indent=2)
print(f'  ✓ Extension list exported ({len(results)} extensions)')
PYEOF
unset ARC_DIR ARC_DATA_BACKUP

echo "Exporting Stats settings..."
defaults read eu.exelban.Stats > "$EXPORT_DIR/stats.plist" 2>/dev/null

echo "Exporting Synology Drive settings..."
defaults read com.synology.CloudStationUI > "$EXPORT_DIR/synology-drive.plist" 2>/dev/null

###############################################################################
# Additional System Information
###############################################################################

echo "Exporting energy settings (pmset)..."
pmset -g > "$EXPORT_DIR/energy-pmset.txt" 2>/dev/null

echo "Exporting NVRAM settings..."
nvram -p > "$EXPORT_DIR/nvram.txt" 2>/dev/null || echo "NVRAM export requires sudo" > "$EXPORT_DIR/nvram.txt"

# Export as binary plist for exact restoration
echo ""
echo "Exporting binary plists for exact restoration..."
defaults export NSGlobalDomain "$EXPORT_DIR/global.binary.plist" 2>/dev/null
defaults export com.apple.dock "$EXPORT_DIR/dock.binary.plist" 2>/dev/null
defaults export com.apple.finder "$EXPORT_DIR/finder.binary.plist" 2>/dev/null
defaults export com.apple.AppleMultitouchTrackpad "$EXPORT_DIR/trackpad.binary.plist" 2>/dev/null
defaults export com.apple.driver.AppleBluetoothMultitouch.trackpad "$EXPORT_DIR/trackpad-bluetooth.binary.plist" 2>/dev/null
defaults export com.apple.driver.AppleBluetoothMultitouch.mouse "$EXPORT_DIR/mouse.binary.plist" 2>/dev/null
defaults export com.apple.symbolichotkeys "$EXPORT_DIR/keyboard-shortcuts.binary.plist" 2>/dev/null
defaults export com.apple.screencapture "$EXPORT_DIR/screencapture.binary.plist" 2>/dev/null
defaults export com.apple.desktopservices "$EXPORT_DIR/desktopservices.binary.plist" 2>/dev/null
defaults export name.guoc.SpaceLauncher "$EXPORT_DIR/spacelauncher.binary.plist" 2>/dev/null
defaults export name.guoc.SpaceLauncher.disabled_apps "$EXPORT_DIR/spacelauncher-disabled-apps.binary.plist" 2>/dev/null
defaults export com.googlecode.iterm2 "$EXPORT_DIR/iterm2.binary.plist" 2>/dev/null
defaults export com.raycast.macos "$EXPORT_DIR/raycast.binary.plist" 2>/dev/null
defaults export company.thebrowser.Browser "$EXPORT_DIR/arc-browser.binary.plist" 2>/dev/null
defaults export eu.exelban.Stats "$EXPORT_DIR/stats.binary.plist" 2>/dev/null
defaults export com.synology.CloudStationUI "$EXPORT_DIR/synology-drive.binary.plist" 2>/dev/null

echo ""
echo "Export complete! Files saved to: $EXPORT_DIR"
echo ""
echo "To restore these exact settings later, you can use:"
echo "  defaults import com.apple.dock $EXPORT_DIR/dock.binary.plist"
echo "  defaults import NSGlobalDomain $EXPORT_DIR/global.binary.plist"
echo "  defaults import com.googlecode.iterm2 $EXPORT_DIR/iterm2.binary.plist"
echo "  defaults import com.raycast.macos $EXPORT_DIR/raycast.binary.plist"
echo "  etc."
echo ""
echo "To restore energy settings:"
echo "  Review $EXPORT_DIR/energy-pmset.txt and use 'sudo pmset' commands"
echo ""
echo "NOTE: Review exported files and update macos.sh with any settings you want to preserve."
echo "      Some settings may require Full Disk Access for Terminal to export properly."
