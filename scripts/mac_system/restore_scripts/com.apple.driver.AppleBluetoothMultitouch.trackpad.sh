#!/bin/bash
# Restore settings for com.apple.driver.AppleBluetoothMultitouch.trackpad
echo "Restoring com.apple.driver.AppleBluetoothMultitouch.trackpad settings..."

defaults write "com.apple.driver.AppleBluetoothMultitouch.trackpad" "Clicking" -int 1
defaults write "com.apple.driver.AppleBluetoothMultitouch.trackpad" "TrackpadRotate" -int 0
defaults write "com.apple.driver.AppleBluetoothMultitouch.trackpad" "TrackpadThreeFingerDrag" -int 1
defaults write "com.apple.driver.AppleBluetoothMultitouch.trackpad" "TrackpadThreeFingerHorizSwipeGesture" -int 0
defaults write "com.apple.driver.AppleBluetoothMultitouch.trackpad" "TrackpadThreeFingerVertSwipeGesture" -int 0
defaults write "com.apple.driver.AppleBluetoothMultitouch.trackpad" "TrackpadTwoFingerDoubleTapGesture" -int 0
