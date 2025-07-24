#!/bin/bash
# Restore settings for com.apple.Spotlight
echo "Restoring com.apple.Spotlight settings..."

defaults write "com.apple.Spotlight" "engagementCount-com.apple.Spotlight" -int 69
defaults write "com.apple.Spotlight" "engagementCountForDate-com.apple.Spotlight" -int 11
defaults write "com.apple.Spotlight" "engagementDate-com.apple.Spotlight" "2024-09-20"
defaults write "com.apple.Spotlight" "lastVisibleScreenRect" "{{0, 0}, {1710, 1074}}"
defaults write "com.apple.Spotlight" "lastWindowPosition" "{{555, 892.94291338582673}, {1, 1}}"
defaults write "com.apple.Spotlight" "startTime" "774981480.108569"
defaults write "com.apple.Spotlight" "useCount" -int 3
defaults write "com.apple.Spotlight" "userHasMovedWindow" -int 1
