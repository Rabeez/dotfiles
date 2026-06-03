#!/usr/bin/env bash
# 06-screenshots.sh — Screenshot folder, format, no shadow

defaults_set com.apple.screencapture location "-string" "$HOME/Pictures/Screenshots"
defaults_set com.apple.screencapture type "-string" "png"
defaults_set com.apple.screencapture disable-shadow "-bool" "true"
defaults_set com.apple.screencapture show-thumbnail "-bool" "false"

# Ensure screenshots directory exists
mkdir -p "$HOME/Pictures/Screenshots"
