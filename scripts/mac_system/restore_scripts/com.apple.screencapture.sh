#!/bin/bash
# Restore settings for com.apple.screencapture
echo "Restoring com.apple.screencapture settings..."

defaults write "com.apple.screencapture" "disable-shadow" -int 1
defaults write "com.apple.screencapture" "last-analytics-stamp" "775082505.99256"
# Dictionary value for last-selection - may need manual handling
# defaults write "com.apple.screencapture" "last-selection" '{'
defaults write "com.apple.screencapture" "Height" -int 935
defaults write "com.apple.screencapture" "Width" "439.5"
defaults write "com.apple.screencapture" "X" "416.75"
defaults write "com.apple.screencapture" "Y" -int 145
defaults write "com.apple.screencapture" "last-selection-display" -int 0
defaults write "com.apple.screencapture" "location" "~/Pictures/Screenshots"
defaults write "com.apple.screencapture" "location-last" "~/Pictures/Screenshots"
defaults write "com.apple.screencapture" "show-thumbnail" -int 0
defaults write "com.apple.screencapture" "showsClicks" -int 1
defaults write "com.apple.screencapture" "showsCursor" -int 1
defaults write "com.apple.screencapture" "style" "selection"
defaults write "com.apple.screencapture" "target" "file"
defaults write "com.apple.screencapture" "type" "png"
defaults write "com.apple.screencapture" "video" -int 1
