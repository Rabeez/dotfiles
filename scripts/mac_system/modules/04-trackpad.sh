#!/usr/bin/env bash
# 04-trackpad.sh — Trackpad (tap to click, 3-finger drag)

# Tap to click
defaults_set com.apple.AppleMultitouchTrackpad Clicking "-int" "1"
defaults_set com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking "-int" "1"

# Click thresholds
defaults_set com.apple.AppleMultitouchTrackpad FirstClickThreshold "-int" "0"
defaults_set com.apple.AppleMultitouchTrackpad SecondClickThreshold "-int" "0"

# Three-finger drag
defaults_set com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag "-int" "1"
defaults_set com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag "-int" "1"

# Disable rotate gesture
defaults_set com.apple.AppleMultitouchTrackpad TrackpadRotate "-int" "0"
defaults_set com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRotate "-int" "0"

# Disable three-finger swipe (conflicts with three-finger drag)
defaults_set com.apple.AppleMultitouchTrackpad TrackpadThreeFingerHorizSwipeGesture "-int" "0"
defaults_set com.apple.AppleMultitouchTrackpad TrackpadThreeFingerVertSwipeGesture "-int" "0"
defaults_set com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture "-int" "0"
defaults_set com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerVertSwipeGesture "-int" "0"
