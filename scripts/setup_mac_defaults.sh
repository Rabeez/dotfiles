#!/usr/bin/env bash

# ---------------------------------------------------------------------------------
printf "%b\n" "${YELLOW}Applying global theme settings for Finder...${RC}"

# Set the default Finder view to list view
printf "%b\n" "${CYAN}Setting default Finder view to list view...${RC}"
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Configure list view settings for all folders
printf "%b\n" "${CYAN}Configuring list view settings for all folders...${RC}"
# Set default list view settings for new folders
defaults write com.apple.finder FK_StandardViewSettings -dict-add ListViewSettings '{ "columns" = ( { "ascending" = 1; "identifier" = "name"; "visible" = 1; "width" = 300; }, { "ascending" = 0; "identifier" = "dateModified"; "visible" = 1; "width" = 181; }, { "ascending" = 0; "identifier" = "size"; "visible" = 1; "width" = 97; } ); "iconSize" = 16; "showIconPreview" = 0; "sortColumn" = "name"; "textSize" = 12; "useRelativeDates" = 1; }'

# Clear existing folder view settings to force use of default settings
printf "%b\n" "${CYAN}Clearing existing folder view settings...${RC}"
defaults delete com.apple.finder FXInfoPanesExpanded 2>/dev/null || true
defaults delete com.apple.finder FXDesktopVolumePositions 2>/dev/null || true

# Set list view for all view types
printf "%b\n" "${CYAN}Setting list view for all folder types...${RC}"
defaults write com.apple.finder FK_StandardViewSettings -dict-add ExtendedListViewSettings '{ "columns" = ( { "ascending" = 1; "identifier" = "name"; "visible" = 1; "width" = 300; }, { "ascending" = 0; "identifier" = "dateModified"; "visible" = 1; "width" = 181; }, { "ascending" = 0; "identifier" = "size"; "visible" = 1; "width" = 97; } ); "iconSize" = 16; "showIconPreview" = 0; "sortColumn" = "name"; "textSize" = 12; "useRelativeDates" = 1; }'

# Sets default search scope to the current folder
printf "%b\n" "${CYAN}Setting default search scope to the current folder...${RC}"
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Remove trash items older than 30 days
printf "%b\n" "${CYAN}Removing trash items older than 30 days...${RC}"
defaults write com.apple.finder "FXRemoveOldTrashItems" -bool "true"

# Remove .DS_Store files to reset folder view settings
printf "%b\n" "${CYAN}Removing .DS_Store files to reset folder view settings...${RC}"
find ~ -name ".DS_Store" -type f -delete 2>/dev/null || true

# Show all filename extensions
printf "%b\n" "${CYAN}Showing all filename extensions in Finder...${RC}"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Set the sidebar icon size to small
printf "%b\n" "${CYAN}Setting sidebar icon size to small...${RC}"
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1

# Show status bar in Finder
printf "%b\n" "${CYAN}Showing status bar in Finder...${RC}"
defaults write com.apple.finder ShowStatusBar -bool true

# Show path bar in Finder
printf "%b\n" "${CYAN}Showing path bar in Finder...${RC}"
defaults write com.apple.finder ShowPathbar -bool true

# Clean up Finder's sidebar
printf "%b\n" "${CYAN}Cleaning up Finder's sidebar...${RC}"
defaults write com.apple.finder SidebarDevicesSectionDisclosedState -bool true
defaults write com.apple.finder SidebarPlacesSectionDisclosedState -bool true
defaults write com.apple.finder SidebarShowingiCloudDesktop -bool false

# Restart Finder to apply changes
printf "%b\n" "${GREEN}Finder has been restarted and settings have been applied.${RC}"
killall Finder
# ---------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------
printf "%b\n" "${YELLOW}Reducing motion and animations on macOS...${RC}"

# Reduce motion in Accessibility settings (most effective)
printf "%b\n" "${CYAN}Setting reduce motion preference...${RC}"
defaults write com.apple.universalaccess reduceMotion -bool true

# Disable window animations
printf "%b\n" "${CYAN}Disabling window animations...${RC}"
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

# Speed up window resize animations
printf "%b\n" "${CYAN}Speeding up window resize animations...${RC}"
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

# Disable smooth scrolling
printf "%b\n" "${CYAN}Disabling smooth scrolling...${RC}"
defaults write NSGlobalDomain NSScrollAnimationEnabled -bool false

# Disable animation when opening and closing windows
printf "%b\n" "${CYAN}Disabling window open/close animations...${RC}"
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

# Disable animation when opening a Quick Look window
printf "%b\n" "${CYAN}Disabling Quick Look animations...${RC}"
defaults write -g QLPanelAnimationDuration -float 0

# Disable animation when opening the Info window in Finder
printf "%b\n" "${CYAN}Disabling Finder Info window animations...${RC}"
defaults write com.apple.finder DisableAllAnimations -bool true

# Speed up Mission Control animations
printf "%b\n" "${CYAN}Speeding up Mission Control animations...${RC}"
defaults write com.apple.dock expose-animation-duration -float 0.1

# Speed up Launchpad animations
printf "%b\n" "${CYAN}Speeding up Launchpad animations...${RC}"
defaults write com.apple.dock springboard-show-duration -float 0.1
defaults write com.apple.dock springboard-hide-duration -float 0.1

# Disable dock hiding animation
printf "%b\n" "${CYAN}Disabling dock hiding animations...${RC}"
defaults write com.apple.dock autohide-time-modifier -float 0
defaults write com.apple.dock autohide-delay -float 0

# Disable animations in Mail.app
printf "%b\n" "${CYAN}Disabling Mail animations...${RC}"
defaults write com.apple.mail DisableReplyAnimations -bool true
defaults write com.apple.mail DisableSendAnimations -bool true

# Disable zoom animation when focusing on text input fields
printf "%b\n" "${CYAN}Disabling text field zoom animations...${RC}"
defaults write NSGlobalDomain NSTextShowsControlCharacters -bool true

printf "%b\n" "${GREEN}Motion and animations have been reduced.${RC}"
killall Dock
printf "%b\n" "${YELLOW}Dock Restarted.${RC}"
# ---------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------
printf "%b\n" "${YELLOW}Performing system cleanup...${RC}"
# Fix Missions control to NEVER rearrange spaces
printf "%b\n" "${CYAN}Fixing Mission Control to never rearrange spaces...${RC}"
defaults write com.apple.dock mru-spaces -bool false

# Apple Intelligence Crap
defaults write com.apple.CloudSubscriptionFeatures.optIn "545129924" -bool "false"

# Empty Trash
printf "%b\n" "${CYAN}Emptying Trash...${RC}"
rm -rf ~/.Trash/*

# Remove old log files
printf "%b\n" "${CYAN}Removing old log files...${RC}"
find /var/log -type f -name "*.log" -mtime +30 -exec "$ESCALATION_TOOL" rm -f {} \;
find /var/log -type f -name "*.old" -mtime +30 -exec "$ESCALATION_TOOL" rm -f {} \;
find /var/log -type f -name "*.err" -mtime +30 -exec "$ESCALATION_TOOL" rm -f {} \;
# ---------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------
# TODO: add mac dock config
# ---------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------
# TODO: add mac mouse/trackpad config
# ---------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------
# TODO: add mac extra utils (Screenshot folder, tweak_tool etc)
# ---------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------
# TODO: add system install commands (brew etc)
# ---------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------
# TODO: spicewtify marketplace command with curl
# ---------------------------------------------------------------------------------
