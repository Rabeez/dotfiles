#!/bin/bash
# Restore settings for com.apple.AppleMultitouchTrackpad
echo "Restoring com.apple.AppleMultitouchTrackpad settings..."

defaults write "com.apple.AppleMultitouchTrackpad" "Clicking" -int 1
defaults write "com.apple.AppleMultitouchTrackpad" "FirstClickThreshold" -int 0
defaults write "com.apple.AppleMultitouchTrackpad" "SecondClickThreshold" -int 0
defaults write "com.apple.AppleMultitouchTrackpad" "TrackpadRotate" -int 0
defaults write "com.apple.AppleMultitouchTrackpad" "TrackpadThreeFingerDrag" -int 1
defaults write "com.apple.AppleMultitouchTrackpad" "TrackpadThreeFingerHorizSwipeGesture" -int 0
defaults write "com.apple.AppleMultitouchTrackpad" "TrackpadThreeFingerVertSwipeGesture" -int 0
defaults write "com.apple.AppleMultitouchTrackpad" "TrackpadTwoFingerDoubleTapGesture" -int 0
