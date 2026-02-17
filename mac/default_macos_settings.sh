#!/usr/bin/env bash

# macOS System Preferences Configuration Script
# Based on https://mths.be/macos and customized for personal preferences
#
# Run this script on a new Mac to configure system settings
# Some changes require logout/restart to take effect
# Some settings require admin privileges (sudo)

set -e

echo "Configuring macOS system preferences..."

# Close any open System Preferences panes to prevent overriding
osascript -e 'tell application "System Preferences" to quit' 2>/dev/null || true
osascript -e 'tell application "System Settings" to quit' 2>/dev/null || true

###############################################################################
# General UI/UX                                                               #
###############################################################################

echo "Setting General UI/UX preferences..."

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" " 2>/dev/null || true

# Set sidebar icon size to small (1=small, 2=medium, 3=large)
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Automatically quit printer app once print jobs complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Clicking in scroll bar jumps to spot that's clicked
defaults write NSGlobalDomain AppleScrollerPagingBehavior -int 1

# Set accent color to Blue (0=Red, 1=Orange, 2=Yellow, 3=Green, 4=Blue, 5=Purple, 6=Pink, -1=Graphite)
defaults write NSGlobalDomain AppleAccentColor -int 4

# Automatically switch between light and dark mode based on time of day
defaults write NSGlobalDomain AppleInterfaceStyleSwitchesAutomatically -int 1

# Disable minimizing windows on double-click of title bar
defaults write NSGlobalDomain AppleMiniaturizeOnDoubleClick -int 0

# When switching to an app, automatically switch to space with its windows
defaults write NSGlobalDomain AppleSpacesSwitchOnActivate -int 1

# Disable flash screen when alert sound occurs (accessibility)
defaults write NSGlobalDomain com.apple.sound.beep.flash -int 0

###############################################################################
# Keyboard                                                                    #
###############################################################################

echo "Setting Keyboard preferences..."

# Enable full keyboard access for all controls
# (e.g. enable Tab in modal dialogs)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Set keyboard repeat rate (lower = faster, 2 is fast)
defaults write NSGlobalDomain KeyRepeat -int 2

# Set initial key repeat delay (lower = shorter delay, 15 is quick)
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Disable press-and-hold for keys in favor of key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Enable automatic capitalization (set to false to disable)
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool true

# Disable smart dashes
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Enable automatic period substitution (set to false to disable)
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool true

# Disable smart quotes
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

###############################################################################
# Trackpad                                                                    #
###############################################################################

echo "Setting Trackpad preferences..."

# Enable tap to click for this user and for the login screen
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Trackpad: two finger tap for right-click
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true

# Enable Force Click and haptic feedback
defaults write NSGlobalDomain com.apple.trackpad.forceClick -int 1

# Set trackpad tracking speed (0=slow, 3=high speed)
defaults write NSGlobalDomain com.apple.trackpad.scaling -int 3

# Disable three finger drag (set to true to enable)
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool false

# Enable trackpad gestures
defaults write com.apple.AppleMultitouchTrackpad TrackpadRotate -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadPinch -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadTwoFingerDoubleTapGesture -int 1
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerVertSwipeGesture -int 2
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerHorizSwipeGesture -int 2
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerVertSwipeGesture -int 2
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerHorizSwipeGesture -int 2

# Two-finger swipe from right edge shows Notification Center
defaults write com.apple.AppleMultitouchTrackpad TrackpadTwoFingerFromRightEdgeSwipeGesture -int 3

# Five-finger pinch gesture opens Launchpad
defaults write com.apple.AppleMultitouchTrackpad TrackpadFiveFingerPinchGesture -int 2

###############################################################################
# Mouse                                                                       #
###############################################################################

echo "Setting Mouse preferences..."

defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseButtonMode -string "OneButton"
defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseTwoFingerDoubleTapGesture -int 3
defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseTwoFingerHorizSwipeGesture -int 2

