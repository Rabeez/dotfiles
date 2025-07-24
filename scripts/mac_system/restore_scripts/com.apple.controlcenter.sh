#!/bin/bash
# Restore settings for com.apple.controlcenter
echo "Restoring com.apple.controlcenter settings..."

defaults write "com.apple.controlcenter" "LastHeartbeatDateString.daily" "2025-07-23T16:36:18Z"
defaults write "com.apple.controlcenter" "NSStatusItem Preferred Position AudioVideoModule" -int 569
defaults write "com.apple.controlcenter" "NSStatusItem Preferred Position Battery" -int 195
defaults write "com.apple.controlcenter" "NSStatusItem Preferred Position BentoBox" -int 84
defaults write "com.apple.controlcenter" "NSStatusItem Preferred Position Bluetooth" -int 314
defaults write "com.apple.controlcenter" "NSStatusItem Preferred Position FocusModes" -int 516
defaults write "com.apple.controlcenter" "NSStatusItem Preferred Position KeyboardBrightness" -int 351
defaults write "com.apple.controlcenter" "NSStatusItem Preferred Position ScreenMirroring" -int 501
defaults write "com.apple.controlcenter" "NSStatusItem Preferred Position Sound" -int 276
defaults write "com.apple.controlcenter" "NSStatusItem Preferred Position Timer" -int 535
defaults write "com.apple.controlcenter" "NSStatusItem Visible AudioVideoModule" -int 0
defaults write "com.apple.controlcenter" "NSStatusItem Visible Battery" -int 0
defaults write "com.apple.controlcenter" "NSStatusItem Visible Bluetooth" -int 1
defaults write "com.apple.controlcenter" "NSStatusItem Visible FocusModes" -int 0
defaults write "com.apple.controlcenter" "NSStatusItem Visible Item-5" -int 0
defaults write "com.apple.controlcenter" "NSStatusItem Visible Item-6" -int 0
defaults write "com.apple.controlcenter" "NSStatusItem Visible Item-7" -int 0
defaults write "com.apple.controlcenter" "NSStatusItem Visible Item-8" -int 0
defaults write "com.apple.controlcenter" "NSStatusItem Visible KeyboardBrightness" -int 0
defaults write "com.apple.controlcenter" "NSStatusItem Visible MusicRecognition" -int 0
defaults write "com.apple.controlcenter" "NSStatusItem Visible ScreenMirroring" -int 0
defaults write "com.apple.controlcenter" "NSStatusItem Visible Shortcuts" -int 0
defaults write "com.apple.controlcenter" "NSStatusItem Visible Sound" -int 1
defaults write "com.apple.controlcenter" "NSStatusItem Visible Timer" -int 0
defaults write "com.apple.controlcenter" "NSStatusItem Visible WiFi" -int 0
defaults write "com.apple.controlcenter" "missionControlTooltipCount" -int 1
