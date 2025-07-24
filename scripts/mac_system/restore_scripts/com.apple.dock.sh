#!/bin/bash
# Restore settings for com.apple.dock
echo "Restoring com.apple.dock settings..."

defaults write "com.apple.dock" "autohide" -int 1
defaults write "com.apple.dock" "autohide-delay" -int 0
defaults write "com.apple.dock" "autohide-time-modifier" -int 0
defaults write "com.apple.dock" "expose-group-apps" -int 1
defaults write "com.apple.dock" "lastShowIndicatorTime" "748469316.905743"
defaults write "com.apple.dock" "mineffect" "scale"
defaults write "com.apple.dock" "minimize-to-application" -int 1
defaults write "com.apple.dock" "mod-count" -int 205
defaults write "com.apple.dock" "orientation" "left"
defaults write "com.apple.dock" "GUID" -int 210280451
# Dictionary value for book - may need manual handling
# defaults write "com.apple.dock" "book" '{length = 552, bytes = 0x626f6f6b 28020000 00000410 30000000 ... 04000000 00000000 }'
defaults write "com.apple.dock" "bundle-identifier" "app.zen-browser.zen"
defaults write "com.apple.dock" "_CFURLString" "file:///Applications/Zen.app/"
defaults write "com.apple.dock" "file-label" "Zen"
defaults write "com.apple.dock" "file-mod-date" -int 15259559278001
defaults write "com.apple.dock" "parent-mod-date" -int 155219659243674
defaults write "com.apple.dock" "GUID" -int 2536335618
# Dictionary value for book - may need manual handling
# defaults write "com.apple.dock" "book" '{length = 556, bytes = 0x626f6f6b 2c020000 00000410 30000000 ... 04000000 00000000 }'
defaults write "com.apple.dock" "bundle-identifier" "com.mitchellh.ghostty"
defaults write "com.apple.dock" "_CFURLString" "file:///Applications/Ghostty.app/"
defaults write "com.apple.dock" "file-label" "Ghostty"
defaults write "com.apple.dock" "file-mod-date" -int 274194548232459
defaults write "com.apple.dock" "parent-mod-date" -int 155219659243674
defaults write "com.apple.dock" "GUID" -int 4188816223
# Dictionary value for book - may need manual handling
# defaults write "com.apple.dock" "book" '{length = 556, bytes = 0x626f6f6b 2c020000 00000410 30000000 ... 04000000 00000000 }'
defaults write "com.apple.dock" "bundle-identifier" "md.obsidian"
defaults write "com.apple.dock" "_CFURLString" "file:///Applications/Obsidian.app/"
defaults write "com.apple.dock" "file-label" "Obsidian"
defaults write "com.apple.dock" "file-mod-date" -int 3804159229
defaults write "com.apple.dock" "parent-mod-date" -int 17273896265510
defaults write "com.apple.dock" "show-recents" -int 0
defaults write "com.apple.dock" "showAppExposeGestureEnabled" -int 1
defaults write "com.apple.dock" "showMissionControlGestureEnabled" -int 1
defaults write "com.apple.dock" "size-immutable" -int 1
defaults write "com.apple.dock" "springboard-columns" -int 8
defaults write "com.apple.dock" "springboard-hide-duration" -int 0
defaults write "com.apple.dock" "springboard-rows" -int 6
defaults write "com.apple.dock" "springboard-show-duration" -int 0
defaults write "com.apple.dock" "tilesize" -int 44
defaults write "com.apple.dock" "workspaces-edge-delay" -int 0
defaults write "com.apple.dock" "wvous-br-corner" -int 1
defaults write "com.apple.dock" "wvous-br-modifier" -int 0