# Enable mouse scrolling (horizontal and vertical)
defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseHorizontalScroll -int 1
defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseVerticalScroll -int 1

# Enable smooth/momentum scrolling with mouse
defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseMomentumScroll -int 1

# Mouse button division threshold
defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseButtonDivision -int 55

###############################################################################
# Energy                                                                      #
###############################################################################

echo "Setting Energy preferences..."

# Sleep the display after 5 minutes
sudo pmset -a displaysleep 5 2>/dev/null || true

# Set machine sleep to 10 minutes
sudo pmset -a sleep 10 2>/dev/null || true

# Put hard disks to sleep after 10 minutes
sudo pmset -a disksleep 10 2>/dev/null || true

# Set hibernate mode (3 = save to disk and memory, safe sleep)
sudo pmset -a hibernatemode 3 2>/dev/null || true

# Enable wake for network access (used by Find My Mac)
sudo pmset -a tcpkeepalive 1 2>/dev/null || true

# Disable Power Nap
sudo pmset -a powernap 0 2>/dev/null || true

###############################################################################
# Screen                                                                      #
###############################################################################

echo "Setting Screen/Screenshot preferences..."

# Save screenshots to Screenshots folder
defaults write com.apple.screencapture location -string "${HOME}/Screenshots"

# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

###############################################################################
# Finder                                                                      #
###############################################################################

echo "Setting Finder preferences..."

# Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons
defaults write com.apple.finder QuitMenuItem -bool true

# Finder: disable window animations and Get Info animations
defaults write com.apple.finder DisableAllAnimations -bool true

# Set Downloads as the default location for new Finder windows
# Use "PfDe" for Desktop, "PfHm" for Home
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Downloads/"

# Show icons for hard drives, servers, and removable media on the desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# Finder: show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool true

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder: show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Enable spring loading for directories
defaults write NSGlobalDomain com.apple.springing.enabled -bool true

# Remove the spring loading delay for directories
defaults write NSGlobalDomain com.apple.springing.delay -float 0

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Automatically open a new Finder window when a volume is mounted
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# Use list view in all Finder windows by default
# Four-letter codes for the other view modes: `icnv`, `clmv`, `glyv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Show item info near icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist 2>/dev/null || true

# Automatically remove items from Trash after 30 days
defaults write com.apple.finder FXRemoveOldTrashItems -bool true

# Show the preview pane in Finder
defaults write com.apple.finder ShowPreviewPane -bool false

###############################################################################
# Dock, Dashboard, and hot corners                                            #
###############################################################################

echo "Setting Dock preferences..."

# Set the icon size of Dock items to 60 pixels
defaults write com.apple.dock tilesize -int 60

# Position Dock on the left
defaults write com.apple.dock orientation -string "left"

# Change minimize/maximize window effect to genie
defaults write com.apple.dock mineffect -string "genie"

# Don't minimize windows into their application's icon
defaults write com.apple.dock minimize-to-application -bool false

# Enable spring loading for all Dock items
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

# Show indicator lights for open applications in the Dock
defaults write com.apple.dock show-process-indicators -bool true

# Don't animate opening applications from the Dock
defaults write com.apple.dock launchanim -bool false

# Speed up Mission Control animations
defaults write com.apple.dock expose-animation-duration -float 0.1

# Don't group windows by application in Mission Control
defaults write com.apple.dock expose-group-by-app -bool false

# Disable Dashboard
defaults write com.apple.dashboard mcx-disabled -bool true

# Don't show Dashboard as a Space
defaults write com.apple.dock dashboard-in-overlay -bool true

# Don't automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# Remove the auto-hiding Dock delay
defaults write com.apple.dock autohide-delay -float 0

# Remove the animation when hiding/showing the Dock
defaults write com.apple.dock autohide-time-modifier -float 0

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Make Dock icons of hidden applications translucent
defaults write com.apple.dock showhidden -bool true

