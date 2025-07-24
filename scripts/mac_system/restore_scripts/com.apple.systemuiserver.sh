#!/bin/bash
# Restore settings for com.apple.systemuiserver
echo "Restoring com.apple.systemuiserver settings..."

defaults write "com.apple.systemuiserver" "NSStatusItem Visible Item-0" -int 0
defaults write "com.apple.systemuiserver" "last-analytics-stamp" "775082506.082534"
# Array value for menuExtras - may need manual handling
# defaults write "com.apple.systemuiserver" "menuExtras" '('
