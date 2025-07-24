#!/bin/bash
# Restore settings for com.apple.menuextra.clock
echo "Restoring com.apple.menuextra.clock settings..."

defaults write "com.apple.menuextra.clock" "ShowDate" -int 2
defaults write "com.apple.menuextra.clock" "ShowDayOfWeek" -int 0
