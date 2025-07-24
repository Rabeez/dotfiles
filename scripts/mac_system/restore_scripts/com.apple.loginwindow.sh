#!/bin/bash
# Restore settings for com.apple.loginwindow
echo "Restoring com.apple.loginwindow settings..."

defaults write "com.apple.loginwindow" "NSWindow Frame ProcessPanel" "215 362 338 313 0 0 1710 1068 "
defaults write "com.apple.loginwindow" "TALLogoutReason" "Restart"
defaults write "com.apple.loginwindow" "TALLogoutSavesState" -int 0