# Don't show recent applications in Dock
defaults write com.apple.dock show-recents -bool false

# Hot corners
# Possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard
# 10: Put display to sleep
# 11: Launchpad
# 12: Notification Center
# 13: Lock Screen
# 14: Quick Note

# Bottom right screen corner → Quick Note
defaults write com.apple.dock wvous-br-corner -int 14
defaults write com.apple.dock wvous-br-modifier -int 0

###############################################################################
# Menu Bar                                                                    #
###############################################################################

echo "Setting Menu Bar preferences..."

# Show AM/PM in menu bar clock
defaults write com.apple.menuextra.clock ShowAMPM -bool true

# Show day of week in menu bar clock
defaults write com.apple.menuextra.clock ShowDayOfWeek -bool true

# Don't show date in menu bar clock (just day of week and time)
defaults write com.apple.menuextra.clock ShowDate -int 0

###############################################################################
# Spotlight                                                                   #
###############################################################################

echo "Setting Spotlight preferences..."

# Disable Spotlight indexing for any volume that gets mounted and has not yet
# been indexed before.
sudo defaults write /.Spotlight-V100/VolumeConfiguration Exclusions -array "/Volumes" 2>/dev/null || true

###############################################################################
# Activity Monitor                                                            #
###############################################################################

echo "Setting Activity Monitor preferences..."

# Show My Processes in Activity Monitor (0=All Processes, 100=My Processes)
defaults write com.apple.ActivityMonitor ShowCategory -int 100

# Sort Activity Monitor results by CPU usage
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

###############################################################################
# Mac App Store                                                               #
###############################################################################

echo "Setting Mac App Store preferences..."

# Enable the automatic update check
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

# Check for software updates daily (every 3 days actually)
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 3

# Download newly available updates in background
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

# Install System data files & security updates
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

# Automatically download apps purchased on other Macs
defaults write com.apple.SoftwareUpdate ConfigDataInstall -int 1

# Turn on app auto-update
defaults write com.apple.commerce AutoUpdate -bool true

###############################################################################
# Photos                                                                      #
###############################################################################

echo "Setting Photos preferences..."

# Prevent Photos from opening automatically when devices are plugged in
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

###############################################################################
# Google Chrome                                                               #
###############################################################################

echo "Setting Google Chrome preferences..."

# Disable the all too sensitive backswipe on trackpads
defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false
defaults write com.google.Chrome.canary AppleEnableSwipeNavigateWithScrolls -bool false

# Expand the print dialog by default
defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true
defaults write com.google.Chrome.canary PMPrintingExpandedStateForPrint2 -bool true

###############################################################################
# TextEdit                                                                    #
###############################################################################

echo "Setting TextEdit preferences..."

# Use plain text mode for new TextEdit documents
defaults write com.apple.TextEdit RichText -int 0

# Open and save files as UTF-8 in TextEdit
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

###############################################################################
# Terminal & iTerm2                                                           #
###############################################################################

echo "Setting Terminal preferences..."

# Only use UTF-8 in Terminal.app
defaults write com.apple.terminal StringEncodings -array 4

# Enable Secure Keyboard Entry in Terminal.app
defaults write com.apple.terminal SecureKeyboardEntry -bool true

###############################################################################
# Kill affected applications                                                  #
###############################################################################

echo "Restarting affected applications..."

for app in "Activity Monitor" \
	"cfprefsd" \
	"Dock" \
	"Finder" \
	"Google Chrome" \
	"Photos" \
	"SystemUIServer" \
	"Terminal"; do
	killall "${app}" &> /dev/null || true
done

echo "Done! Note that some of these changes require a logout/restart to take effect."
echo ""
echo "IMPORTANT: You may need to grant Terminal (or your terminal app) Full Disk Access"
echo "in System Settings > Privacy & Security > Full Disk Access for all settings to apply."
